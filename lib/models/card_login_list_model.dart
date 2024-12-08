import 'package:intl/intl.dart';

class CardLoginListModel {
  final String customerName;
  final String mobileNo;
  final String punchingDate;
  final String ipStatus;
  final String panNo;
  final String kycStatus;
  final String incompleteReason;
  final String employeeName;
  final String referenceNo;

  CardLoginListModel({
    required this.customerName,
    required this.mobileNo,
    required this.punchingDate,
    required this.ipStatus,
    required this.panNo,
    required this.kycStatus,
    required this.incompleteReason,
    required this.employeeName,
    required this.referenceNo,
  });

  factory CardLoginListModel.fromJson(Map<String, dynamic> json) {
    return CardLoginListModel(
      customerName: json['customer_name'] ?? '',
      mobileNo: json['mobile_no']?.toString() ?? '',
      punchingDate: _formatDate(json['punching_date'] ?? ''),
      ipStatus: json['ip_status'] ?? '',
      panNo: json['pan_no'] ?? '',
      kycStatus: json['kyc_status'] ?? '',
      incompleteReason: json['incomplete_reason'] ?? '',
      employeeName: json['employee_name'] ?? '',
      referenceNo: json['reference_no'] ?? '',
    );
  }

  static String _formatDate(String date) {
    if (date.isEmpty) {
      return '';
    }
    try {
      final parsedDate = DateFormat('yyyy-MM-dd').parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'mobile_no': mobileNo,
      'punching_date': punchingDate,
      'ip_status': ipStatus,
      'pan_no': panNo,
      'kyc_status': kycStatus,
      'incomplete_reason': incompleteReason,
      'employee_name': employeeName,
      'reference_no': referenceNo,
    };
  }
}
