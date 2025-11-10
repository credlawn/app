import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/api/server_api.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';

Future<Map<String, dynamic>?> getManagerDashboardData() async {
  try {
    final headers = await SessionManager.getAuthHeaders();
    final response = await http.get(
      ServerApi.getManagerDashboardData,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['message'] != null) {
        return jsonResponse['message'];
      } else {
        return null;
      }
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      await SessionManager.clearSession();
      throw Exception('Authentication failed - please login again');
    } else {
      return null;
    }
  } catch (e) {
    if (e.toString().contains('No valid API credentials found')) {
      await SessionManager.clearSession();
      throw Exception('Please login to continue');
    } else if (e.toString().contains('Authentication failed')) {
      throw e;
    }
    return null;
  }
}
