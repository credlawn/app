import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/network/api_network.dart';
import 'package:credlawn/helpers/session_manager.dart'; // Assuming session manager is needed for SID
import 'package:credlawn/models/user.dart'; // Import User model

Future<void> logAppError({
  required String errorMessage,
  String? errorContext,
}) async {
  final User? user = await SessionManager.getSessionData();
  String? userId = user?.userId;
  String? sid = user?.sid;

  if (sid == null) {
    // If no session, log to console and return
    // print('Error logging to backend: No user session. Error: $errorMessage, Context: $errorContext'); // Removed print
    return;
  }

  final Map<String, dynamic> body = {
    'error_message': errorMessage,
    'error_context': errorContext,
    'user_id': userId,
  };

  try {
    final response = await http.post(
      Uri.parse(ApiNetwork.logAppError),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        // print('Error logged to Frappe successfully.'); // Removed print
      } else {
        // print('Failed to log error to Frappe: ${jsonResponse['error']}'); // Removed print
      }
    } else {
      // print('Failed to log error to Frappe: ${response.statusCode}'); // Removed print
    }
  } catch (e) {
    // print('An error occurred while sending error to Frappe: $e'); // Removed print
  }
}