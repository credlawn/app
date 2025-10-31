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

  Future<List<CaseLoginModel>> getAllCaseLogins() async {
    final db = await _appDatabase.database;
    final result = await db.query('case_login');
    return result.map((json) => CaseLoginModel.fromMap(json)).toList();
  }

  Future<int> updateCaseLoginLocalFields(
    String currentFrappeId, {
    String? newFrappeId,
    int? isDirty,
    String? syncError,
  }) async {
    final db = await _appDatabase.database;
    final Map<String, dynamic> updates = {};
    if (newFrappeId != null) updates['frappe_id'] = newFrappeId;
    if (isDirty != null) updates['is_dirty'] = isDirty;
    if (syncError != null) updates['sync_error'] = syncError;

    if (updates.isEmpty) return 0; // No fields to update

    return await db.update(
      'case_login',
      updates,
      where: 'frappe_id = ?',
      whereArgs: [currentFrappeId],
    );
  }
}