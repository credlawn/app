import 'package:shared_preferences/shared_preferences.dart';

class AppStateManager {
  static const String _pendingFeedbackKey = 'pending_feedback_mobile_no';

  static Future<void> setPendingFeedbackMobile(String mobileNo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingFeedbackKey, mobileNo);
  }

  static Future<String?> getPendingFeedbackMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingFeedbackKey);
  }

  static Future<void> clearPendingFeedbackMobile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingFeedbackKey);
  }
}
