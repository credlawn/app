import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/models/user.dart';
import 'package:credlawn/network/api_network.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/network/api_profile_helper.dart';

Future<User?> apiLoginHelper(Map<String, dynamic> jsonResponse, String? cookies) async {
  var user = User(
    sid: _extractCookieValue(cookies, 'sid'),
    fullName: jsonResponse['full_name'] ?? '',
    userId: Uri.decodeComponent(_extractCookieValue(cookies, 'user_id') ?? ''),
    userImage: ApiNetwork.baseUrl + (_extractCookieValue(cookies, 'user_image') ?? ''),
  );

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
  var url = Uri.parse(ApiNetwork.saveFcmToken);

  var body = {
    'fcm_token': token,
    'device_id': deviceId,
  };

  if (userId != null) {
    body['user'] = userId;
  }

  var headers = {
    "Content-Type": "application/json",
  };

  if (sid != null) {
    headers["Cookie"] = 'sid=$sid';
  }

  try {
    var response = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );

  } catch (e) {
  }
}
