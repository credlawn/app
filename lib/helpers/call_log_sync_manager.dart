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
const String _lastSuccessfulSyncTimeKey = "lastCallLogSuccessfulSyncTime"; // Key to store last successful sync timestamp

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case _callLogSyncTask:
        print("Executing call log sync task");
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
      isInDebugMode: true, // Set to false for production
    );
    await Workmanager().registerPeriodicTask(
      "callLogSyncTask",
      _callLogSyncTask,
      frequency: const Duration(minutes: 5), // Sync every 5 minutes
      initialDelay: const Duration(minutes: 1), // Start after 1 minute
      constraints: Constraints(
        networkType: NetworkType.connected, // Only run when connected to network
      ),
    );
  }

  static Future<void> syncCallLogs() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final User? user = await SessionManager.getSessionData();

      if (user == null) {
        print("User not logged in, cannot sync call logs.");
        return;
      }

      // 1. Check Call Log Permission
      var status = await Permission.phone.status;
      if (!status.isGranted) {
        status = await Permission.phone.request();
        if (!status.isGranted) {
          print("Call log permission denied, cannot sync.");
          return;
        }
      }

      final List<ConnectivityResult> connectivityResults = await (Connectivity().checkConnectivity());
      final bool isOnline = connectivityResults.contains(ConnectivityResult.mobile) || connectivityResults.contains(ConnectivityResult.wifi);

      if (!isOnline) {
        print("Device is offline, skipping sync.");
        return; // Only sync when online
      }

      // Determine dateFrom for CallLog.query
      int dateFromMillis;
      final int? lastSuccessfulSyncTime = prefs.getInt(_lastSuccessfulSyncTimeKey);

      if (lastSuccessfulSyncTime == null) {
        // First time sync: fetch all logs from the beginning of today
        final DateTime startOfToday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        dateFromMillis = startOfToday.millisecondsSinceEpoch;
        print("First time sync: Fetching logs from start of today: ${startOfToday}");
      } else {
        // Subsequent sync: fetch logs since last successful sync time
        dateFromMillis = lastSuccessfulSyncTime;
        print("Subsequent sync: Fetching logs from last successful sync time: ${DateTime.fromMillisecondsSinceEpoch(lastSuccessfulSyncTime)}");
      }

      // 2. Fetch new call logs from device
      final Iterable<CallLogEntry> newCallLogs = await CallLog.query(
        dateFrom: dateFromMillis,
      );

      if (newCallLogs.isEmpty) {
        print("No new call logs to sync.");
        return;
      }

      print("Found ${newCallLogs.length} new call logs from device.");

      final List<String> rawLogsList = [];
      int latestLogTimestamp = 0;

      for (final logEntry in newCallLogs) {
        // Ensure timestamp is not null before proceeding
        if (logEntry.timestamp == null) continue;

        // Only add logs that are strictly newer than the last successful sync time
        // This handles cases where CallLog.query might return logs slightly older than dateFrom
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
        print("No new logs to send after filtering by timestamp.");
        return;
      }

      final String syncDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final String syncTime = DateFormat('HH:mm:ss').format(DateTime.now());
      final String allRawLogsJson = jsonEncode(rawLogsList);

      print("Attempting to send ${rawLogsList.length} logs as a single batch to backend.");
      try {
        final bool success = await addSyncRecord(
          syncDate: syncDate,
          syncTime: syncTime,
          userEmail: user.userId,
          allRawLogsJson: allRawLogsJson,
          sid: user.sid,
        );

        if (success) {
          print("Successfully synced all ${rawLogsList.length} logs in a single batch.");
          // Update last successful sync time to the timestamp of the latest log processed
          await prefs.setInt(_lastSuccessfulSyncTimeKey, latestLogTimestamp);
        } else {
          print("Backend reported failure for sync batch. Will retry on next cycle.");
          // Do NOT update _lastSuccessfulSyncTimeKey, so these logs are retried.
        }
      } catch (e) {
        print("Failed to sync call logs to backend: $e. Will retry on next cycle.");
        // Do NOT update _lastSuccessfulSyncTimeKey, so these logs are retried.
      }
    } catch (e) {
      print("An error occurred during syncCallLogs: $e");
    }
  }
}
