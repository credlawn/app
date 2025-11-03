import 'dart:async';
import 'package:credlawn/helpers/database_service.dart';
import 'package:credlawn/models/leads_model.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/network/api_leads_helper.dart';
import 'package:credlawn/helpers/error_logger.dart';
import 'package:credlawn/helpers/session_manager.dart';

class BackgroundSyncService {
  static Future<void> triggerSync() async {
    final User? currentUser = await SessionManager.getSessionData();
    if (currentUser != null) {
      unawaited(_performSync(currentUser));
    }
  }

  static Future<void> _performSync(User currentUser) async {
    try {
      await syncLeads(currentUser);
    } catch (e) {
      // Silent fail for background sync errors
    }
  }

  static void initialize() {}

  static Future<void> syncLeads(User currentUser) async {
    try {
      await ErrorLogger.logError(
        title: 'Background Lead Sync Started',
        errorMessage: 'Starting lead synchronization for user: ${currentUser.userId}',
        errorType: 'Data Sync',
        userId: currentUser.userId,
      );

      // 1. Sync dirty leads from local to server
      final dirtyLeads = await DatabaseService.instance.leadsRepository.getAllLeads();
      for (final lead in dirtyLeads.where((l) => l.isDirty == 1)) {
        try {
          final bool success = await syncLeadUpdateToServer(lead, currentUser.sid);
          if (success) {
            await DatabaseService.instance.leadsRepository.updateLeadLocalFields(
              lead.frappeId,
              isDirty: 0,
              lastSyncedAt: DateTime.now().millisecondsSinceEpoch,
            );
          } else {
            await ErrorLogger.logError(
              title: 'Background Lead Sync Failed',
              errorMessage: 'Failed to sync lead: ${lead.frappeId}',
              errorType: 'Data Sync',
              userId: currentUser.userId,
            );
          }
        } catch (e) {
          await ErrorLogger.logException(
            context: 'BackgroundSyncService.syncLeads.syncLeadUpdate',
            exception: e,
            userId: currentUser.userId,
          );
        }
      }

      // 2. Fetch latest leads from API and update local DB
      final apiLeads = await fetchEmployeeLeadsFromApi(currentUser.userId, currentUser.sid);
      final Set<String> apiFrappeIds = apiLeads.map((lead) => lead.frappeId).toSet();

      for (final apiLead in apiLeads) {
        await DatabaseService.instance.leadsRepository.upsertLeadFromApi(apiLead);
      }

      // 3. Mark leads as inactive if they are no longer in the API response
      final allLocalLeads = await DatabaseService.instance.leadsRepository.getAllLeads();
      for (final localLead in allLocalLeads) {
        if (localLead.allocationStatus == 'Active' && !apiFrappeIds.contains(localLead.frappeId)) {
          await DatabaseService.instance.leadsRepository.markLeadAsInactive(localLead.frappeId);
        }
      }

      await ErrorLogger.logError(
        title: 'Background Lead Sync Completed',
        errorMessage: 'Successfully synced leads for user: ${currentUser.userId}',
        errorType: 'Data Sync',
        userId: currentUser.userId,
      );
    } catch (e) {
      await ErrorLogger.logException(
        context: 'BackgroundSyncService.syncLeads',
        exception: e,
        userId: currentUser.userId,
      );
    }
  }
}
