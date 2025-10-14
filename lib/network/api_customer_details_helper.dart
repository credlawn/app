import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:credlawn/network/api_network.dart';
import 'package:credlawn/models/customer_details_model.dart';
import 'package:credlawn/helpers/session_manager.dart'; // Assuming session manager is needed for SID
import 'package:credlawn/models/user.dart'; // Import User model

Future<CustomerDetailsModel> fetchCustomerDetails(String mobileNo) async {
  final User? user = await SessionManager.getSessionData();
  if (user == null) {
    throw Exception('User not logged in.');
  }
  final String sid = user.sid;

  final Map<String, dynamic> queryParams = {
    'mobile_no': mobileNo,
  };

  final Uri uri = Uri.http(
    Uri.parse(ApiNetwork.baseUrl).host,
    Uri.parse(ApiNetwork.getCustomerDetails).path,
    queryParams,
  );

  try {
    final response = await http.get(
      uri,
      headers: {'Cookie': 'sid=$sid'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['message'] != null && jsonResponse['message']['status'] != 'not_found') {
        return CustomerDetailsModel.fromJson(jsonResponse['message']);
      } else {
        throw Exception(jsonResponse['message']['message'] ?? 'Customer details not found.');
      }
    } else {
      throw Exception('Failed to load customer details: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('An error occurred while fetching customer details: $e');
  }
}