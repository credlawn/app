import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/calling_data_model.dart';
import 'package:credlawn/network/api_network.dart';


// Fetch Normal Calling Data
Future<List<CallingDataModel>> fetchNormalCallingData(String userId, String sid, String? designation) async {
  String filters;
  
  if (designation != null && designation == 'Branch Manager') {
    // For Branch Manager, fetch all leads without email filter
    filters = '[["data_type", "=", "Normal Leads"], ["lead_status", "=", "New Lead"]]';
  } else {
    // For other roles, use the userId to filter leads
    filters = '[["email", "=", "$userId"], ["data_type", "=", "Normal Leads"], ["lead_status", "=", "New Lead"]]';
  }

  final fields = '["name", "customer_name", "mobile_no", "data_status", "data_type", "employee_name", "email", "remarks", "lead_status"]';
  final orderBy = 'creation asc';
  final noLimit = '30';

  final url = '${ApiNetwork.fetchCallingData}?order_by=${Uri.encodeQueryComponent(orderBy)}&filters=${Uri.encodeQueryComponent(filters)}&fields=${Uri.encodeQueryComponent(fields)}&limit=${Uri.encodeQueryComponent(noLimit)}';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Cookie': 'sid=$sid'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
        return (jsonResponse['data'] as List)
            .map((item) => CallingDataModel.fromJson(item)) 
            .toList();
      }
    }
  } catch (e) {
    return Future.error('Failed to load data');
  }

  return Future.error('No data available');
}

// Fetch Interested Calling Data
Future<List<CallingDataModel>> fetchInterestedCallingData(String userId, String sid, String? designation) async {
  String filters;
  
  if (designation != null && designation == 'Branch Manager') {
    filters = '[["data_type", "=", "Interested Leads"], ["lead_status", "=", "New Lead"]]';
  } else {
    filters = '[["email", "=", "$userId"], ["data_type", "=", "Interested Leads"], ["lead_status", "=", "New Lead"]]';
  }

  final fields = '["name", "customer_name", "mobile_no", "data_status", "data_type", "employee_name", "email", "remarks", "lead_status"]';
  final orderBy = 'creation asc';
  final noLimit = '30';

  final url = '${ApiNetwork.fetchCallingData}?order_by=${Uri.encodeQueryComponent(orderBy)}&filters=${Uri.encodeQueryComponent(filters)}&fields=${Uri.encodeQueryComponent(fields)}&limit=${Uri.encodeQueryComponent(noLimit)}';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Cookie': 'sid=$sid'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
        return (jsonResponse['data'] as List)
            .map((item) => CallingDataModel.fromJson(item)) 
            .toList();
      }
    }
  } catch (e) {
    return Future.error('Failed to load data');
  }

  return Future.error('No data available');
}

// Fetch Pre-Approved Calling Data
Future<List<CallingDataModel>> fetchPreApprovedCallingData(String userId, String sid, String? designation) async {
  String filters;
  
  if (designation != null && designation == 'Branch Manager') {
    filters = '[["data_type", "=", "Pre Approved Leads"], ["lead_status", "=", "New Lead"]]';
  } else {
    filters = '[["email", "=", "$userId"], ["data_type", "=", "Pre Approved Leads"], ["lead_status", "=", "New Lead"]]';
  }

  final fields = '["name", "customer_name", "mobile_no", "data_status", "data_type", "employee_name", "email", "remarks", "lead_status"]';
  final orderBy = 'creation asc';
  final noLimit = '30';

  final url = '${ApiNetwork.fetchCallingData}?order_by=${Uri.encodeQueryComponent(orderBy)}&filters=${Uri.encodeQueryComponent(filters)}&fields=${Uri.encodeQueryComponent(fields)}&limit=${Uri.encodeQueryComponent(noLimit)}';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Cookie': 'sid=$sid'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
        return (jsonResponse['data'] as List)
            .map((item) => CallingDataModel.fromJson(item))
            .toList();
      }
    }
  } catch (e) {
    return Future.error('Failed to load data');
  }

  return Future.error('No data available');
}

// Fetch CNR Calling Data
Future<List<CallingDataModel>> fetchCnrCallingData(String userId, String sid, String? designation) async {
  String filters;
  
  if (designation != null && designation == 'Branch Manager') {
    filters = '[["lead_status", "=", "CNR"]]';
  } else {
    filters = '[["email", "=", "$userId"], ["lead_status", "=", "CNR"]]';
  }

  final fields = '["name", "customer_name", "mobile_no", "data_status", "data_type", "employee_name", "email", "remarks", "lead_status"]';
  final orderBy = 'creation asc';
  final noLimit = '100';

  final url = '${ApiNetwork.fetchCallingData}?order_by=${Uri.encodeQueryComponent(orderBy)}&filters=${Uri.encodeQueryComponent(filters)}&fields=${Uri.encodeQueryComponent(fields)}&limit=${Uri.encodeQueryComponent(noLimit)}';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Cookie': 'sid=$sid'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
        return (jsonResponse['data'] as List)
            .map((item) => CallingDataModel.fromJson(item))
            .toList();
      }
    }
  } catch (e) {
    return Future.error('Failed to load data');
  }

  return Future.error('No data available');
}
