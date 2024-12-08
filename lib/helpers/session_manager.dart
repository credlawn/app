import 'package:shared_preferences/shared_preferences.dart';
import 'package:credlawn/models/user.dart';

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
  }) async {
    final prefs = await SharedPreferences.getInstance();
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
    );

    await prefs.setString(_userKey, user.toJson());
  }

  static Future<User?> getSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson != null) {
      return User.fromJson(userJson); 
    } else {
      return null; 
    }
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  static Future<void> logout() async {
    await clearSession();  
  }
}
