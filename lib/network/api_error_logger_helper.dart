import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/network/server_api.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';

Future<void> logAppError({
  required String errorMessage,
  String? errorContext,
}) async {
  final User? user = await SessionManager.getSessionData();
  String? userId = user?.userId;

  final Map<String, dynamic> body = {
    'error_message': errorMessage,
    'error_context': errorContext,
    'user_id': userId,
  };

  try {
    final response = await http.post(
      Uri.parse(ServerApi.logAppError),
      headers: await SessionManager.getAuthHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
      } else {
      }
    } else {
    }
  } catch (e) {
  }
}
