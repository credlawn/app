import 'package:credlawn/helpers/app_database.dart';
import 'package:credlawn/helpers/call_history_repository.dart';
import 'package:credlawn/helpers/leads_repository.dart';
import 'package:credlawn/helpers/case_login_repository.dart';
import 'package:credlawn/helpers/feedback_repository.dart'; // Import FeedbackRepository

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();

  late final AppDatabase appDatabase;
  late final CallHistoryRepository callHistoryRepository;
  late final LeadsRepository leadsRepository;
  late final CaseLoginRepository caseLoginRepository;
  late final FeedbackRepository feedbackRepository; // Declare FeedbackRepository

  DatabaseService._init() {
    appDatabase = AppDatabase.instance;
    callHistoryRepository = CallHistoryRepository(appDatabase);
    leadsRepository = LeadsRepository(appDatabase);
    caseLoginRepository = CaseLoginRepository(appDatabase);
    // Initialize feedbackRepository later in the async initialize method
  }

  Future<void> initialize() async {
    final db = await appDatabase.database; // Initialize the database
    feedbackRepository = FeedbackRepository(db); // Initialize FeedbackRepository here
  }

  Future<void> close() async {
    await appDatabase.close();
  }
}
