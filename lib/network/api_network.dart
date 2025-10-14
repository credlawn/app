class ApiNetwork {

  static const String baseUrl = 'https://cipl.me/';


  static const String login = '${baseUrl}api/method/login';

  static const String fetchProfile = '${baseUrl}api/resource/Employee';

  static const String newCardLogin = '${baseUrl}api/resource/Case Punching';

  static const String fetchCardLoginData = '${baseUrl}api/resource/Case Punching';

  static const String fetchCallingData = '${baseUrl}api/resource/Calling Data';

  static const String updateLeadStatus = '${baseUrl}api/resource/Calling Data';

  static const String fetchAdobeDumpData = '${baseUrl}api/resource/Adobe Database';
  static const String getDailyAttendanceSummary = '${baseUrl}api/method/credlawn.api.attendance.get_daily_attendance_summary';
  static const String getPreApprovedLeads = '${baseUrl}api/method/credlawn.api.calling_data.get_pre_approved_leads';

  static const String addRawCallLogEntry = '${baseUrl}api/method/credlawn.api.raw_call_log.add_raw_call_log_entry';
  static const String addSyncRecord = '${baseUrl}api/method/credlawn.api.raw_call_log.add_sync_record';

  

}
