import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/network/server_api.dart';
import 'package:credlawn/network/api_error_logger_helper.dart';
import 'package:credlawn/models/fcm_log_model.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';

Future<List<FcmLogModel>> fetchFcmLogs({required int page, String? searchTerm, String? status, String? filterType}) async {
  final Map<String, String> queryParams = {
    'page': page.toString(),
  };

  if (searchTerm != null && searchTerm.isNotEmpty) {
    queryParams['search_term'] = searchTerm;
  }

  if (status != null && status.isNotEmpty) {
    queryParams['status'] = status;
  }

  if (filterType != null && filterType.isNotEmpty) {
    queryParams['filter_type'] = filterType;
  }

  String queryString = Uri(queryParameters: queryParams).query;
  final Uri uri = Uri.parse('${ServerApi.getFcmLogs}?$queryString');

  try {
    final response = await http.get(
      uri,
      headers: await SessionManager.getAuthHeaders(),
    ).timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['message'] != null && jsonResponse['message'] is List) {
        final List<dynamic> logList = jsonResponse['message'];
        return logList.map((json) => FcmLogModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load FCM logs: ${response.statusCode}');
    }
  } catch (e) {
    // Log error to backend
    await logAppError(
      errorMessage: 'Failed to fetch FCM logs',
      errorContext: 'Page: $page, Search: $searchTerm, Status: $status, Error: $e',
    );
    throw Exception('An error occurred while fetching FCM logs: $e');
  }
}

Future<void> updateFcmLogStatus({required String logId}) async {
  final Uri uri = Uri.parse(ServerApi.updateFcmLogStatus);

  try {
    final response = await http.post(
      uri,
      headers: await SessionManager.getAuthHeaders(),
      body: json.encode({'log_id': logId}),
    ).timeout(Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to update FCM log status: ${response.statusCode}');
    }
  } catch (e) {
    // Log error to backend
    await logAppError(
      errorMessage: 'Failed to update FCM log status',
      errorContext: 'Log ID: $logId, Error: $e',
    );
    throw Exception('An error occurred while updating FCM log status: $e');
  }
}

Future<int> getUnreadFcmLogsCount() async {
  final Uri uri = Uri.parse(ServerApi.getUnreadFcmLogsCount);

  try {
    final response = await http.get(
      uri,
      headers: await SessionManager.getAuthHeaders(),
    ).timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse['message']['unread_count'] ?? 0;
    } else {
      throw Exception('Failed to get unread FCM logs count: ${response.statusCode}');
    }
  } catch (e) {
    // Log error to backend
    await logAppError(
      errorMessage: 'Failed to get unread FCM logs count',
      errorContext: 'Error: $e',
    );
    throw Exception('An error occurred while getting unread FCM logs count: $e');
  }
}

Future<void> markFcmLogScreenRead({required String logId}) async {
  final Uri uri = Uri.parse(ServerApi.markFcmLogScreenRead);

  try {
    final response = await http.post(
      uri,
      headers: await SessionManager.getAuthHeaders(),
      body: json.encode({'log_id': logId}),
    ).timeout(Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to mark FCM log screen read: ${response.statusCode}');
    }
  } catch (e) {
    // Log error to backend
    await logAppError(
      errorMessage: 'Failed to mark FCM log screen read',
      errorContext: 'Log ID: $logId, Error: $e',
    );
    throw Exception('An error occurred while marking FCM log screen read: $e');
  }
}
