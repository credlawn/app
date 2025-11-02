import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/network/api_network.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/feedback_model.dart';
import 'package:credlawn/helpers/database_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FeedbackSyncService {
  // Sync all unsynced feedback
  static Future<void> syncUnsyncedFeedback() async {
    // Check network connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return; // Skip sync if offline
    }

    final unsyncedFeedback = await _getUnsyncedFeedback();
    if (unsyncedFeedback.isEmpty) return;

    try {
      final response = await _syncWithServer(unsyncedFeedback);
      await _processSyncResponse(response);
    } catch (e) {
      // Log error but don't throw - we'll retry later
      print('Error syncing feedback: $e');
    }
  }

  // Sync a single feedback record
  static Future<void> syncFeedback(FeedbackModel feedback) async {
    // Check network connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print('Skipping sync - no network connection available');
      return; // Skip sync if offline
    }

    try {
      print('Attempting to sync feedback for lead: ${feedback.leadFrappeId}');
      print('Feedback details: ${feedback.toString()}');

      final response = await _syncWithServer([feedback]);
      print('Sync response received for lead: ${feedback.leadFrappeId}');
      await _processSyncResponse(response);
    } catch (e) {
      // Log error but don't throw - we'll retry later
      print('Error syncing feedback for lead ${feedback.leadFrappeId}: $e');
    }
  }

  // Get all unsynced feedback from local database
  static Future<List<FeedbackModel>> _getUnsyncedFeedback() async {
    final feedbackList = await DatabaseService.instance.feedbackRepository.getAllFeedback();
    return feedbackList.where((feedback) => !feedback.isSynced).toList();
  }

  // Sync feedback with server
  static Future<Map<String, dynamic>> _syncWithServer(List<FeedbackModel> feedbackList) async {
    final user = await SessionManager.getSessionData();
    final sid = user?.sid;

    if (sid == null) {
      throw Exception('User not authenticated');
    }

    print('Preparing to sync ${feedbackList.length} feedback records with server');

    // Prepare feedback data for server
    final feedbackData = feedbackList.map((feedback) {
      return {
        'local_id': feedback.id,
        'customer_name': feedback.customerName,
        'lead_frappe_id': feedback.leadFrappeId,
        'follow_up_date': feedback.followUpDate,
        'follow_up_time': feedback.followUpTime,
        'status': feedback.status,
        'remarks': feedback.remarks,
        'user': feedback.userId,
        'timestamp': DateTime.fromMillisecondsSinceEpoch(feedback.timestamp).toIso8601String(),
        'mobile_no': feedback.mobileNo,
      };
    }).toList();

    print('Sending feedback data to server: ${jsonEncode({'feedback_list': feedbackData})}');

    final response = await http.post(
      Uri.parse(ApiNetwork.syncFeedback),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid',
      },
      body: jsonEncode({'feedback_list': feedbackData}),
    );

    print('Received response from server with status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to sync feedback: ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }

  // Process server response and update local database
  static Future<void> _processSyncResponse(Map<String, dynamic> response) async {
    final results = response['results'] as List<dynamic>;

    for (final result in results) {
      final resultMap = result as Map<String, dynamic>;
      final localId = resultMap['local_id'] as int;
      final status = resultMap['status'] as String;

      if (status == 'success') {
        final serverId = resultMap['server_id'] as String;

        // Update feedback as synced
        await DatabaseService.instance.feedbackRepository.markFeedbackAsSynced(
          localId,
          serverId: serverId,
        );
      } else {
        // Increment sync attempts
        await DatabaseService.instance.feedbackRepository.incrementSyncAttempts(localId);
      }
    }
  }
}
