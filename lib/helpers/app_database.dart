
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('credlawn.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 7, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE call_history (
  id $idType,
  phone_number $textType,
  normalized_number $textType,
  duration $intType,
  call_type $textType,
  timestamp $intType,
  user $textType
)
''');

    await db.execute('CREATE INDEX idx_normalized_number ON call_history (normalized_number)');

    await db.execute('''
CREATE TABLE leads (
  id $idType,
  frappe_id $textType UNIQUE,
  allocation_date $textType DEFAULT '',
  user $textType DEFAULT '',
  customer_name $textType DEFAULT '',
  mobile_no $textType DEFAULT '',
  city $textType DEFAULT '',
  employer $textType DEFAULT '',
  segment $textType DEFAULT '',
  decline_reason $textType DEFAULT '',
  product $textType DEFAULT '',
  data_code $textType DEFAULT '',
  lead_status $textType DEFAULT '',
  remarks $textType DEFAULT '',
  arn_no $textType DEFAULT '',
  attempted_calls $intType DEFAULT 0,
  connected_calls $intType DEFAULT 0,
  total_duration $intType DEFAULT 0,
  allocation_status $textType DEFAULT 'Active',
  is_dirty $intType DEFAULT 0,
  last_synced_at $intType DEFAULT 0,
  sync_error $textType DEFAULT '',
  follow_up_date $textType DEFAULT '',
  follow_up_time $textType DEFAULT ''
)
''');

    await db.execute('''
CREATE TABLE case_login (
  id $idType,
  frappe_id $textType UNIQUE,
  sync_id $textType UNIQUE,
  customer_name $textType,
  mobile_no $textType,
  login_date $textType,
  ip_status $textType,
  arn_no $textType DEFAULT '',
  remarks $textType DEFAULT '',
  user $textType DEFAULT '',
  is_dirty $intType DEFAULT 0,
  sync_error $textType DEFAULT '',
  modified $textType DEFAULT ''
)
''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE call_history ADD COLUMN user TEXT NOT NULL DEFAULT ""');
    }
    if (oldVersion < 3) {
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const intType = 'INTEGER NOT NULL';
      await db.execute('''
CREATE TABLE leads (
  id $idType,
  frappe_id $textType UNIQUE,
  allocation_date $textType DEFAULT '',
  user $textType DEFAULT '',
  customer_name $textType DEFAULT '',
  mobile_no $textType DEFAULT '',
  city $textType DEFAULT '',
  employer $textType DEFAULT '',
  segment $textType DEFAULT '',
  decline_reason $textType DEFAULT '',
  product $textType DEFAULT '',
  data_code $textType DEFAULT '',
  lead_status $textType DEFAULT '',
  remarks $textType DEFAULT '',
  arn_no $textType DEFAULT '',
  attempted_calls $intType DEFAULT 0,
  connected_calls $intType DEFAULT 0,
  total_duration $intType DEFAULT 0,
  allocation_status $textType DEFAULT 'Active',
  is_dirty $intType DEFAULT 0,
  last_synced_at $intType DEFAULT 0,
  sync_error $textType DEFAULT '',
  follow_up_date $textType DEFAULT '',
  follow_up_time $textType DEFAULT ''
)
''');
    }
    if (oldVersion < 4) {
      
    }
    if (oldVersion < 5) {
      
    }
    if (oldVersion < 6) {
      
    }
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE case_login ADD COLUMN sync_id TEXT UNIQUE');
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
