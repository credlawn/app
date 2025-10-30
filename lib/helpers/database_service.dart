import 'package:credlawn/helpers/app_database.dart';
import 'package:credlawn/helpers/call_history_repository.dart';
import 'package:credlawn/helpers/leads_repository.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();

  late final AppDatabase appDatabase;
  late final CallHistoryRepository callHistoryRepository;
  late final LeadsRepository leadsRepository;

  DatabaseService._init() {
    appDatabase = AppDatabase.instance;
    callHistoryRepository = CallHistoryRepository(appDatabase);
    leadsRepository = LeadsRepository(appDatabase);
  }

  Future<void> initialize() async {
    await appDatabase.database; // Initialize the database
  }

  Future<void> close() async {
    await appDatabase.close();
  }
}
