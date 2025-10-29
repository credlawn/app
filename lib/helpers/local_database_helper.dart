
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:call_log/call_log.dart';
import 'package:credlawn/models/call_log_model.dart';

class LocalDatabaseHelper {
  static final LocalDatabaseHelper instance = LocalDatabaseHelper._init();
  static Database? _database;

  LocalDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('local_calls.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE call_history (
  id $idType,
  phone_number $textType,
  normalized_number $textType,
  duration $intType,
  call_type $textType,
  timestamp $intType
)
''');

    await db.execute('CREATE INDEX idx_normalized_number ON call_history (normalized_number)');
  }

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
        return; // Permission not granted
      }
    }

    final db = await instance.database;
    final lastTimestampResult = await db.rawQuery('SELECT MAX(timestamp) as max_time FROM call_history');
    final lastTimestamp = (lastTimestampResult.first['max_time'] as int? ?? 0) * 1000;

    final Iterable<CallLogEntry> entries = await CallLog.query(
      dateFrom: lastTimestamp,
    );

    final batch = db.batch();
    for (final entry in entries) {
      if (entry.number == null || entry.number!.isEmpty) continue;
      batch.insert('call_history', {
        'phone_number': entry.number!,
        'normalized_number': LocalDatabaseHelper.normalizeNumber(entry.number!),
        'duration': entry.duration ?? 0,
        'call_type': entry.callType?.toString().split('.').last ?? 'UNKNOWN',
        'timestamp': entry.timestamp ?? 0,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<int> getCallCount(String mobileNo) async {
    final db = await instance.database;
    final normalizedNumber = LocalDatabaseHelper.normalizeNumber(mobileNo);
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM call_history WHERE normalized_number = ?',
      [normalizedNumber],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<void> deleteLogsForNumber(String mobileNo) async {
    final db = await instance.database;
    final normalizedNumber = LocalDatabaseHelper.normalizeNumber(mobileNo);
    await db.delete(
      'call_history',
      where: 'normalized_number = ?',
      whereArgs: [normalizedNumber],
    );
  }

  Future<List<CallLogModel>> getLogsForNumber(String mobileNo) async {
    final db = await instance.database;
    final normalizedNumber = normalizeNumber(mobileNo);
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

  Future close() async {

    final db = await instance.database;
    db.close();
  }
}
