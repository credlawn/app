import 'package:credlawn/models/leads_model.dart'; // For LeadsModel reference

class FeedbackModel {
  final int? id;
  final String leadFrappeId;
  final String status;
  final String? remarks;
  final String? arnNo;
  final String? followUpDate;
  final String? followUpTime;
  final int timestamp;
  final String? userId;
  final String? mobileNo;
  final String? customerName;
  final bool isSynced;
  final int syncAttempts;
  final int lastSyncAttempt;
  final String? serverId;

  FeedbackModel({
    this.id,
    required this.leadFrappeId,
    required this.status,
    this.remarks,
    this.arnNo,
    this.followUpDate,
    this.followUpTime,
    required this.timestamp,
    this.userId,
    this.mobileNo,
    this.customerName,
    this.isSynced = false,
    this.syncAttempts = 0,
    this.lastSyncAttempt = 0,
    this.serverId,
  });

  // Convert a FeedbackModel into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lead_frappe_id': leadFrappeId,
      'status': status,
      'remarks': remarks,
      'arn_no': arnNo,
      'follow_up_date': followUpDate,
      'follow_up_time': followUpTime,
      'timestamp': timestamp,
      'user_id': userId,
      'mobile_no': mobileNo,
      'customer_name': customerName,
      'is_synced': isSynced ? 1 : 0,
      'sync_attempts': syncAttempts,
      'last_sync_attempt': lastSyncAttempt,
      'server_id': serverId,
    };
  }

  // Implement toString to make it easier to see information about
  // each feedback when using the print statement.
  @override
  String toString() {
    return 'FeedbackModel{id: $id, leadFrappeId: $leadFrappeId, status: $status, remarks: $remarks, arnNo: $arnNo, followUpDate: $followUpDate, followUpTime: $followUpTime, timestamp: $timestamp, userId: $userId, mobileNo: $mobileNo, customerName: $customerName}';
  }

  // Factory method to create a FeedbackModel from a Map
  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'],
      leadFrappeId: map['lead_frappe_id'],
      status: map['status'],
      remarks: map['remarks'],
      arnNo: map['arn_no'],
      followUpDate: map['follow_up_date'],
      followUpTime: map['follow_up_time'],
      timestamp: map['timestamp'],
      userId: map['user_id'],
      mobileNo: map['mobile_no'],
      customerName: map['customer_name'],
      isSynced: map['is_synced'] != null ? map['is_synced'] == 1 : false,
      syncAttempts: map['sync_attempts'] ?? 0,
      lastSyncAttempt: map['last_sync_attempt'] ?? 0,
      serverId: map['server_id'],
    );
  }
}
