import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/models/follow_up_model.dart';
import 'package:credlawn/network/api_network.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';

Future<List<FollowUp>> getFollowUps() async {
  final User? user = await SessionManager.getSessionData();
  String? sid = user?.sid;
  String? userId = user?.userId;

  if (sid == null || userId == null) {
    return [];
  }

  try {
    final response = await http.post(
      Uri.parse(ApiNetwork.getFollowUps),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid',
      },
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['message'] != null && jsonResponse['message']['success'] == true) {
        final List<dynamic> followUpsJson = jsonResponse['message']['follow_ups'];
        return followUpsJson.map((json) => FollowUp.fromJson(json)).toList();
      } else {
        return [];
      }
    } else {
      return [];
    }
  } catch (e) {
    print('An error occurred while fetching follow-ups: $e');
    return [];
  }
}
