import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/network/api_network.dart';
import 'package:credlawn/models/fcm_log_model.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';

Future<List<FcmLogModel>> fetchFcmLogs({required int page, String? searchTerm}) async {
  final User? user = await SessionManager.getSessionData();
  if (user == null) {
    throw Exception('User not logged in.');
  }
  final String sid = user.sid;

  final Map<String, String> queryParams = {
    'page': page.toString(),
  };

  if (searchTerm != null && searchTerm.isNotEmpty) {
    queryParams['search_term'] = searchTerm;
  }

  String queryString = Uri(queryParameters: queryParams).query;
  final Uri uri = Uri.parse('${ApiNetwork.getFcmLogs}?$queryString');

  try {
    final response = await http.get(
      uri,
      headers: {'Cookie': 'sid=$sid'},
    );

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
    throw Exception('An error occurred while fetching FCM logs: $e');
  }
}

Future<void> updateFcmLogStatus({required String logId}) async {
  final User? user = await SessionManager.getSessionData();
  if (user == null) {
    throw Exception('User not logged in.');
  }
  final String sid = user.sid;

  final Uri uri = Uri.parse(ApiNetwork.updateFcmLogStatus);

  try {
    final response = await http.post(
      uri,
      headers: {
        'Cookie': 'sid=$sid',
        'Content-Type': 'application/json',
      },
      body: json.encode({'log_id': logId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update FCM log status: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('An error occurred while updating FCM log status: $e');
  }
}

Future<int> getUnreadFcmLogsCount() async {
  final User? user = await SessionManager.getSessionData();
  if (user == null) {
    throw Exception('User not logged in.');
  }
  final String sid = user.sid;

  final Uri uri = Uri.parse(ApiNetwork.getUnreadFcmLogsCount);

  try {
    final response = await http.get(
      uri,
      headers: {'Cookie': 'sid=$sid'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse['message']['unread_count'] ?? 0;
    } else {
      throw Exception('Failed to get unread FCM logs count: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('An error occurred while getting unread FCM logs count: $e');
  }
}
