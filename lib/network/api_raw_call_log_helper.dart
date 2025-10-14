import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/network/api_network.dart';

Future<bool> addSyncRecord({
  required String syncDate,
  required String syncTime,
  required String userEmail,
  required String allRawLogsJson,
  required String sid,
}) async {
  final Map<String, dynamic> body = {
    'sync_date': syncDate,
    'sync_time': syncTime,
    'user_email': userEmail,
    'all_raw_logs_json': allRawLogsJson,
  };

  try {
    final response = await http.post(
      Uri.parse(ApiNetwork.addSyncRecord),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse['message'] != null && jsonResponse['message']['success'] == true;
    } else {
      throw Exception('Failed to add sync record: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('An error occurred while adding sync record: $e');
  }
}
