import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/network/api_network.dart';
import 'package:credlawn/helpers/session_manager.dart'; // Assuming session manager is needed for SID
import 'package:credlawn/models/user.dart'; // Import User model
import 'package:credlawn/models/feedback_model.dart'; // Import FeedbackModel

Future<bool> saveCustomerFeedback(FeedbackModel feedback) async {
  final Map<String, dynamic> body = {
    'mobile_no': feedback.mobileNo ?? feedback.leadFrappeId, // Use mobileNo if available, otherwise use leadFrappeId
    'remarks': feedback.remarks,
    'status': feedback.status,
    'reference_no': feedback.arnNo,
    'user': feedback.userId,
    'customer_name': feedback.customerName, // Add customer name to the API request
  };

  if (feedback.followUpDate != null) {
    body['follow_up_date'] = feedback.followUpDate;
  }

  if (feedback.followUpTime != null) {
    body['follow_up_time'] = feedback.followUpTime;
  }

  try {
    final response = await http.post(
      Uri.parse(ApiNetwork.saveCustomerFeedback),
      headers: await SessionManager.getAuthHeaders(),
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
