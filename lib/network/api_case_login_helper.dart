import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/models/case_login_model.dart';
import 'package:credlawn/network/api_network.dart';
import 'package:credlawn/helpers/session_manager.dart';

Future<Map<String, dynamic>> submitCaseLoginToServer({
  required String customerName,
  required String mobileNo,
  required String loginDate,
  required String ipStatus,
  required String arnNo,
  required String remarks,
  required String user,
  required String syncId,
  String? modified,
}) async {
  final Uri uri = Uri.https(
    Uri.parse(ApiNetwork.baseUrl).host,
    'api/method/credlawn.mobile.api.case_login.submit_case_login',
  );

  try {
  final response = await http.post(
    uri,
    headers: await SessionManager.getAuthHeaders(),
    body: json.encode({
      'customer_name': customerName,
      'mobile_no': mobileNo,
      'login_date': loginDate,
      'ip_status': ipStatus,
      'arn_no': arnNo,
      'remarks': remarks,
      'user': user,
      'sync_id': syncId,
    }),
  );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse; // Return the full response from the server
    } else {
      return {"status": "error", "message": "Server error: ${response.statusCode}"};
    }
  } catch (e) {
    return {"status": "error", "message": "Exception: $e"};
  }
}

Future<Map<String, dynamic>> getUserCaseLoginsFromServer(String userId) async {
  final Uri uri = Uri.https(
    Uri.parse(ApiNetwork.baseUrl).host,
    'api/method/credlawn.mobile.api.case_login.get_user_case_logins',
    {'user_id': userId},
  );

  try {
    final response = await http.get(
      uri,
      headers: await SessionManager.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {"status": "error", "message": "Server error: ${response.statusCode}"};
    }
  } catch (e) {
    return {"status": "error", "message": "Exception: $e"};
  }
}
