import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/models/user.dart';
import 'package:credlawn/models/login_result.dart';
import 'package:credlawn/api/server_api.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/network/api_profile_helper.dart';
import 'package:credlawn/helpers/error_logger.dart';

Future<LoginResult> apiLoginHelper(Map<String, dynamic> jsonResponse, String? cookies) async {
  
  final sid = _extractCookieValue(cookies, 'sid');
  if (sid.isEmpty) {
    return LoginResult.error(LoginErrorType.invalidCredentials, 'Invalid credentials');
  }

  
  final userId = Uri.decodeComponent(_extractCookieValue(cookies, 'user_id') ?? '');
  final fullName = jsonResponse['full_name'] ?? '';
  final userImage = ServerApi.baseUrl + (_extractCookieValue(cookies, 'user_image') ?? '');

  var user = User(
    sid: sid,
    fullName: fullName,
    userId: userId,
    userImage: userImage,
  );

  
  Map<String, dynamic> apiKeys;
  try {
    apiKeys = await fetchApiKeys(sid);
    user = user.copyWith(
      apiKey: apiKeys['api_key'],
      apiSecret: apiKeys['api_secret'],
    );
  } catch (e) {
    await ErrorLogger.logException(
      context: 'fetchApiKeys in apiLoginHelper',
      exception: e,
      userId: user.userId,
    );
    return LoginResult.error(LoginErrorType.unauthorizedAccess, 'Unauthorized access error');
  }

  
  try {
    
    final profileData = await fetchProfileDataWithKeys(userId, apiKeys['api_key']!, apiKeys['api_secret']!);
    user = user.copyWith(
      employeeName: profileData['employee_name'] ?? '',
      employeeCode: profileData['employee_code']?.toString() ?? '',
      joiningDate: profileData['joining_date'] ?? '',
      dateOfBirth: profileData['date_of_birth'] ?? '',
      gender: profileData['gender'] ?? '',
      department: profileData['department'] ?? '',
      designation: profileData['designation'] ?? '',
      mobileNo: profileData['mobile_no'] ?? '',
      email: profileData['email'] ?? '',
      age: profileData['age'] ?? '',
      tenure: profileData['tenure'] ?? '',
      role: profileData['role'] ?? '',
    );
  } catch (e) {
    await ErrorLogger.logException(
      context: 'validateApiKeys in apiLoginHelper',
      exception: e,
      userId: user.userId,
    );
    return LoginResult.error(LoginErrorType.permissionDenied, 'API key validation failed - please contact administrator');
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
    apiKey: user.apiKey,
    apiSecret: user.apiSecret,
  );

  return LoginResult.success(user);
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
}) async {
  final body = {
    'fcm_token': token,
    'device_id': deviceId,
  };

  if (userId != null) {
    body['user'] = userId;
  }

  try {
    final response = await http.post(
      ServerApi.saveFcmToken,
      headers: await SessionManager.getAuthHeaders(),
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

Future<Map<String, dynamic>> fetchApiKeys(String sid) async {
  try {
    final response = await http.get(
      ServerApi.getApiKeys,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['message'] != null) {
        final message = jsonResponse['message'] as Map<String, dynamic>;
        return {
          'api_key': message['api_key'] ?? '',
          'api_secret': message['api_secret'] ?? '',
          'profile': message['profile'] ?? {},
        };
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to fetch API keys: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching API keys: $e');
  }
}

Future<Map<String, dynamic>> fetchProfileDataWithKeys(String userId, String apiKey, String apiSecret) async {
  try {
    final response = await http.get(ServerApi.getUserProfile, headers: {
      'Authorization': 'token $apiKey:$apiSecret',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['message'] != null && jsonResponse['message']['data'] != null && jsonResponse['message']['data'].isNotEmpty) {
        final profileData = jsonResponse['message']['data'] as Map<String, dynamic>;
        return profileData;
      } else {
        throw Exception('No profile data found for user');
      }
    } else {
      throw Exception('API key validation failed: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('API key validation error: $e');
  }
}

Future<dynamic> fetchProfileWithToken(String userId, String apiKey, String apiSecret) async {
  try {
    final response = await http.get(
      Uri.parse('${ServerApi.baseUrl}api/resource/Employee/$userId'),
      headers: {
        'Authorization': 'token $apiKey:$apiSecret',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['data'];
    } else {
      throw Exception('Failed to fetch profile with token: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching profile with token: $e');
  }
}
