import 'package:sqflite/sqflite.dart';
import 'package:credlawn/models/feedback_model.dart';

class FeedbackRepository {
  final Database _database;

  FeedbackRepository(this._database);

  static const String tableName = 'feedback';

  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lead_frappe_id TEXT NOT NULL,
        status TEXT NOT NULL,
        remarks TEXT,
        arn_no TEXT,
        follow_up_date TEXT,
        follow_up_time TEXT,
        timestamp INTEGER NOT NULL,
        user_id TEXT,
        mobile_no TEXT,
        customer_name TEXT
      )
    ''');
  }

  Future<int> insertFeedback(FeedbackModel feedback) async {
    return await _database.insert(
      tableName,
      feedback.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FeedbackModel>> getFeedbackForLead(String leadFrappeId) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      tableName,
      where: 'lead_frappe_id = ?',
      whereArgs: [leadFrappeId],
      orderBy: 'timestamp DESC', // Order by most recent feedback first
    );

    return List.generate(maps.length, (i) {
      return FeedbackModel.fromMap(maps[i]);
    });
  }

  Future<List<FeedbackModel>> getAllFeedback() async {
    final List<Map<String, dynamic>> maps = await _database.query(tableName);
    return List.generate(maps.length, (i) {
      return FeedbackModel.fromMap(maps[i]);
    });
  }

  Future<int> deleteFeedback(int id) async {
    return await _database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllFeedbackForLead(String leadFrappeId) async {
    return await _database.delete(
      tableName,
      where: 'lead_frappe_id = ?',
      whereArgs: [leadFrappeId],
    );
  }

  // Sync-related methods
  Future<List<FeedbackModel>> getUnsyncedFeedback() async {
    final List<Map<String, dynamic>> maps = await _database.query(
      tableName,
      where: 'is_synced = 0',
      orderBy: 'timestamp ASC', // Sync oldest first
    );

    return List.generate(maps.length, (i) {
      return FeedbackModel.fromMap(maps[i]);
    });
  }

  Future<void> markFeedbackAsSynced(int id, {String? serverId}) async {
    await _database.update(
      tableName,
      {
        'is_synced': 1,
        'server_id': serverId,
        'last_sync_attempt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> incrementSyncAttempts(int id) async {
    final currentAttempts = await _getSyncAttempts(id);
    await _database.update(
      tableName,
      {
        'sync_attempts': currentAttempts + 1,
        'last_sync_attempt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> _getSyncAttempts(int id) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      tableName,
      columns: ['sync_attempts'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first['sync_attempts'] ?? 0;
    }
    return 0;
  }
}
