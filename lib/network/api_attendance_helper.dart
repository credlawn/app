import 'dart:convert';
import 'dart:math';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/network/api_network.dart';
import 'package:http/http.dart' as http;

class ApiAttendanceHelper {
  static Future<String> markAttendance({
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
        final responseData = jsonDecode(response.body);
        return responseData['data']['name'];
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['exception'] ?? 'Failed to create attendance record');
      }
    } catch (e) {
      throw Exception('An error occurred while creating record: $e');
    }
  }

  static Future<String> uploadImage({
    required String docname,
    required String imagePath,
  }) async {
    final User? user = await SessionManager.getSessionData();
    if (user == null) {
      throw Exception('User not logged in');
    }

    final random = Random().nextInt(900000) + 100000; // 6-digit number
    final extension = imagePath.substring(imagePath.lastIndexOf('.'));
    final newFilename = '$random$extension';

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiNetwork.baseUrl}/api/method/upload_file'),
    );

    request.headers['Cookie'] = 'sid=${user.sid}';
    request.fields['doctype'] = 'Attendance Records';
    request.fields['docname'] = docname;
    request.fields['fieldname'] = 'atn_image';
    request.fields['is_private'] = '1';
    request.fields['optimize'] = '1'; // Enable server-side image optimization
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imagePath,
      filename: newFilename,
    ));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);
        return responseData['message']['file_url']; // Return the file path
      } else {
        final errorData = jsonDecode(responseBody);
        throw Exception(errorData['exception'] ?? 'Failed to upload image');
      }
    } catch (e) {
      throw Exception('An error occurred while uploading image: $e');
    }
  }

  static Future<void> updateImagePath({
    required String docname,
    required String filePath,
  }) async {
    final User? user = await SessionManager.getSessionData();
    if (user == null) {
      throw Exception('User not logged in');
    }

    final url = '${ApiNetwork.baseUrl}/api/resource/Attendance Records/$docname';
    final body = {'atn_image': filePath};

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'sid=${user.sid}',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['exception'] ?? 'Failed to update image path');
      }
    } catch (e) {
      throw Exception('An error occurred while updating path: $e');
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
        return null;
      } else {
        throw Exception('Failed to fetch last attendance');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}