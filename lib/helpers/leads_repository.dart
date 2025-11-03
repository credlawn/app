import 'package:sqflite/sqflite.dart';
import 'package:credlawn/helpers/app_database.dart';
import 'package:credlawn/helpers/database_service.dart';
import 'package:credlawn/models/leads_model.dart';

class LeadsRepository {
  final AppDatabase _appDatabase;

  LeadsRepository(this._appDatabase);

  Future<int> insertLead(LeadsModel lead) async {
    final db = await _appDatabase.database;
    return db.insert('leads', lead.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateLead(LeadsModel lead) async {
    final db = await _appDatabase.database;
    return db.update(
      'leads',
      lead.toMap(),
      where: 'frappe_id = ?',
      whereArgs: [lead.frappeId],
    );
  }

  Future<LeadsModel?> getLeadByFrappeId(String frappeId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'leads',
      where: 'frappe_id = ?',
      whereArgs: [frappeId],
    );
    if (maps.isNotEmpty) {
      return LeadsModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<LeadsModel>> getAllLeads() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('leads');
    
    return List.generate(maps.length, (i) {
      return LeadsModel.fromMap(maps[i]);
    });
  }

  Future<int> deleteLead(String frappeId) async {
    final db = await _appDatabase.database;
    return db.delete(
      'leads',
      where: 'frappe_id = ?',
      whereArgs: [frappeId],
    );
  }

  Future<int> markLeadAsInactive(String frappeId) async {
    final db = await _appDatabase.database;
    
    return db.update(
      'leads',
      {'allocation_status': 'Inactive'},
      where: 'frappe_id = ?',
      whereArgs: [frappeId],
    );
  }

  Future<void> upsertLeadFromApi(LeadsModel apiLead) async {
    if (apiLead.removeLead == 1) {
      await deleteLead(apiLead.frappeId);
      
      return;
    }

    final db = await _appDatabase.database;
    final existingLead = await getLeadByFrappeId(apiLead.frappeId);
    

    if (existingLead != null) {
      final updatedLead = apiLead.copyWith(
        id: existingLead.id,
        leadStatus: existingLead.leadStatus,
        remarks: existingLead.remarks,
        arnNo: existingLead.arnNo,
        attemptedCalls: existingLead.attemptedCalls,
        connectedCalls: existingLead.connectedCalls,
        totalDuration: existingLead.totalDuration,
        isDirty: existingLead.isDirty,
        lastSyncedAt: existingLead.lastSyncedAt,
        syncError: existingLead.syncError,
        allocationStatus: 'Active',
        followUpDate: existingLead.followUpDate,
        followUpTime: existingLead.followUpTime,
        bankStatus: apiLead.bankStatus, // Update from server
        bankStatusDate: apiLead.bankStatusDate, // Update from server
      );
      await updateLead(updatedLead);
    } else {
      await insertLead(apiLead.copyWith(allocationStatus: 'Active'));
    }
  }

  Future<int> updateLeadLocalFields(String frappeId, {
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
    int? lastFeedbackId, // New parameter
    int? lastFeedbackTimestamp, // New parameter
  }) async {
    final db = await _appDatabase.database;
    final Map<String, dynamic> fieldsToUpdate = {};
    if (leadStatus != null) fieldsToUpdate['lead_status'] = leadStatus;
    if (remarks != null) fieldsToUpdate['remarks'] = remarks;
    if (arnNo != null) fieldsToUpdate['arn_no'] = arnNo;
    if (attemptedCalls != null) fieldsToUpdate['attempted_calls'] = attemptedCalls;
    if (connectedCalls != null) fieldsToUpdate['connected_calls'] = connectedCalls;
    if (totalDuration != null) fieldsToUpdate['total_duration'] = totalDuration;
    if (allocationStatus != null) fieldsToUpdate['allocation_status'] = allocationStatus;
    if (isDirty != null) fieldsToUpdate['is_dirty'] = isDirty;
    if (lastSyncedAt != null) fieldsToUpdate['last_synced_at'] = lastSyncedAt;
    if (syncError != null) fieldsToUpdate['sync_error'] = syncError;
    if (followUpDate != null) fieldsToUpdate['follow_up_date'] = followUpDate;
    if (followUpTime != null) fieldsToUpdate['follow_up_time'] = followUpTime;
    if (lastFeedbackId != null) fieldsToUpdate['last_feedback_id'] = lastFeedbackId; // Update new field
    if (lastFeedbackTimestamp != null) fieldsToUpdate['last_feedback_timestamp'] = lastFeedbackTimestamp; // Update new field

    return db.update(
      'leads',
      fieldsToUpdate,
      where: 'frappe_id = ?',
      whereArgs: [frappeId],
    );
  }

  Future<List<String>> getFrappeIdsOfActiveLeads() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'leads',
      columns: ['frappe_id'],
      where: 'allocation_status = ?',
      whereArgs: ['Active'],
    );
    
    return maps.map((map) => map['frappe_id'] as String).toList();
  }

  Future<LeadsModel?> getLeadByMobileNo(String mobileNo) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'leads',
      where: 'mobile_no = ?',
      whereArgs: [mobileNo],
    );
    if (maps.isNotEmpty) {
      return LeadsModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<void> updateCallStatisticsForLead(String frappeId, String mobileNo) async {
    await DatabaseService.instance.callHistoryRepository.syncPhoneCallLogs();

    final stats = await DatabaseService.instance.callHistoryRepository.calculateCallStatistics(mobileNo);

    await updateLeadLocalFields(
      frappeId,
      attemptedCalls: stats['attempted'],
      connectedCalls: stats['connected'],
      totalDuration: stats['duration'],
    );
  }
}
