import 'dart:convert';
import 'dart:math';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/helpers/error_logger.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/models/geofence_config.dart';
import 'package:credlawn/models/attendance_record_model.dart';
import 'package:credlawn/models/today_attendance_status.dart';
import 'package:credlawn/api/server_api.dart';
import 'package:http/http.dart' as http;
class ApiAttendanceHelper {
  static Future<String> markAttendance({
    required String logType,
    required double latitude,
    required double longitude,

  }) async {
    final User? user = await SessionManager.getSessionData();
    if (user == null) {
      throw Exception('User not logged in');
    }
    final Map<String, dynamic> body = {
      'user': user.userId,
      'log_type': logType,
      'latitude': latitude,
      'longitude': longitude,

    };
    final Uri url = ServerApi.attendanceRecords;
    try {
      final response = await http.post(
        url,
        headers: await SessionManager.getAuthHeaders(),
        body: jsonEncode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['data']['name'];
      } else {
        ErrorLogger.logApiError(
          endpoint: url.toString(),
          method: 'POST',
          statusCode: response.statusCode,
          responseBody: response.body,
          userId: user.userId,
        );
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['exception'] ?? 'Failed to create attendance record');
      }
    } catch (e) {
      ErrorLogger.logException(
        context: 'markAttendance',
        exception: e,
        userId: user.userId,
      );
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
    final random = Random().nextInt(900000) + 100000;
    final extension = imagePath.substring(imagePath.lastIndexOf('.'));
    final newFilename = '$random$extension';
    final request = http.MultipartRequest(
      'POST',
      ServerApi.uploadFile,
    );
    request.headers.addAll(await SessionManager.getAuthHeaders());
    request.fields['doctype'] = 'Attendance Records';
    request.fields['docname'] = docname;
    request.fields['fieldname'] = 'atn_image';
    request.fields['is_private'] = '1';
    request.fields['optimize'] = '1';
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
        return responseData['message']['file_url'];
      } else {
        ErrorLogger.logApiError(
          endpoint: ServerApi.uploadFile.toString(),
          method: 'POST',
          statusCode: response.statusCode,
          responseBody: responseBody,
          userId: user.userId,
        );
        final errorData = jsonDecode(responseBody);
        throw Exception(errorData['exception'] ?? 'Failed to upload image');
      }
    } catch (e) {
      ErrorLogger.logException(
        context: 'uploadImage',
        exception: e,
        userId: user.userId,
      );
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
    final url = '${ServerApi.baseUrl}/api/resource/Attendance Records/$docname';
    final body = {'atn_image': filePath};
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: await SessionManager.getAuthHeaders(),
        body: jsonEncode(body),
      );
      if (response.statusCode != 200) {
        ErrorLogger.logApiError(
          endpoint: url,
          method: 'PUT',
          statusCode: response.statusCode,
          responseBody: response.body,
          userId: user.userId,
        );
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['exception'] ?? 'Failed to update image path');
      }
    } catch (e) {
      ErrorLogger.logException(
        context: 'updateImagePath',
        exception: e,
        userId: user.userId,
      );
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
      
      final List<AttendanceRecord> todaySummary = await getAttendanceRecords(fromDate: date, toDate: date);
      bool hasCheckedIn = false;
      bool hasCheckedOut = false;
      String? lastLogType; 
      if (todaySummary.isNotEmpty) {
        final record = todaySummary.first;
        if (record.inTime != null && record.inTime != 'N/A') {
          hasCheckedIn = true;
        }
        if (record.outTime != null && record.outTime != 'N/A') {
          hasCheckedOut = true;
        }
        
        if (hasCheckedIn && hasCheckedOut) {
          
          
          
          
          lastLogType = 'Out'; 
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
      ErrorLogger.logException(
        context: 'getLastAttendanceForToday',
        exception: e,
        userId: user.userId,
      );
      return TodayAttendanceStatus();
    }
  }
  static Future<GeofenceConfig?> fetchActiveGeofence() async {
        final User? user = await SessionManager.getSessionData();
        if (user == null) {
          throw Exception('User not logged in');
        }

        final String filters = '[["is_active","=",1]]';
        final String fields = '["location_name", "latitude", "longitude", "radius", "office_start_time", "office_end_time"]';
        final Map<String, dynamic> queryParams = {
          'fields': fields,
          'filters': filters,
        };
        final Uri uri = ServerApi.attendanceGeofence.replace(queryParameters: queryParams);

        try {
          final response = await http.get(
            uri,
            headers: await SessionManager.getAuthHeaders(),
          );
    
                if (response.statusCode == 200) {
                  final jsonResponse = json.decode(response.body);
                  if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
                    return GeofenceConfig.fromJson(jsonResponse['data'][0]);
                  }
                          return null;
                        } else {
                          ErrorLogger.logApiError(
                            endpoint: uri.toString(),
                            method: 'GET',
                            statusCode: response.statusCode,
                            responseBody: response.body,
                            userId: user.userId,
                          );
                          throw Exception('Failed to fetch active geofence');
                        }
                      } catch (e) {
                        ErrorLogger.logException(
                          context: 'fetchActiveGeofence',
                          exception: e,
                          userId: user.userId,
                        );
                        throw Exception('An error occurred while fetching geofence: $e');
                      }
                    }
  static Future<List<AttendanceRecord>> getAttendanceRecords({
    String? fromDate,
    String? toDate,
    int? limit,
    int? offset,
  }) async {
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

    // Add pagination parameters if provided
    if (limit != null) {
      queryParams['limit'] = limit.toString();
    }
    if (offset != null) {
      queryParams['offset'] = offset.toString();
    }

    final Uri uri = ServerApi.getDailyAttendanceSummary.replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: await SessionManager.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['message'] != null && jsonResponse['message'].isNotEmpty) {
          return (jsonResponse['message'] as List)
              .map((e) => AttendanceRecord.fromJson(e))
              .toList();
        }
        return [];
      } else {
        ErrorLogger.logApiError(
          endpoint: uri.toString(),
          method: 'GET',
          statusCode: response.statusCode,
          responseBody: response.body,
          userId: user.userId,
        );
        throw Exception('Failed to fetch attendance records: ${response.statusCode}');
      }
    } catch (e) {
      ErrorLogger.logException(
        context: 'getAttendanceRecords',
        exception: e,
        userId: user.userId,
      );
      throw Exception('An error occurred while fetching records: $e');
    }
  }
}
