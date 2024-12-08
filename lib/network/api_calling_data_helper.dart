import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/calling_data_model.dart';  
import 'package:credlawn/network/api_network.dart';

// Fetch Normal Calling Data
Future<List<CallingDataModel>> fetchNormalCallingData(String userId, String sid) async {
  final filters = '[["email", "=", "$userId"], ["data_type", "=", "Normal Leads"], ["data_status", "=", "New"]]';
  final fields = '["name", "customer_name", "mobile_no", "data_status", "data_type", "employee_name", "email", "remarks", "lead_status"]';
  final orderBy = 'creation asc';

  final url = '${ApiNetwork.fetchCallingData}?order_by=${Uri.encodeQueryComponent(orderBy)}&filters=${Uri.encodeQueryComponent(filters)}&fields=${Uri.encodeQueryComponent(fields)}';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Cookie': 'sid=$sid'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
        return (jsonResponse['data'] as List)
            .map((item) => CallingDataModel.fromJson(item)) // Using the same CallingDataModel
            .toList();
      }
    }
  } catch (e) {
    return Future.error('Failed to load data');
  }

  return Future.error('No data available');
}

// Fetch Interested Calling Data
Future<List<CallingDataModel>> fetchInterestedCallingData(String userId, String sid) async {
  final filters = '[["email", "=", "$userId"], ["data_type", "=", "Interested Leads"], ["data_status", "=", "New"]]';
  final fields = '["name", "customer_name", "mobile_no", "data_status", "data_type", "employee_name", "email", "remarks", "lead_status"]';
  final orderBy = 'creation asc';

  final url = '${ApiNetwork.fetchCallingData}?order_by=${Uri.encodeQueryComponent(orderBy)}&filters=${Uri.encodeQueryComponent(filters)}&fields=${Uri.encodeQueryComponent(fields)}';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Cookie': 'sid=$sid'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
        return (jsonResponse['data'] as List)
            .map((item) => CallingDataModel.fromJson(item)) // Using the same CallingDataModel
            .toList();
      }
    }
  } catch (e) {
    return Future.error('Failed to load data');
  }

  return Future.error('No data available');
}

// Fetch Pre-Approved Calling Data
Future<List<CallingDataModel>> fetchPreApprovedCallingData(String userId, String sid) async {
  final filters = '[["email", "=", "$userId"], ["data_type", "=", "Pre Approved Leads"], ["data_status", "=", "New"]]';
  final fields = '["name", "customer_name", "mobile_no", "data_status", "data_type", "employee_name", "email", "remarks", "lead_status"]';
  final orderBy = 'creation asc';

  final url = '${ApiNetwork.fetchCallingData}?order_by=${Uri.encodeQueryComponent(orderBy)}&filters=${Uri.encodeQueryComponent(filters)}&fields=${Uri.encodeQueryComponent(fields)}';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Cookie': 'sid=$sid'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
        return (jsonResponse['data'] as List)
            .map((item) => CallingDataModel.fromJson(item)) // Using the same CallingDataModel
            .toList();
      }
    }
  } catch (e) {
    return Future.error('Failed to load data');
  }

  return Future.error('No data available');
}
