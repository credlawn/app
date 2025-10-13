import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/calling_data_model.dart';
import 'package:credlawn/network/api_network.dart';
import 'package:intl/intl.dart';


// Fetch Normal Calling Data
Future<List<CallingDataModel>> fetchNormalCallingData(String userId, String sid, String? designation) async {

  final Map<String, dynamic> queryParams = {
    'user_id': userId,
    'designation': designation,
  };

  final Uri uri = Uri.http(
    Uri.parse(ApiNetwork.baseUrl).host,
    Uri.parse(ApiNetwork.getNormalLeads).path,
    queryParams,
  );

  try {
    final response = await http.get(
      uri,
      headers: {'Cookie': 'sid=$sid'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['message'] != null && jsonResponse['message'].isNotEmpty) {
        return (jsonResponse['message'] as List)
            .map((item) => CallingDataModel.fromJson(item)) 
            .toList();
      }
    }
  } catch (e) {
    return Future.error('Failed to load data');
  }

  return Future.error('No normal leads available');
}

Future<List<CallingDataModel>> fetchInterestedCallingData(String userId, String sid, String? designation) async {

  final Map<String, dynamic> queryParams = {
    'user_id': userId,
    'designation': designation,
  };

  final Uri uri = Uri.http(
    Uri.parse(ApiNetwork.baseUrl).host,
    Uri.parse(ApiNetwork.getInterestedLeads).path,
    queryParams,
  );

  try {
    final response = await http.get(
      uri,
      headers: {'Cookie': 'sid=$sid'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['message'] != null && jsonResponse['message'].isNotEmpty) {
        return (jsonResponse['message'] as List)
            .map((item) => CallingDataModel.fromJson(item)) 
            .toList();
      }
    }
  } catch (e) {
    return Future.error('Failed to load data');
  }

  return Future.error('No Interested leads available');
}

Future<List<CallingDataModel>> fetchPreApprovedCallingData(String userId, String sid, String? designation) async {

  final Map<String, dynamic> queryParams = {
    'user_id': userId,
    'designation': designation,
  };

  final Uri uri = Uri.http(
    Uri.parse(ApiNetwork.baseUrl).host,
    Uri.parse(ApiNetwork.getPreApprovedLeads).path,
    queryParams,
  );

  try {
    final response = await http.get(
      uri,
      headers: {'Cookie': 'sid=$sid'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['message'] != null && jsonResponse['message'].isNotEmpty) {
        return (jsonResponse['message'] as List)
            .map((item) => CallingDataModel.fromJson(item))
            .toList();
      }
    }
  } catch (e) {
    return Future.error('Failed to load data');
  }

  return Future.error('No Pre Approved leads available');
}

// Fetch CNR Calling Data
Future<List<CallingDataModel>> fetchCnrCallingData(String userId, String sid, String? designation) async {
  String filters;
  
  if (designation != null && designation == 'Branch Manager') {
    filters = '[["lead_status", "=", "CNR"]]';
  } else {
    filters = '[["email", "=", "$userId"], ["lead_status", "=", "CNR"], ["data_status", "=", "Allocated"]]';
  }

  final fields = '["name", "customer_name", "mobile_no", "data_status", "data_type", "employee_name", "email", "remarks", "lead_status", "update_date", "follow_up_date"]';
  final orderBy = 'update_date asc';
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

  return Future.error('Wow: You have no CNR');
}

Future<List<CallingDataModel>> fetchFollowUpCallingData(String userId, String sid, String? designation) async {
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String filters;
  
  if (designation != null && designation == 'Branch Manager') {
    filters = '[["lead_status", "=", "CNR"]]';
  } else {
    filters = '[["email", "=", "$userId"], ["lead_status", "=", "Follow-up"], ["follow_up_date", "<=", "$today"], ["data_status", "=", "Allocated"]]';
  }

  final fields = '["name", "customer_name", "mobile_no", "data_status", "data_type", "employee_name", "email", "remarks", "lead_status", "update_date", "follow_up_date"]';
  final orderBy = 'follow_up_date asc';
  final noLimit = '40';

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

  return Future.error('All up to date. You Have no follow-ups left');
}