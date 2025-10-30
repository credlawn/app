import 'dart:convert';
import 'dart:math';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/models/geofence_config.dart';
import 'package:credlawn/models/attendance_record_model.dart';
import 'package:credlawn/models/today_attendance_status.dart'; // Added this import
import 'package:credlawn/network/api_network.dart';
import 'package:http/http.dart' as http;

class ApiAttendanceHelper {
  static Future<String> markAttendance({
    required String logType,
    required double latitude,
    required double longitude,
    // remarks: remarks, // Removed remarks parameter
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
      // 'remarks': remarks, // Removed remarks from body
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
      ApiAttendanceHelper.logErrorToFrappe('Error creating attendance record: $e', 'Flutter Attendance Error');
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
      ApiAttendanceHelper.logErrorToFrappe('Error uploading image: $e', 'Flutter Attendance Error');
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
      ApiAttendanceHelper.logErrorToFrappe('Error updating image path: $e', 'Flutter Attendance Error');
      throw Exception('An error occurred while updating path: $e');
    }
  }

  static Future<TodayAttendanceStatus> getLastAttendanceForToday() async {
    final User? user = await SessionManager.getSessionData();
    if (user == null) {
      throw Exception('User not logged in');
    }

    final today = DateTime.now();
    final date = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      // Use the custom API to get today's summary
      final List<AttendanceRecord> todaySummary = await getAttendanceRecords(fromDate: date, toDate: date);

      bool hasCheckedIn = false;
      bool hasCheckedOut = false;
      String? lastLogType; // This will be determined by the summary

      if (todaySummary.isNotEmpty) {
        final record = todaySummary.first; // Should only be one record for today
        if (record.inTime != 'N/A') {
          hasCheckedIn = true;
        }
        if (record.outTime != 'N/A') {
          hasCheckedOut = true;
        }

        // Determine lastLogType based on presence of in/out times
        if (hasCheckedIn && hasCheckedOut) {
          // If both exist, we need to know which was truly last. This requires more info from backend.
          // For now, if both exist, assume the day is completed.
          // If only In, then In was last. If only Out, then Out was last (unlikely scenario).
          // The button logic will primarily rely on hasCheckedIn and hasCheckedOut.
          lastLogType = 'Out'; // Assuming Out was the last action if both are present
        } else if (hasCheckedIn) {
          lastLogType = 'In';
        } else if (hasCheckedOut) {
          lastLogType = 'Out';
        }
      }

      return TodayAttendanceStatus(
        hasCheckedIn: hasCheckedIn,
        hasCheckedOut: hasCheckedOut,
        lastLogType: lastLogType,
      );
    } catch (e) {
      ApiAttendanceHelper.logErrorToFrappe('Error fetching today\'s attendance summary: $e', 'Flutter Attendance Error');
      // Return default status on error
      return TodayAttendanceStatus();
    }
  }

  static Future<GeofenceConfig?> fetchActiveGeofence() async {
        final User? user = await SessionManager.getSessionData();
        if (user == null) {
          throw Exception('User not logged in');
        }
    
        final String filters = '[["is_active","=",1]]'; // Filter for active geofences
        final String fields = '["location_name", "latitude", "longitude", "radius", "office_start_time", "office_end_time"]';

        final Map<String, dynamic> queryParams = {
          'fields': fields,
          'filters': filters,
        };

        final Uri uri = Uri.https(
          Uri.parse(ApiNetwork.baseUrl).host,
          '/api/resource/Attendance Geofence',
          queryParams,
        );
    
        try {
          final response = await http.get(
            uri,
            headers: {
              'Cookie': 'sid=${user.sid}',
            },
          );
    
                if (response.statusCode == 200) {
                  final jsonResponse = json.decode(response.body);
                  if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
                    return GeofenceConfig.fromJson(jsonResponse['data'][0]);
                  }
                          return null; // No active geofence found
                        } else {
                          throw Exception('Failed to fetch active geofence');
                        }
                      } catch (e) {
                        throw Exception('An error occurred while fetching geofence: $e');
                      }
                    }

  static Future<List<AttendanceRecord>> getAttendanceRecords({String? fromDate, String? toDate}) async {
    final User? user = await SessionManager.getSessionData();
    if (user == null) {
      throw Exception('User not logged in');
    }

    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final DateTime toDateObj = DateTime.now();

    final String finalFromDate = fromDate ?? '${firstDayOfMonth.year}-${firstDayOfMonth.month.toString().padLeft(2, '0')}-${firstDayOfMonth.day.toString().padLeft(2, '0')}';
    final String finalToDate = toDate ?? '${toDateObj.year}-${toDateObj.month.toString().padLeft(2, '0')}-${toDateObj.day.toString().padLeft(2, '0')}';

    final Map<String, dynamic> queryParams = {
      'user_id': user.userId,
      'from_date': finalFromDate,
      'to_date': finalToDate,
    };

    final Uri uri = Uri.https(
      Uri.parse(ApiNetwork.baseUrl).host,
      Uri.parse(ApiNetwork.getDailyAttendanceSummary).path, // Use the path from the new endpoint
      queryParams,
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Cookie': 'sid=${user.sid}',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        // Expecting 'data' key from custom method response
        if (jsonResponse['message'] != null && jsonResponse['message'].isNotEmpty) {
          return (jsonResponse['message'] as List) // <--- Changed to 'message' key
              .map((e) => AttendanceRecord.fromJson(e))
              .toList();
        }
        return []; // Return empty list if no data
      } else {
        throw Exception('Failed to fetch attendance records: ${response.statusCode}');
      }
    } catch (e) {
      ApiAttendanceHelper.logErrorToFrappe('Error fetching attendance records: $e', 'Flutter Attendance Error');
      throw Exception('An error occurred while fetching records: $e');
    }
  }

  static Future<void> logErrorToFrappe(String message, String title) async {
    final User? user = await SessionManager.getSessionData();
    if (user == null) {
      // Cannot log to Frappe if user is not logged in
      return;
    }

    const String url = '${ApiNetwork.baseUrl}/api/method/frappe.utils.error.log';
    final Map<String, dynamic> body = {
      'message': message,
      'title': title,
    };

    try {
      await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'sid=${user.sid}',
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      // If logging fails, just print to console, don't throw further
      print('Failed to log error to Frappe: $e');
    }
  }
}
                  