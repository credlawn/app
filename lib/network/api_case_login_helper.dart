import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/models/case_login_model.dart';
import 'package:credlawn/network/api_network.dart';

Future<Map<String, dynamic>> submitCaseLoginToServer(
  String customerName,
  String mobileNo,
  String loginDate,
  String ipStatus,
  String arnNo,
  String remarks,
  String user,
  String sid,
) async {
  final Uri uri = Uri.https(
    Uri.parse(ApiNetwork.baseUrl).host,
    'api/method/credlawn.mobile.api.case_login.submit_case_login', // Assuming this is the server endpoint
  );

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid',
      },
      body: json.encode({
        'customer_name': customerName,
        'mobile_no': mobileNo,
        'login_date': loginDate,
        'ip_status': ipStatus,
        'arn_no': arnNo,
        'remarks': remarks,
        'user': user,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse; // Return the full response from the server
    } else {
      // Log or handle server error
      print('Server error submitting case login: ${response.statusCode} - ${response.body}');
      return {"status": "error", "message": "Server error: ${response.statusCode}"};
    }
  } catch (e) {
    // Log or handle network/other exceptions
    print('Exception submitting case login: $e');
    return {"status": "error", "message": "Exception: $e"};
  }
}