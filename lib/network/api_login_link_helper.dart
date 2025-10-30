import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/network/api_network.dart';
import 'package:credlawn/models/login_link_model.dart';
import 'package:credlawn/helpers/session_manager.dart'; // Assuming session manager is needed for SID
import 'package:credlawn/models/user.dart'; // Import User model

Future<List<LoginLinkModel>> fetchLoginLinks() async {
  final User? user = await SessionManager.getSessionData();
  if (user == null) {
    throw Exception('User not logged in.');
  }
  final String sid = user.sid;

  final Uri uri = Uri.https(
    Uri.parse(ApiNetwork.baseUrl).host,
    Uri.parse(ApiNetwork.getLoginLinks).path,
  );

  try {
    final response = await http.get(
      uri,
      headers: {'Cookie': 'sid=$sid'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse is List) { // Check if jsonResponse is a List directly
        return (jsonResponse as List)
            .map((item) => LoginLinkModel.fromJson(item))
            .toList();
      } else if (jsonResponse['message'] is List) { // Fallback for wrapped response
        return (jsonResponse['message'] as List)
            .map((item) => LoginLinkModel.fromJson(item))
            .toList();
      }
      else {
        throw Exception('Invalid response format for login links: Not a List or wrapped List.');
      }
    } else {
      throw Exception('Failed to load login links: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('An error occurred while fetching login links: $e');
  }
}