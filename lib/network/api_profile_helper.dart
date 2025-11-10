import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';
import 'package:credlawn/api/server_api.dart';
import 'package:credlawn/helpers/session_manager.dart';

Future<ProfileModel> fetchProfileData(String userId, String sid) async {
  try {
    final headers = await SessionManager.getAuthHeaders();
    final response = await http.get(ServerApi.getUserProfile, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
        final profileData = jsonResponse['data'];
        return ProfileModel.fromJson(profileData);
      }
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      await SessionManager.clearSession();
      throw Exception('Authentication failed - please login again');
    }
  } catch (e) {
    if (e.toString().contains('No valid API credentials found')) {
      await SessionManager.clearSession();
      throw Exception('Please login to continue');
    }
    return Future.error('');
  }

  return Future.error('');
}
