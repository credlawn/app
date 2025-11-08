import 'dart:async';
import 'package:credlawn/helpers/database_service.dart';
import 'package:credlawn/models/leads_model.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/network/api_leads_helper.dart';
import 'package:credlawn/helpers/error_logger.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/helpers/app_state_manager.dart';
import 'package:credlawn/screens/login_screen.dart';
import 'package:flutter/material.dart';

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
      
    }
  }

  static void initialize() {}

  static Future<void> syncLeads(User currentUser) async {
    try {
      final dirtyLeads = await DatabaseService.instance.leadsRepository.getAllLeads();
      for (final lead in dirtyLeads.where((l) => l.isDirty == 1)) {
        await ErrorLogger.logError(
          title: 'Background Sync Processing Lead',
          errorMessage: 'Processing lead: ${lead.frappeId}, status: ${lead.leadStatus}, is_dirty: ${lead.isDirty}',
          errorType: 'Data Sync Debug',
          userId: currentUser.userId,
        );
        try {
          final bool success = await syncLeadUpdateToServer(lead, currentUser.sid);
          if (success) {
            try {
              final rowsAffected = await DatabaseService.instance.leadsRepository.updateLeadLocalFields(
                lead.frappeId,
                isDirty: 0,
                lastModifiedAt: DateTime.now().millisecondsSinceEpoch,
              );

              if (rowsAffected == 0) {
                await ErrorLogger.logError(
                  title: 'Background Lead Sync - No Rows Updated',
                  errorMessage: 'updateLeadLocalFields returned 0 rows for lead: ${lead.frappeId}, lead_status: ${lead.leadStatus}, is_dirty: ${lead.isDirty}',
                  errorType: 'Data Sync',
                  userId: currentUser.userId,
                );
              } else {
                await ErrorLogger.logError(
                  title: 'Background Lead Sync - Flag Cleared',
                  errorMessage: 'Successfully cleared is_dirty flag for lead: ${lead.frappeId}, lead_status: ${lead.leadStatus}',
                  errorType: 'Data Sync Debug',
                  userId: currentUser.userId,
                );
              }
            } catch (e) {
              await ErrorLogger.logException(
                context: 'BackgroundSyncService.syncLeads.updateLeadLocalFields',
                exception: e,
                userId: currentUser.userId,
              );
            }
          } else {
            await ErrorLogger.logError(
              title: 'Background Lead Sync Failed',
              errorMessage: 'Failed to sync lead: ${lead.frappeId}',
              errorType: 'Data Sync',
              userId: currentUser.userId,
            );
          }
        } catch (e) {
          final errorMessage = e.toString();
          if (e is SessionExpiredException) {
            // Session expired, stop syncing, notify UI, and log
            await ErrorLogger.logError(
              title: 'Background Sync Stopped - Session Expired',
              errorMessage: 'Session expired during background sync. Stopping sync.',
              errorType: 'Auth',
              userId: currentUser.userId,
            );
            AppStateManager.notifySessionExpired();
            return; // Stop the sync process
          } else if (errorMessage.contains('CONCURRENCY_ERROR') ||
              errorMessage.contains('Document has been modified after you have opened it')) {
            await DatabaseService.instance.leadsRepository.updateLeadLocalFields(
              lead.frappeId,
              isDirty: 0,
              lastModifiedAt: DateTime.now().millisecondsSinceEpoch,
            );
          } else {
            await ErrorLogger.logException(
              context: 'BackgroundSyncService.syncLeads.syncLeadUpdate',
              exception: e,
              userId: currentUser.userId,
            );
          }
        }
      }

      try {
        final apiLeads = await fetchEmployeeLeadsFromApi(currentUser.userId, currentUser.sid);
        final Set<String> apiFrappeIds = apiLeads.map((lead) => lead.frappeId).toSet();

        for (final apiLead in apiLeads) {
          await DatabaseService.instance.leadsRepository.upsertLeadFromApi(apiLead);
        }

        final allLocalLeads = await DatabaseService.instance.leadsRepository.getAllLeads();
        for (final localLead in allLocalLeads) {
          if (localLead.allocationStatus == 'Active' && !apiFrappeIds.contains(localLead.frappeId)) {
            await DatabaseService.instance.leadsRepository.markLeadAsInactive(localLead.frappeId);
          }
        }
      } catch (e) {
        if (e is SessionExpiredException) {
          await ErrorLogger.logError(
            title: 'Background Sync Stopped - Session Expired During Fetch',
            errorMessage: 'Session expired while fetching leads. Stopping sync.',
            errorType: 'Auth',
            userId: currentUser.userId,
          );
          AppStateManager.notifySessionExpired();
          return;
        } else {
          await ErrorLogger.logException(
            context: 'BackgroundSyncService.syncLeads.fetchEmployeeLeadsFromApi',
            exception: e,
            userId: currentUser.userId,
          );
        }
      }

    } catch (e) {
      await ErrorLogger.logException(
        context: 'BackgroundSyncService.syncLeads',
        exception: e,
        userId: currentUser.userId,
      );
    }
  }
}
