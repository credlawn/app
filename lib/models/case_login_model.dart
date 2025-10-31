class CaseLoginModel {
  final int? id;
  final String? frappeId;
  final String customerName;
  final String mobileNo;
  final String loginDate;
  final String ipStatus;
  final String arnNo;
  final String remarks;
  final String? user;
  final int isDirty;
  final String? syncError;

  CaseLoginModel({
    this.id,
    this.frappeId,
    required this.customerName,
    required this.mobileNo,
    required this.loginDate,
    required this.ipStatus,
    this.arnNo = '',
    this.remarks = '',
    this.user,
    this.isDirty = 0,
    this.syncError,
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
      'is_dirty': isDirty,
      'sync_error': syncError,
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
      arnNo: map['arn_no'] ?? '',
      remarks: map['remarks'] ?? '',
      user: map['user'],
      isDirty: map['is_dirty'] ?? 0,
      syncError: map['sync_error'],
    );
  }

  CaseLoginModel copyWith({
    int? id,
    String? frappeId,
    String? customerName,
    String? mobileNo,
    String? loginDate,
    String? ipStatus,
    String? arnNo,
    String? remarks,
    String? user,
    int? isDirty,
    String? syncError,
  }) {
    return CaseLoginModel(
      id: id ?? this.id,
      frappeId: frappeId ?? this.frappeId,
      customerName: customerName ?? this.customerName,
      mobileNo: mobileNo ?? this.mobileNo,
      loginDate: loginDate ?? this.loginDate,
      ipStatus: ipStatus ?? this.ipStatus,
      arnNo: arnNo ?? this.arnNo,
      remarks: remarks ?? this.remarks,
      user: user ?? this.user,
      isDirty: isDirty ?? this.isDirty,
      syncError: syncError ?? this.syncError,
    );
  }
}