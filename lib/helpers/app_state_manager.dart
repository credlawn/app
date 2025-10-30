import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AppStateManager {
  static const String _pendingFeedbackKey = 'pending_feedback_mobile_no';

  static final ValueNotifier<bool> _dirtyLeadNotifier = ValueNotifier<bool>(false);

  static ValueNotifier<bool> get dirtyLeadNotifier => _dirtyLeadNotifier;

  static void notifyLeadDirty() {
    _dirtyLeadNotifier.value = true;
  }

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
