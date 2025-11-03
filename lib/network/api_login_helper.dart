import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/models/user.dart';
import 'package:credlawn/api/server_api.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/network/api_profile_helper.dart';
import 'package:credlawn/helpers/error_logger.dart';

Future<User?> apiLoginHelper(Map<String, dynamic> jsonResponse, String? cookies) async {
  var user = User(
    sid: _extractCookieValue(cookies, 'sid'),
    fullName: jsonResponse['full_name'] ?? '',
    userId: Uri.decodeComponent(_extractCookieValue(cookies, 'user_id') ?? ''),
    userImage: ServerApi.baseUrl + (_extractCookieValue(cookies, 'user_image') ?? ''),
  );

  try {
    var profileData = await fetchProfileData(user.userId, user.sid);
    user = user.copyWith(
      employeeName: profileData.employeeName ?? '',
      employeeCode: profileData.employeeCode ?? '',
      joiningDate: profileData.joiningDate ?? '',
      dateOfBirth: profileData.dateOfBirth ?? '',
      gender: profileData.gender ?? '',
      department: profileData.department ?? '',
      designation: profileData.designation ?? '',
      mobileNo: profileData.mobileNo ?? '',
      email: profileData.email ?? '',
      age: profileData.age ?? '',
      tenure: profileData.tenure ?? '',
      role: profileData.role ?? '',
    );
  } catch (e) {
    await ErrorLogger.logException(
      context: 'fetchProfileData in apiLoginHelper',
      exception: e,
      userId: user.userId,
    );
  }

  await SessionManager.saveSessionData(
    sid: user.sid,
    fullName: user.fullName,
    userId: user.userId,
    userImage: user.userImage ?? '',
    employeeName: user.employeeName ?? '',
    employeeCode: user.employeeCode ?? '',
    joiningDate: user.joiningDate ?? '',
    dateOfBirth: user.dateOfBirth ?? '',
    gender: user.gender ?? '',
    department: user.department ?? '',
    designation: user.designation ?? '',
    mobileNo: user.mobileNo ?? '',
    email: user.email ?? '',
    age: user.age ?? '',
    tenure: user.tenure ?? '',
    role: user.role ?? '',
  );

  return user;
}

String _extractCookieValue(String? cookies, String cookieName) {
  if (cookies == null) return '';
  final cookieRegex = RegExp('($cookieName=[^;]+)');
  final match = cookieRegex.firstMatch(cookies);
  return match != null ? match.group(0)!.split('=')[1] : '';
}

Future<void> sendFcmTokenToServer({
  required String token,
  required String deviceId,
  String? userId,
  String? sid,
}) async {
  final body = {
    'fcm_token': token,
    'device_id': deviceId,
  };

  if (userId != null) {
    body['user'] = userId;
  }

  final headers = {
    "Content-Type": "application/json",
  };

  if (sid != null) {
    headers["Cookie"] = 'sid=$sid';
  }

  try {
    final response = await http.post(
      ServerApi.saveFcmToken,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      await ErrorLogger.logApiError(
        endpoint: ServerApi.saveFcmToken.toString(),
        method: 'POST',
        statusCode: response.statusCode,
        responseBody: response.body,
        userId: userId,
      );
    }
  } catch (e) {
    await ErrorLogger.logException(
      context: 'sendFcmTokenToServer',
      exception: e,
      userId: userId,
    );
  }
}
