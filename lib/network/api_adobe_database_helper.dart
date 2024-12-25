import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/adobe_database_model.dart';  
import 'package:credlawn/network/api_network.dart';
import 'package:intl/intl.dart'; 

Future<List<AdobeDatabaseModel>> fetchVkycExpireToday(String userId, String sid, String? designation) async {
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final startOfDay = '$today 00:00:00';
  final endOfDay = '$today 23:59:59';
  final filters = '[["lead_owner", "=", "$userId"], ["vkyc_expire_date", ">=", "$startOfDay"], ["vkyc_expire_date", "<=", "$endOfDay"], ["vkyc_status", "like", "PENDING"]]';
  final fields = '["name", "customer_name", "creation_date", "final_decision_date", "promo_code", "ipa_status", "kyc_type", "vkyc_status", "employee_name", "reference_no", "vkyc_link", "vkyc_expire_date", "final_decision", "final_stage", "action_required", "mobile_no"]';
  final orderBy = 'vkyc_expire_date asc';
  final noLimit = '20';

  final url = '${ApiNetwork.fetchAdobeDumpData}?order_by=${Uri.encodeQueryComponent(orderBy)}&filters=${Uri.encodeQueryComponent(filters)}&fields=${Uri.encodeQueryComponent(fields)}&limit=${Uri.encodeQueryComponent(noLimit)}';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Cookie': 'sid=$sid'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
        return (jsonResponse['data'] as List)
            .map((item) => AdobeDatabaseModel.fromJson(item))
            .toList();
      }
    }
  } catch (e) {
    return Future.error('Failed to load data');
  }

  return Future.error('No VKYC Pending Today');
}

Future<List<AdobeDatabaseModel>> fetchTotalPendingVkyc(String userId, String sid, String? designation) async {
  final firstDayOfMonth = DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, 1));
  final lastDayOfMonth = DateFormat('yyyy-MM-dd').format(
      DateTime(DateTime.now().year, DateTime.now().month + 1, 0));
  final filters = '[["lead_owner", "=", "$userId"], ["vkyc_expire_date", ">=", "$firstDayOfMonth"], ["vkyc_expire_date", "<=", "$lastDayOfMonth"], ["vkyc_status", "like", "PENDING"]]'; 
  final fields = '["name", "customer_name", "creation_date", "final_decision_date", "promo_code", "ipa_status", "kyc_type", "vkyc_status", "employee_name", "reference_no", "vkyc_link", "vkyc_expire_date", "final_decision", "final_stage", "action_required", "mobile_no"]';
  final orderBy = 'vkyc_expire_date asc';
  final noLimit = '100';

  final url = '${ApiNetwork.fetchAdobeDumpData}?order_by=${Uri.encodeQueryComponent(orderBy)}&filters=${Uri.encodeQueryComponent(filters)}&fields=${Uri.encodeQueryComponent(fields)}&limit=${Uri.encodeQueryComponent(noLimit)}';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Cookie': 'sid=$sid'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
        return (jsonResponse['data'] as List)
            .map((item) => AdobeDatabaseModel.fromJson(item))
            .toList();
      }
    }
  } catch (e) {
    return Future.error('Failed to load data');
  }

  return Future.error('Great: NO VKYC Pending');
}