import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/models/leads_model.dart';
import 'package:credlawn/network/api_network.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';

Future<List<LeadsModel>> fetchEmployeeLeadsFromApi(String userId, String sid) async {
  final Map<String, dynamic> queryParams = {
    'user_id': userId,
  };

  final Uri uri = Uri.http(
    Uri.parse(ApiNetwork.baseUrl).host,
    'api/method/credlawn.mobile.api.leads.get_employee_leads',
    queryParams,
  );




  try {
    final response = await http.get(
      uri,
      headers: {'Cookie': 'sid=$sid'},
    );




    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['message'] != null && jsonResponse['message'].isNotEmpty) {
        final List<LeadsModel> leads = (jsonResponse['message'] as List)
            .map((item) => LeadsModel.fromJson(item))
            .toList();

        return leads;

      } else {
        return Future.error('API Response message is empty or null.');
      }
    } else {
      return Future.error('Failed to load leads from API: ${response.statusCode}');
    }
  } catch (e) {
    return Future.error('Exception during API fetch: $e');
  }

  return Future.error('No leads available from API');
}

Future<bool> syncLeadUpdateToServer(LeadsModel lead, String sid) async {
  final User? user = await SessionManager.getSessionData();
  String? csrfToken = user?.csrfToken;

  if (csrfToken == null) {

    return false;
  }

  final Uri uri = Uri.http(
    Uri.parse(ApiNetwork.baseUrl).host,
    'api/method/credlawn.mobile.api.leads.update_lead_status_and_details',
  );

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid',
        'X-Frappe-CSRF-Token': csrfToken,
      },
      body: json.encode({
        'frappe_id': lead.frappeId,
        'lead_status': lead.leadStatus,
        'remarks': lead.remarks,
        'arn_no': lead.arnNo,
        'attempted_calls': lead.attemptedCalls,
        'connected_calls': lead.connectedCalls,
        'total_duration': lead.totalDuration,
        'allocation_status': lead.allocationStatus,
        'last_synced_at': lead.lastSyncedAt,
        'follow_up_date': lead.followUpDate,
        'follow_up_time': lead.followUpTime,
      }),
    );

    if (response.statusCode == 200) {

      final Map<String, dynamic> jsonResponse = json.decode(response.body);


      return jsonResponse['message']?['status'] == 'success';
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
}

Future<bool> markLeadInactiveOnServer(String frappeId, String sid) async {
  final User? user = await SessionManager.getSessionData();
  String? csrfToken = user?.csrfToken;

  if (csrfToken == null) {

    return false;
  }

  final Uri uri = Uri.http(
    Uri.parse(ApiNetwork.baseUrl).host,
    'api/method/credlawn.api.leads.mark_lead_inactive_on_server',
  );

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid',
        'X-Frappe-CSRF-Token': csrfToken,
      },
      body: json.encode({
        'frappe_id': frappeId,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse['status'] == 'success';
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
}
