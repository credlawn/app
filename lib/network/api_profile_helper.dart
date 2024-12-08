import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';
import 'package:credlawn/network/api_network.dart';

Future<ProfileModel> fetchProfileData(String userId, String sid) async {
  final filters = '{"email": "$userId"}';  
  final fields = '["name", "employee_name", "joining_date", "employee_code", "date_of_birth", "gender", "department", "designation", "mobile_no", "email", "age", "tenure"]';  

  final url = '${ApiNetwork.fetchProfile}?filters=${Uri.encodeQueryComponent(filters)}&fields=${Uri.encodeQueryComponent(fields)}';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Cookie': 'sid=$sid'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
        final profileData = jsonResponse['data'][0];

        return ProfileModel.fromJson(profileData);
      }
    }
  } catch (e) {
    return Future.error('');
  }

  return Future.error('');
}
