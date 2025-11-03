import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/models/leads_model.dart';
import 'package:credlawn/api/server_api.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/helpers/error_logger.dart';

Future<List<LeadsModel>> fetchEmployeeLeadsFromApi(String userId, String sid) async {
  final uri = ServerApi.getEmployeeLeads({'user_id': userId});

  try {
    final response = await http.get(uri, headers: {'Cookie': 'sid=$sid'});

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['message'] != null) {
        final leads = (jsonResponse['message'] as List<dynamic>)
            .map((item) => LeadsModel.fromJson(item))
            .toList();
        return leads;
      }
      return Future.error('API Response is missing the "message" key.');
    }
    return Future.error('Failed to load leads from API: ${response.statusCode}');
  } catch (e) {
    return Future.error('Exception during API fetch: $e');
  }
}

Future<bool> syncLeadUpdateToServer(LeadsModel lead, String sid) async {
  final user = await SessionManager.getSessionData();
  final uri = ServerApi.updateLeadStatus;

  try {
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json', 'Cookie': 'sid=$sid'},
      body: json.encode({
        'frappe_id': lead.frappeId,
        'lead_status': lead.leadStatus,
        'remarks': lead.remarks,
        'arn_no': lead.arnNo,
        'attempted_calls': lead.attemptedCalls,
        'connected_calls': lead.connectedCalls,
        'total_duration': lead.totalDuration,
        'allocation_status': lead.allocationStatus,
        'last_synced_at': DateTime.fromMillisecondsSinceEpoch(lead.lastSyncedAt).toIso8601String(),
        'follow_up_date': lead.followUpDate,
        'follow_up_time': lead.followUpTime,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['message']?['status'] == 'success';
    } else {
      if (response.statusCode == 417) {
        if (response.body.contains('not found')) {
          await ErrorLogger.logError(
            title: 'Lead Not Found on Server',
            errorMessage: 'Lead ${lead.frappeId} not found on server. May have been deleted or ID mismatch.',
            errorType: 'Data Sync',
            userId: user?.userId,
          );
        } else if (response.body.contains('Document has been modified after you have opened it') ||
                   response.body.contains('TimestampMismatchError')) {
          throw Exception('CONCURRENCY_ERROR: Document has been modified after you have opened it');
        }
      }

      await ErrorLogger.logApiError(
        endpoint: uri.toString(),
        method: 'POST',
        statusCode: response.statusCode,
        responseBody: response.body,
        userId: user?.userId,
      );
      return false;
    }
  } catch (e) {
    if (!e.toString().contains('CONCURRENCY_ERROR')) {
      await ErrorLogger.logException(
        context: 'syncLeadUpdateToServer',
        exception: e,
        userId: user?.userId,
      );
    }
    rethrow;
  }
}

Future<bool> markLeadInactiveOnServer(String frappeId, String sid) async {
  final user = await SessionManager.getSessionData();
  final uri = ServerApi.markLeadInactive;

  try {
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json', 'Cookie': 'sid=$sid'},
      body: json.encode({'frappe_id': frappeId}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['status'] == 'success';
    } else {
      await ErrorLogger.logApiError(
        endpoint: uri.toString(),
        method: 'POST',
        statusCode: response.statusCode,
        responseBody: response.body,
        userId: user?.userId,
      );
      return false;
    }
  } catch (e) {
    await ErrorLogger.logException(
      context: 'markLeadInactiveOnServer',
      exception: e,
      userId: user?.userId,
    );
    return false;
  }
}
