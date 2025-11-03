import 'package:permission_handler/permission_handler.dart';
import 'package:call_log/call_log.dart';
import 'package:credlawn/models/call_log_model.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/helpers/app_database.dart';

class CallHistoryRepository {
  final AppDatabase _appDatabase;

  CallHistoryRepository(this._appDatabase);

  static String normalizeNumber(String number) {
    final digitsOnly = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length >= 10) {
      return digitsOnly.substring(digitsOnly.length - 10);
    }
    return digitsOnly;
  }

  Future<void> syncPhoneCallLogs() async {
    if (!await Permission.phone.isGranted) {
      if (await Permission.phone.request() != PermissionStatus.granted) {
        return;
      }
    }

    final db = await _appDatabase.database;
    final lastTimestampResult = await db.rawQuery('SELECT MAX(timestamp) as max_time FROM call_history');
    final lastTimestamp = lastTimestampResult.first['max_time'] as int? ?? 0;

    final now = DateTime.now().millisecondsSinceEpoch;
    final oneWeekAgo = now - (7 * 24 * 60 * 60 * 1000);

    int queryFromTimestamp;
    if (lastTimestamp == 0 || lastTimestamp > now) {
      queryFromTimestamp = oneWeekAgo;
    } else {
      queryFromTimestamp = lastTimestamp > oneWeekAgo ? lastTimestamp : oneWeekAgo;
    }

    final Iterable<CallLogEntry> entries = await CallLog.query(
      dateFrom: queryFromTimestamp,
    );

    final User? currentUser = await SessionManager.getSessionData();
    final String currentUserId = currentUser?.userId ?? '';

    final batch = db.batch();
    for (final entry in entries) {
      if (entry.number == null || entry.number!.isEmpty) continue;
      batch.insert('call_history', {
        'phone_number': entry.number!,
        'normalized_number': CallHistoryRepository.normalizeNumber(entry.number!),
        'duration': entry.duration ?? 0,
        'call_type': entry.callType?.toString().split('.').last ?? 'UNKNOWN',
        'timestamp': entry.timestamp ?? 0,
        'user': currentUserId,
      });
    }
    await batch.commit(noResult: true);
    await checkAndDeactivatePoorPerformers();
  }

  Future<int> getCallCount(String mobileNo) async {
    final db = await _appDatabase.database;
    final normalizedNumber = CallHistoryRepository.normalizeNumber(mobileNo);
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM call_history WHERE normalized_number = ?',
      [normalizedNumber],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int?> getLastCallDuration(String mobileNo) async {
    final db = await _appDatabase.database;
    final normalizedNumber = CallHistoryRepository.normalizeNumber(mobileNo);
    final result = await db.query(
      'call_history',
      columns: ['duration'],
      where: 'normalized_number = ?',
      whereArgs: [normalizedNumber],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['duration'] as int?;
    }
    return null;
  }

  Future<void> deleteLogsForNumber(String mobileNo) async {
    final db = await _appDatabase.database;
    final normalizedNumber = CallHistoryRepository.normalizeNumber(mobileNo);
    await db.delete(
      'call_history',
      where: 'normalized_number = ?',
      whereArgs: [normalizedNumber],
    );
  }

  Future<List<CallLogModel>> getLogsForNumber(String mobileNo) async {
    final db = await _appDatabase.database;
    final normalizedNumber = CallHistoryRepository.normalizeNumber(mobileNo);
    final maps = await db.query(
      'call_history',
      where: 'normalized_number = ?',
      whereArgs: [normalizedNumber],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return CallLogModel.fromMap(maps[i]);
    });
  }

  Future<Map<String, int>> calculateCallStatistics(String mobileNo) async {
    final db = await _appDatabase.database;
    final normalizedNumber = CallHistoryRepository.normalizeNumber(mobileNo);

    final sevenDaysAgo = DateTime.now().millisecondsSinceEpoch - (7 * 24 * 60 * 60 * 1000);

    final attemptedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM call_history WHERE normalized_number = ? AND call_type = ? AND timestamp >= ?',
      [normalizedNumber, 'outgoing', sevenDaysAgo],
    );
    final attemptedCalls = (attemptedResult.first['count'] as int?) ?? 0;

    final connectedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM call_history WHERE normalized_number = ? AND duration > 0 AND timestamp >= ?',
      [normalizedNumber, sevenDaysAgo],
    );
    final connectedCalls = (connectedResult.first['count'] as int?) ?? 0;

    final durationResult = await db.rawQuery(
      'SELECT SUM(duration) as total FROM call_history WHERE normalized_number = ? AND duration > 0 AND timestamp >= ?',
      [normalizedNumber, sevenDaysAgo],
    );
    final totalDuration = (durationResult.first['total'] as int?) ?? 0;

    return {
      'attempted': attemptedCalls,
      'connected': connectedCalls,
      'duration': totalDuration,
    };
  }

  Future<bool> hasRecentSuccessfulCall(String mobileNo, int days) async {
    final db = await _appDatabase.database;
    final normalizedNumber = CallHistoryRepository.normalizeNumber(mobileNo);
    final timeAgo = DateTime.now().millisecondsSinceEpoch - (days * 24 * 60 * 60 * 1000);

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM call_history WHERE normalized_number = ? AND duration > 0 AND timestamp >= ?',
      [normalizedNumber, timeAgo],
    );
    return ((result.first['count'] as int?) ?? 0) > 0;
  }

  Future<int> countRecentFailedCalls(String mobileNo, int lastN) async {
    final db = await _appDatabase.database;
    final normalizedNumber = CallHistoryRepository.normalizeNumber(mobileNo);

    final result = await db.rawQuery(
      'SELECT call_type, duration FROM call_history WHERE normalized_number = ? ORDER BY timestamp DESC LIMIT ?',
      [normalizedNumber, lastN],
    );

    return result.where((row) =>
      row['call_type'] == 'outgoing' && (row['duration'] as int? ?? 0) == 0
    ).length;
  }

  Future<void> checkAndDeactivatePoorPerformers() async {
    final db = await _appDatabase.database;
    final activeLeads = await db.query('leads', where: 'allocation_status = ?', whereArgs: ['Active']);

    for (final lead in activeLeads) {
      final mobileNo = lead['mobile_no'] as String;

      final hasRecentSuccess = await hasRecentSuccessfulCall(mobileNo, 3);
      final recentFailedCount = await countRecentFailedCalls(mobileNo, hasRecentSuccess ? 4 : 3);

      final shouldDeactivate = !hasRecentSuccess && recentFailedCount >= 3 ||
                             hasRecentSuccess && recentFailedCount >= 4;

      if (shouldDeactivate) {
        await db.update(
          'leads',
          {
            'lead_status': 'CNR',
            'allocation_status': 'Inactive',
            'is_dirty': 1,
            'last_modified_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'frappe_id = ?',
          whereArgs: [lead['frappe_id']],
        );
      }
    }
  }
}
