import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/card_login_list_model.dart';  
import 'package:credlawn/network/api_network.dart';
import 'package:intl/intl.dart'; 

Future<List<CardLoginListModel>> fetchTodayLoginData(String userId, String sid) async {
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final filters = '[["email", "=", "$userId"], ["punching_date", "=", "$today"]]'; 
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

Future<List<CardLoginListModel>> fetchMonthLoginData(String userId, String sid) async {
  final firstDayOfMonth = DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, 1));
  final lastDayOfMonth = DateFormat('yyyy-MM-dd').format(
      DateTime(DateTime.now().year, DateTime.now().month + 1, 0));
  final filters = '[["email", "=", "$userId"], ["punching_date", ">=", "$firstDayOfMonth"], ["punching_date", "<=", "$lastDayOfMonth"]]'; 
  final fields = '["name", "customer_name", "mobile_no", "punching_date", "ip_status", "pan_no", "kyc_status", "incomplete_reason", "employee_name", "reference_no"]';
  final orderBy = 'creation desc';
  final noLimit = '100';

  final url = '${ApiNetwork.fetchCardLoginData}?order_by=${Uri.encodeQueryComponent(orderBy)}&filters=${Uri.encodeQueryComponent(filters)}&fields=${Uri.encodeQueryComponent(fields)}&limit=${Uri.encodeQueryComponent(noLimit)}';

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