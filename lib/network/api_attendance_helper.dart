import 'dart:convert';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/models/attendance_model.dart';
import 'package:credlawn/network/api_network.dart';
import 'package:http/http.dart' as http;

class ApiAttendanceHelper {
  static Future<AttendanceResponse> markAttendance({
    required String logType,
    required double latitude,
    required double longitude,
    required String remarks,
  }) async {
    final User? user = await SessionManager.getSessionData();
    if (user == null) {
      throw Exception('User not logged in');
    }
    final String sid = user.sid;

    final Map<String, dynamic> body = {
      'user': user.userId,
      'log_type': logType,
      'latitude': latitude,
      'longitude': longitude,
      'remarks': remarks,
    };

    const String url = '${ApiNetwork.baseUrl}/api/resource/Attendance Records';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'sid=$sid',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AttendanceResponse(message: 'Attendance marked successfully');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['exception'] ?? 'Failed to mark attendance');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  static Future<String?> getLastAttendanceForToday() async {
    final User? user = await SessionManager.getSessionData();
    if (user == null) {
      throw Exception('User not logged in');
    }

    final today = DateTime.now();
    final date = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final filters = '[["user","=","${user.userId}"],["attendance_date","=","$date"]]';
    final fields = '["log_type"]';
    final url = '${ApiNetwork.baseUrl}/api/resource/Attendance Records'
        '?fields=${Uri.encodeQueryComponent(fields)}'
        '&filters=${Uri.encodeQueryComponent(filters)}'
        '&order_by=timestamp desc&limit_page_length=1';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Cookie': 'sid=${user.sid}',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
          return jsonResponse['data'][0]['log_type'];
        }
        return null; // No record found for today
      } else {
        throw Exception('Failed to fetch last attendance');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
