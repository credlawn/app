import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:call_log/call_log.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:credlawn/network/api_raw_call_log_helper.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

const String _callLogSyncTask = "callLogSyncTask";
const String _lastSuccessfulSyncTimeKey = "lastSuccessfulSyncTime";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case _callLogSyncTask:
        await CallLogSyncManager.syncCallLogs();
        break;
    }
    return Future.value(true);
  });
}

class CallLogSyncManager {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    await Workmanager().registerPeriodicTask(
      "callLogSyncTask",
      _callLogSyncTask,
      frequency: const Duration(minutes: 5),
      initialDelay: const Duration(minutes: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Future<void> syncCallLogs() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final User? user = await SessionManager.getSessionData();

      if (user == null) {
        return;
      }

      var status = await Permission.phone.status;
      if (!status.isGranted) {
        status = await Permission.phone.request();
        if (!status.isGranted) {
          return;
        }
      }

      final List<ConnectivityResult> connectivityResults = await (Connectivity().checkConnectivity());
      final bool isOnline = connectivityResults.contains(ConnectivityResult.mobile) ||
          connectivityResults.contains(ConnectivityResult.wifi);

      if (!isOnline) {
        return;
      }

      int dateFromMillis;
      final int? lastSuccessfulSyncTime = prefs.getInt(_lastSuccessfulSyncTimeKey);

      if (lastSuccessfulSyncTime == null) {
        final DateTime startOfToday =
            DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        dateFromMillis = startOfToday.millisecondsSinceEpoch;
      } else {
        dateFromMillis = lastSuccessfulSyncTime;
      }

      final Iterable<CallLogEntry> newCallLogs = await CallLog.query(
        dateFrom: dateFromMillis,
      );

      if (newCallLogs.isEmpty) {
        return;
      }

      final List<String> rawLogsList = [];
      int latestLogTimestamp = 0;

      for (final logEntry in newCallLogs) {
        if (logEntry.timestamp == null) continue;
        if (logEntry.number == null || (logEntry.number?.isEmpty ?? true)) continue;
        if (logEntry.timestamp! <= dateFromMillis) continue;

        final String rawLogJson = jsonEncode({
          "number": logEntry.number,
          "duration": logEntry.duration,
          "timestamp": logEntry.timestamp,
          "callType": logEntry.callType.toString().split('.').last,
          "name": logEntry.name,
          "simDisplayName": logEntry.simDisplayName,
          "formattedNumber": logEntry.formattedNumber,
        });

        rawLogsList.add(rawLogJson);

        if (logEntry.timestamp! > latestLogTimestamp) {
          latestLogTimestamp = logEntry.timestamp!;
        }
      }

      if (rawLogsList.isEmpty) {
        return;
      }

      final String syncDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final String syncTime = DateFormat('HH:mm:ss').format(DateTime.now());
      final String allRawLogsJson = jsonEncode(rawLogsList);

      final bool success = await addSyncRecord(
        syncDate: syncDate,
        syncTime: syncTime,
        userEmail: user.userId,
        allRawLogsJson: allRawLogsJson,
        sid: user.sid,
      );

      if (success) {
        await prefs.setInt(_lastSuccessfulSyncTimeKey, latestLogTimestamp);
      }
    } catch (_) {}
  }
}
