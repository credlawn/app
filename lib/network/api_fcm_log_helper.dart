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

  // Note: Frappe endpoints don't use uri.http constructor well with https
  // Building the URL manually is more reliable.
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
