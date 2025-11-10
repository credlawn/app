import 'package:shared_preferences/shared_preferences.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/helpers/error_logger.dart';

class SessionManager {
  static const String _userKey = 'user_session';

  static Future<void> saveSessionData({
    required String sid,
    required String fullName,
    required String userId,
    required String userImage,
    required String employeeName,
    required String employeeCode,
    required String joiningDate,
    required String dateOfBirth,
    required String gender,
    required String department,
    required String designation,
    required String mobileNo,
    required String email,
    required String age,
    required String tenure,
    required String role,
    String? apiKey,
    String? apiSecret,
  }) async {
    final user = User(
      sid: sid,
      fullName: fullName,
      userId: userId,
      userImage: userImage,
      employeeName: employeeName,
      employeeCode: employeeCode,
      joiningDate: joiningDate,
      dateOfBirth: dateOfBirth,
      gender: gender,
      department: department,
      designation: designation,
      mobileNo: mobileNo,
      email: email,
      age: age,
      tenure: tenure,
      role: role,
      apiKey: apiKey,
      apiSecret: apiSecret,
    );

    final prefs = await SharedPreferences.getInstance();
    final userJson = user.toJson();
    await prefs.setString(_userKey, userJson);

    await ErrorLogger.logError(
      title: 'User Login Successful',
      errorMessage: 'User logged in with details: SID=${user.sid}, UserID=${user.userId}, Name=${user.fullName}',
      errorType: 'Login',
      userId: user.userId,
    );
  }

  static Future<User?> getSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(userJson);
    }
    return null;
  }

  static Future<String?> getValidSid() async {
    final user = await getSessionData();
    if (user?.sid == null || user!.sid.isEmpty) {
      await ErrorLogger.logError(
        title: 'Invalid Session',
        errorMessage: 'Session SID is null or empty',
        errorType: 'Auth',
        userId: user?.userId,
      );
      return null;
    }
    return user.sid;
  }

  static Future<bool> isSessionValid() async {
    final user = await getSessionData();
    return user?.sid != null && user!.sid.isNotEmpty;
  }

  static Future<void> refreshSessionIfNeeded() async {
    final isValid = await isSessionValid();
    if (!isValid) {
      await ErrorLogger.logError(
        title: 'Session Refresh Needed',
        errorMessage: 'Session is invalid, user may need to re-login',
        errorType: 'Auth',
      );
    }
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  static Future<void> logout() async {
    final user = await getSessionData();
    final userDetails = user != null
        ? 'SID=${user.sid}, UserID=${user.userId}, Name=${user.fullName}'
        : 'No user data found';

    await clearSession();

    await ErrorLogger.logError(
      title: 'User Logout',
      errorMessage: 'User session cleared. Data removed: $userDetails',
      errorType: 'Logout',
      userId: user?.userId,
    );
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final user = await getSessionData();
    if (user?.apiKey != null && user?.apiSecret != null && user!.apiKey!.isNotEmpty && user.apiSecret!.isNotEmpty) {
      return {
        'Authorization': 'token ${user.apiKey}:${user.apiSecret}',
        'Content-Type': 'application/json',
      };
    } else {
      throw Exception('No valid API credentials found. Please login again.');
    }
  }
}
