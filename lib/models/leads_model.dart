import 'package:intl/intl.dart';

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
  final int lastSyncedAt;
  final String syncError;
  final String followUpDate;
  final String followUpTime;

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
    required this.lastSyncedAt,
    required this.syncError,
    required this.followUpDate,
    required this.followUpTime,
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
      lastSyncedAt: DateTime.now().millisecondsSinceEpoch,
      syncError: '',
      followUpDate: json['follow_up_date'] ?? '',
      followUpTime: json['follow_up_time'] ?? '',
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
      lastSyncedAt: map['last_synced_at'] ?? 0,
      syncError: map['sync_error'] ?? '',
      followUpDate: map['follow_up_date'] ?? '',
      followUpTime: map['follow_up_time'] ?? '',
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
      'last_synced_at': lastSyncedAt,
      'sync_error': syncError,
      'follow_up_date': followUpDate,
      'follow_up_time': followUpTime,
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
    int? lastSyncedAt,
    String? syncError,
    String? followUpDate,
    String? followUpTime,
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
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      syncError: syncError ?? this.syncError,
      followUpDate: followUpDate ?? this.followUpDate,
      followUpTime: followUpTime ?? this.followUpTime,
    );
  }
}
