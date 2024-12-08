import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/card_login_list_model.dart';  
import 'package:credlawn/network/api_network.dart';

Future<List<CardLoginListModel>> fetchCardLoginData(String userId, String sid) async {
  final filters = '{"email": "$userId"}'; 
  final fields = '["name", "customer_name", "mobile_no", "punching_date", "ip_status", "pan_no", "kyc_status", "incomplete_reason", "employee_name", "reference_no"]';
  final orderBy = 'creation desc';

  final url = '${ApiNetwork.fetchCardLoginData}?order_by=${Uri.encodeQueryComponent(orderBy)}&filters=${Uri.encodeQueryComponent(filters)}&fields=${Uri.encodeQueryComponent(fields)}';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Cookie': 'sid=$sid'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
        return (jsonResponse['data'] as List)
            .map((item) => CardLoginListModel.fromJson(item))
            .toList();
      }
    }
  } catch (e) {
    return Future.error('Failed to load data');
  }

  return Future.error('No data available');
}
