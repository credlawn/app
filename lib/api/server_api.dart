class ServerApi {
  static const String baseUrl = 'https://cipl.me/';

  // Authentication
  static final Uri login = Uri.parse('${baseUrl}api/method/login');

  // Resources
  static final Uri employee = Uri.parse('${baseUrl}api/resource/Employee');
  static final Uri appErrorLog = Uri.parse('${baseUrl}api/resource/App Error Log');

  // Methods
  static final Uri saveFcmToken = Uri.parse('${baseUrl}api/method/credlawn.api.save_fcm_token.save_fcm_token');
  static final Uri syncFeedback = Uri.parse('${baseUrl}api/method/credlawn.mobile.api.feedback_sync.sync_feedback_data');

  // Leads endpoints
  static Uri getEmployeeLeads([Map<String, dynamic>? queryParams]) {
    return Uri.https(Uri.parse(baseUrl).host, 'api/method/credlawn.mobile.api.leads.get_employee_leads', queryParams);
  }

  static final Uri updateLeadStatus = Uri.parse('${baseUrl}api/method/credlawn.mobile.api.leads.update_lead_status_and_details');
  static final Uri markLeadInactive = Uri.parse('${baseUrl}api/method/credlawn.api.leads.mark_lead_inactive_on_server');

  // External URLs
  static const String whatsAppMessageUrl = '${baseUrl}tata';
}
