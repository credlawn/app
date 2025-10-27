import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/network/api_network.dart';
import 'package:credlawn/helpers/session_manager.dart'; // Assuming session manager is needed for SID
import 'package:credlawn/models/user.dart'; // Import User model

Future<bool> saveCustomerFeedback({
  required String mobileNo,
  required String remarks,
  String? status,
  String? referenceNo,
  required String userId,
  String? followUpDate,
  String? followUpTime,
}) async {
  final User? user = await SessionManager.getSessionData();
  String? sid = user?.sid;

  if (sid == null) {
    return false;
  }

  final Map<String, dynamic> body = {
    'mobile_no': mobileNo,
    'remarks': remarks,
    'status': status,
    'reference_no': referenceNo,
    'user': userId,
  };

  if (followUpDate != null) {
    body['follow_up_date'] = followUpDate;
  }

  if (followUpTime != null) {
    body['follow_up_time'] = followUpTime;
  }

  try {
    final response = await http.post(
      Uri.parse(ApiNetwork.saveCustomerFeedback),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      // Frappe nests the method's return value in a 'message' key.
      if (jsonResponse['message'] != null && jsonResponse['message']['success'] == true) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } catch (e) {
    print('An error occurred while saving feedback: $e');
    return false;
  }
}