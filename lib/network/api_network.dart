class ApiNetwork {

  static const String baseUrl = 'https://cipl.me/';


  static const String login = '${baseUrl}api/method/login';

  static const String fetchProfile = '${baseUrl}api/resource/Employee';

  static const String newCardLogin = '${baseUrl}api/resource/Case Punching';

  static const String fetchCardLoginData = '${baseUrl}api/resource/Case Punching';

  static const String fetchCallingData = '${baseUrl}api/resource/Calling Data';

  static const String updateLeadStatus = '${baseUrl}api/resource/Calling Data';

  static const String fetchAdobeDumpData = '${baseUrl}api/resource/Adobe Database';
  static const String saveFcmToken = '${baseUrl}api/method/credlawn.api.save_fcm_token.save_fcm_token';
  static const String getDailyAttendanceSummary = '${baseUrl}api/method/credlawn.api.attendance.get_daily_attendance_summary';
  static const String getEmployeeLeads = '${baseUrl}api/method/credlawn.api.calling_data.get_employee_leads';

  static const String addRawCallLogEntry = '${baseUrl}api/method/credlawn.api.raw_call_log.add_raw_call_log_entry';
  static const String addSyncRecord = '${baseUrl}api/method/credlawn.api.raw_call_log.add_sync_record';
  static const String getCustomerDetails = '${baseUrl}api/method/credlawn.api.customer_detail.get_customer_details';
  static const String getLoginLinks = '${baseUrl}api/method/credlawn.api.login_link.get_login_links';
  static const String logAppError = '${baseUrl}api/method/credlawn.api.log_app_error.log_error_from_app';
  static const String saveCustomerFeedback = '${baseUrl}api/method/credlawn.api.save_feedback.save_customer_feedback';
  static const String getFcmLogs = '${baseUrl}api/method/credlawn.api.get_fcm_logs.get_user_fcm_logs';
  static const String getFollowUps = '${baseUrl}api/method/credlawn.api.get_follow_ups.get_follow_ups';
  static const String deleteFollowUp = '${baseUrl}api/method/credlawn.api.delete_follow_up.delete_follow_up';
  static const String getUpcomingFollowUpsCount = '${baseUrl}api/method/credlawn.api.get_follow_ups.get_upcoming_follow_ups_count';


  

}
