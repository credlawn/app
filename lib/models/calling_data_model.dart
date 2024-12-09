import 'package:intl/intl.dart';

class CallingDataModel {
  final String name;
  final String customerName;
  final String mobileNo;
  final String dataStatus;
  final String dataType;
  final String employeeName;
  final String email;
  final String leadStatus;
  final String remarks;
  final String updateDate;

  CallingDataModel({
    required this.name,
    required this.customerName,
    required this.mobileNo,
    required this.dataStatus,
    required this.dataType,
    required this.employeeName,
    required this.email,
    required this.leadStatus,
    required this.remarks,
    required this.updateDate,
  });

  factory CallingDataModel.fromJson(Map<String, dynamic> json) {
    return CallingDataModel(
      name: json['name'] ?? '',
      customerName: json['customer_name'] ?? '',
      mobileNo: json['mobile_no']?.toString() ?? '',
      dataStatus: json['data_status'] ?? '',
      dataType: json['data_type'] ?? '',
      employeeName: json['employee_name'] ?? '',
      email: json['email'] ?? '',
      leadStatus: json['lead_status'] ?? '',
      remarks: json['remarks'] ?? '',
      updateDate: json['update_date'] ?? '',
    );
  }

  static String _formatDate(String date) {
    if (date.isEmpty) {
      return '';
    }
    try {
      final parsedDate = DateFormat('dd-MM-yyyy').parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'mobile_no': mobileNo,
      'data_status': dataStatus,
      'data_type': dataType,
      'employee_name': employeeName,
      'email': email,
      'lead_status': leadStatus,
      'remarks': remarks,
      'update_date': updateDate,
    };
  }
}
