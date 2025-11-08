
class LeadsModel {
  final int? id;
  final String frappeId;
  final String allocationDate;
  final String user;
  final String customerName;
  final String mobileNo;
  final String city;
  final String employer;
  final String segment;
  final String declineReason;
  final String product;
  final String dataCode;
  final String leadStatus;
  final String remarks;
  final String arnNo;
  final int attemptedCalls;
  final int connectedCalls;
  final int totalDuration;
  final String allocationStatus;
  final int isDirty;
  final int lastModifiedAt;
  final String syncError;
  final String followUpDate;
  final String followUpTime;
  final String bankStatus;
  final String bankStatusDate;
  final int removeLead;
  final int? lastFeedbackId; // New field to store the ID of the last feedback
  final int? lastFeedbackTimestamp; // New field to store the timestamp of the last feedback
  final String leadStatusDate; // Date when lead status was last changed
  final String dateOfBirth; // Customer's date of birth

  LeadsModel({
    this.id,
    required this.frappeId,
    required this.allocationDate,
    required this.user,
    required this.customerName,
    required this.mobileNo,
    required this.city,
    required this.employer,
    required this.segment,
    required this.declineReason,
    required this.product,
    required this.dataCode,
    required this.leadStatus,
    required this.remarks,
    required this.arnNo,
    required this.attemptedCalls,
    required this.connectedCalls,
    required this.totalDuration,
    required this.allocationStatus,
    required this.isDirty,
    required this.lastModifiedAt,
    required this.syncError,
    required this.followUpDate,
    required this.followUpTime,
    required this.bankStatus,
    required this.bankStatusDate,
    required this.removeLead,
    this.lastFeedbackId, // Initialize new field
    this.lastFeedbackTimestamp, // Initialize new field
    this.leadStatusDate = '', // New field
    this.dateOfBirth = '', // New field
  });

  factory LeadsModel.fromJson(Map<String, dynamic> json) {
    return LeadsModel(
      frappeId: json['name'] ?? '',
      allocationDate: json['allocation_date'] ?? '',
      user: json['user'] ?? '',
      customerName: json['customer_name'] ?? '',
      mobileNo: json['mobile_no']?.toString() ?? '',
      city: json['city'] ?? '',
      employer: json['employer'] ?? '',
      segment: json['segment'] ?? '',
      declineReason: json['decline_reason'] ?? '',
      product: json['product'] ?? '',
      dataCode: json['data_code'] ?? '',
      leadStatus: json['lead_status'] ?? '',
      remarks: json['remarks'] ?? '',
      arnNo: json['arn_no'] ?? '',
      attemptedCalls: json['attempted_calls'] ?? 0,
      connectedCalls: json['connected_calls'] ?? 0,
      totalDuration: json['total_duration'] ?? 0,
      allocationStatus: json['allocation_status'] ?? 'Active',
      isDirty: 0,
      lastModifiedAt: DateTime.now().millisecondsSinceEpoch,
      syncError: '',
      followUpDate: json['follow_up_date'] ?? '',
      followUpTime: json['follow_up_time'] ?? '',
      bankStatus: json['bank_status'] ?? '',
      bankStatusDate: json['bank_status_date'] ?? '',
      removeLead: json['remove_lead'] ?? 0,
      lastFeedbackId: null, // New field, not from API initially
      lastFeedbackTimestamp: null, // New field, not from API initially
      leadStatusDate: json['lead_status_date'] ?? '', // New field
      dateOfBirth: json['date_of_birth'] ?? '', // New field
    );
  }

  factory LeadsModel.fromMap(Map<String, dynamic> map) {
    return LeadsModel(
      id: map['id'] as int?,
      frappeId: map['frappe_id'] ?? '',
      allocationDate: map['allocation_date'] ?? '',
      user: map['user'] ?? '',
      customerName: map['customer_name'] ?? '',
      mobileNo: map['mobile_no'] ?? '',
      city: map['city'] ?? '',
      employer: map['employer'] ?? '',
      segment: map['segment'] ?? '',
      declineReason: map['decline_reason'] ?? '',
      product: map['product'] ?? '',
      dataCode: map['data_code'] ?? '',
      leadStatus: map['lead_status'] ?? '',
      remarks: map['remarks'] ?? '',
      arnNo: map['arn_no'] ?? '',
      attemptedCalls: map['attempted_calls'] ?? 0,
      connectedCalls: map['connected_calls'] ?? 0,
      totalDuration: map['total_duration'] ?? 0,
      allocationStatus: map['allocation_status'] ?? 'Active',
      isDirty: map['is_dirty'] ?? 0,
      lastModifiedAt: map['last_modified_at'] ?? 0,
      syncError: map['sync_error'] ?? '',
      followUpDate: map['follow_up_date'] ?? '',
      followUpTime: map['follow_up_time'] ?? '',
      bankStatus: map['bank_status'] ?? '',
      bankStatusDate: map['bank_status_date'] ?? '',
      removeLead: 0, // This field is only from the API, not stored locally
      lastFeedbackId: map['last_feedback_id'] as int?, // New field
      lastFeedbackTimestamp: map['last_feedback_timestamp'] as int?, // New field
      leadStatusDate: map['lead_status_date'] ?? '', // New field
      dateOfBirth: map['date_of_birth'] ?? '', // New field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'frappe_id': frappeId,
      'allocation_date': allocationDate,
      'user': user,
      'customer_name': customerName,
      'mobile_no': mobileNo,
      'city': city,
      'employer': employer,
      'segment': segment,
      'decline_reason': declineReason,
      'product': product,
      'data_code': dataCode,
      'lead_status': leadStatus,
      'remarks': remarks,
      'arn_no': arnNo,
      'attempted_calls': attemptedCalls,
      'connected_calls': connectedCalls,
      'total_duration': totalDuration,
      'allocation_status': allocationStatus,
      'is_dirty': isDirty,
      'last_modified_at': lastModifiedAt,
      'sync_error': syncError,
      'follow_up_date': followUpDate,
      'follow_up_time': followUpTime,
      'bank_status': bankStatus,
      'bank_status_date': bankStatusDate,
      'last_feedback_id': lastFeedbackId, // New field
      'last_feedback_timestamp': lastFeedbackTimestamp, // New field
      'lead_status_date': leadStatusDate, // New field
      'date_of_birth': dateOfBirth, // New field
    };
  }

  LeadsModel copyWith({
    int? id,
    String? frappeId,
    String? allocationDate,
    String? user,
    String? customerName,
    String? mobileNo,
    String? city,
    String? employer,
    String? segment,
    String? declineReason,
    String? product,
    String? dataCode,
    String? leadStatus,
    String? remarks,
    String? arnNo,
    int? attemptedCalls,
    int? connectedCalls,
    int? totalDuration,
    String? allocationStatus,
    int? isDirty,
    int? lastModifiedAt,
    String? syncError,
    String? followUpDate,
    String? followUpTime,
    String? bankStatus,
    String? bankStatusDate,
    int? removeLead,
    int? lastFeedbackId, // New field
    int? lastFeedbackTimestamp, // New field
    String? leadStatusDate, // New field
    String? dateOfBirth, // New field
  }) {
    return LeadsModel(
      id: id ?? this.id,
      frappeId: frappeId ?? this.frappeId,
      allocationDate: allocationDate ?? this.allocationDate,
      user: user ?? this.user,
      customerName: customerName ?? this.customerName,
      mobileNo: mobileNo ?? this.mobileNo,
      city: city ?? this.city,
      employer: employer ?? this.employer,
      segment: segment ?? this.segment,
      declineReason: declineReason ?? this.declineReason,
      product: product ?? this.product,
      dataCode: dataCode ?? this.dataCode,
      leadStatus: leadStatus ?? this.leadStatus,
      remarks: remarks ?? this.remarks,
      arnNo: arnNo ?? this.arnNo,
      attemptedCalls: attemptedCalls ?? this.attemptedCalls,
      connectedCalls: connectedCalls ?? this.connectedCalls,
      totalDuration: totalDuration ?? this.totalDuration,
      allocationStatus: allocationStatus ?? this.allocationStatus,
      isDirty: isDirty ?? this.isDirty,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      syncError: syncError ?? this.syncError,
      followUpDate: followUpDate ?? this.followUpDate,
      followUpTime: followUpTime ?? this.followUpTime,
      bankStatus: bankStatus ?? this.bankStatus,
      bankStatusDate: bankStatusDate ?? this.bankStatusDate,
      removeLead: removeLead ?? this.removeLead,
      lastFeedbackId: lastFeedbackId ?? this.lastFeedbackId, // New field
      lastFeedbackTimestamp: lastFeedbackTimestamp ?? this.lastFeedbackTimestamp, // New field
      leadStatusDate: leadStatusDate ?? this.leadStatusDate, // New field
      dateOfBirth: dateOfBirth ?? this.dateOfBirth, // New field
    );
  }
}
