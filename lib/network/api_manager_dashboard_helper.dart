import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/api/server_api.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';

Future<Map<String, dynamic>?> getManagerDashboardData() async {
  final User? user = await SessionManager.getSessionData();
  String? sid = user?.sid;

  if (sid == null) {
    return null;
  }

  try {
    final response = await http.get(
      ServerApi.getManagerDashboardData,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['message'] != null) {
        return jsonResponse['message'];
      } else {
        return null;
      }
    } else {
      return null;
    }
  } catch (e) {
    print('An error occurred while fetching manager dashboard data: $e');
    return null;
  }
}
