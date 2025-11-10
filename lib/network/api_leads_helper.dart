import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/models/leads_model.dart';
import 'package:credlawn/api/server_api.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/helpers/error_logger.dart';

// Custom exception for session expiry
class SessionExpiredException implements Exception {
  final String message;
  SessionExpiredException(this.message);

  @override
  String toString() => 'SessionExpiredException: $message';
}

Future<List<LeadsModel>> fetchEmployeeLeadsFromApi(String userId) async {
  final uri = ServerApi.getEmployeeLeads({'user_id': userId});

  try {
    final response = await http.get(uri, headers: await SessionManager.getAuthHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['message'] != null) {
        final leads = (jsonResponse['message'] as List<dynamic>)
            .map((item) => LeadsModel.fromJson(item))
            .toList();
        return leads;
      }
      return Future.error('API Response is missing the "message" key.');
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      // Session expired or invalid
      await SessionManager.clearSession();
      await ErrorLogger.logError(
        title: 'Session Expired During Lead Fetch',
        errorMessage: 'Session invalid (status ${response.statusCode}). Cleared session.',
        errorType: 'Auth',
        userId: userId,
      );
      throw SessionExpiredException('Your session has expired. Please log in again.');
    }
    return Future.error('Failed to load leads from API: ${response.statusCode}');
  } catch (e) {
    if (e is! SessionExpiredException) {
      return Future.error('Exception during API fetch: $e');
    }
    rethrow;
  }
}

Future<bool> syncLeadUpdateToServer(LeadsModel lead) async {
  final user = await SessionManager.getSessionData();
  final uri = ServerApi.updateLeadStatus;

  try {
    final response = await http.post(
      uri,
      headers: await SessionManager.getAuthHeaders(),
      body: json.encode({
        'frappe_id': lead.frappeId,
        'lead_status': lead.leadStatus,
        'lead_status_date': lead.leadStatusDate.isNotEmpty ? lead.leadStatusDate : "",
        'remarks': lead.remarks,
        'arn_no': lead.arnNo,
        'attempted_calls': lead.attemptedCalls,
        'connected_calls': lead.connectedCalls,
        'total_duration': lead.totalDuration,
        'allocation_status': lead.allocationStatus,
        'last_modified_at': DateTime.fromMillisecondsSinceEpoch(lead.lastModifiedAt).toIso8601String(),
        'follow_up_date': lead.followUpDate,
        'follow_up_time': lead.followUpTime,
        'date_of_birth': lead.dateOfBirth.isNotEmpty ? lead.dateOfBirth : "",
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['message']?['status'] == 'success';
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      // Session expired or invalid
      await SessionManager.clearSession();
      await ErrorLogger.logError(
        title: 'Session Expired During Lead Sync',
        errorMessage: 'Session invalid (status ${response.statusCode}) during sync of lead ${lead.frappeId}. Cleared session.',
        errorType: 'Auth',
        userId: user?.userId,
      );
      throw SessionExpiredException('Your session has expired. Please log in again.');
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

Future<bool> markLeadInactiveOnServer(String frappeId) async {
  final user = await SessionManager.getSessionData();
  final uri = ServerApi.markLeadInactive;

  try {
    final response = await http.post(
      uri,
      headers: await SessionManager.getAuthHeaders(),
      body: json.encode({'frappe_id': frappeId}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['status'] == 'success';
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      // Session expired or invalid
      await SessionManager.clearSession();
      await ErrorLogger.logError(
        title: 'Session Expired During Mark Inactive',
        errorMessage: 'Session invalid (status ${response.statusCode}) during mark inactive for lead ${frappeId}. Cleared session.',
        errorType: 'Auth',
        userId: user?.userId,
      );
      throw SessionExpiredException('Your session has expired. Please log in again.');
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
    if (e is! SessionExpiredException) {
      await ErrorLogger.logException(
        context: 'markLeadInactiveOnServer',
        exception: e,
        userId: user?.userId,
      );
    }
    rethrow;
  }
}
