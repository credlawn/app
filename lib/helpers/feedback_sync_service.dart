import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/api/server_api.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/feedback_model.dart';
import 'package:credlawn/helpers/database_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FeedbackSyncService {
  static Future<void> syncUnsyncedFeedback() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;

    final unsyncedFeedback = await _getUnsyncedFeedback();
    if (unsyncedFeedback.isEmpty) return;

    try {
      final response = await _syncWithServer(unsyncedFeedback);
      await _processSyncResponse(response);
    } catch (e) {}
  }

  static Future<void> syncFeedback(FeedbackModel feedback) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;

    try {
      final response = await _syncWithServer([feedback]);
      await _processSyncResponse(response);
    } catch (e) {}
  }

  static Future<List<FeedbackModel>> _getUnsyncedFeedback() async {
    final feedbackList = await DatabaseService.instance.feedbackRepository.getAllFeedback();
    return feedbackList.where((feedback) => !feedback.isSynced).toList();
  }

  static Future<Map<String, dynamic>> _syncWithServer(List<FeedbackModel> feedbackList) async {
    final user = await SessionManager.getSessionData();
    final sid = user?.sid;
    if (sid == null) throw Exception('User not authenticated');

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

    final response = await http.post(
      ServerApi.syncFeedback,
      headers: {'Content-Type': 'application/json', 'Cookie': 'sid=$sid'},
      body: jsonEncode({'feedback_list': feedbackData}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to sync feedback: ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }

  static Future<void> _processSyncResponse(Map<String, dynamic> response) async {
    final message = response['message'] as Map<String, dynamic>;
    final results = message['results'] as List<dynamic>;

    for (final result in results) {
      final resultMap = result as Map<String, dynamic>;
      final localId = resultMap['local_id'] as int;
      final status = resultMap['status'] as String;

      if (status == 'success') {
        final serverId = resultMap['server_id'] as String;
        await DatabaseService.instance.feedbackRepository.markFeedbackAsSynced(localId, serverId: serverId);
      } else {
        await DatabaseService.instance.feedbackRepository.incrementSyncAttempts(localId);
      }
    }
  }
}
