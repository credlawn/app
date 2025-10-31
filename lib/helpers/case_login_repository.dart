import 'package:sqflite/sqflite.dart';
import 'package:credlawn/helpers/app_database.dart';
import 'package:credlawn/models/case_login_model.dart';

class CaseLoginRepository {
  final AppDatabase _appDatabase;

  CaseLoginRepository(this._appDatabase);

  Future<int> insertCaseLogin(CaseLoginModel caseLogin) async {
    final db = await _appDatabase.database;
    return await db.insert(
      'case_login',
      caseLogin.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateCaseLoginLocalFields(
    String currentFrappeId, {
    String? newFrappeId,
    int? isDirty,
    String? syncError,
    String? modified,
  }) async {
    final db = await _appDatabase.database;
    final Map<String, dynamic> updates = {};
    if (newFrappeId != null) updates['frappe_id'] = newFrappeId;
    if (isDirty != null) updates['is_dirty'] = isDirty;
    if (syncError != null) updates['sync_error'] = syncError;
    if (modified != null) updates['modified'] = modified;

    if (updates.isEmpty) return 0; // No fields to update

    return await db.update(
      'case_login',
      updates,
      where: 'frappe_id = ?',
      whereArgs: [currentFrappeId],
    );
  }

  Future<List<CaseLoginModel>> getAllCaseLogins() async {
    final db = await _appDatabase.database;
    final result = await db.query('case_login');
    return result.map((json) => CaseLoginModel.fromMap(json)).toList();
  }


  Future<int> deleteCaseLogin(String frappeId) async {
    final db = await _appDatabase.database;
    return await db.delete(
      'case_login',
      where: 'frappe_id = ?',
      whereArgs: [frappeId],
    );
  }

  Future<int> updateCaseLoginFields(
    String currentFrappeId, {
    String? newFrappeId,
    int? isDirty,
    String? syncError,
    String? customerName,
    String? mobileNo,
    String? loginDate,
    String? ipStatus,
    String? arnNo,
    String? remarks,
    String? user,
    String? modified,
  }) async {
    final db = await _appDatabase.database;
    final Map<String, dynamic> updates = {};
    if (newFrappeId != null) updates['frappe_id'] = newFrappeId;
    if (isDirty != null) updates['is_dirty'] = isDirty;
    if (syncError != null) updates['sync_error'] = syncError;
    if (customerName != null) updates['customer_name'] = customerName;
    if (mobileNo != null) updates['mobile_no'] = mobileNo;
    if (loginDate != null) updates['login_date'] = loginDate;
    if (ipStatus != null) updates['ip_status'] = ipStatus;
    if (arnNo != null) updates['arn_no'] = arnNo;
    if (remarks != null) updates['remarks'] = remarks;
    if (user != null) updates['user'] = user;
    if (modified != null) updates['modified'] = modified;

    if (updates.isEmpty) return 0; // No fields to update

    return await db.update(
      'case_login',
      updates,
      where: 'frappe_id = ?',
      whereArgs: [currentFrappeId],
    );
  }
}
