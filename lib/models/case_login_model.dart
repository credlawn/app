class CaseLoginModel {
  final int? id;
  final String frappeId;
  final String customerName;
  final String mobileNo;
  final String loginDate;
  final String ipStatus;
  final String arnNo;
  final String remarks;
  final String? user;

  CaseLoginModel({
    this.id,
    required this.frappeId,
    required this.customerName,
    required this.mobileNo,
    required this.loginDate,
    required this.ipStatus,
    required this.arnNo,
    required this.remarks,
    this.user,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'frappe_id': frappeId,
      'customer_name': customerName,
      'mobile_no': mobileNo,
      'login_date': loginDate,
      'ip_status': ipStatus,
      'arn_no': arnNo,
      'remarks': remarks,
      'user': user,
    };
  }

  factory CaseLoginModel.fromMap(Map<String, dynamic> map) {
    return CaseLoginModel(
      id: map['id'],
      frappeId: map['frappe_id'],
      customerName: map['customer_name'],
      mobileNo: map['mobile_no'],
      loginDate: map['login_date'],
      ipStatus: map['ip_status'],
      arnNo: map['arn_no'],
      remarks: map['remarks'],
      user: map['user'],
    );
  }
}