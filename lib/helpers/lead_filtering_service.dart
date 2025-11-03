import 'package:credlawn/helpers/database_service.dart';
import 'package:credlawn/models/leads_model.dart';
import 'package:credlawn/helpers/lead_data_helper.dart';

class LeadFilteringService {
  static Future<List<LeadWithCallInfo>> getFilteredLeadsByGroup(
    List<LeadWithCallInfo> leads,
    String selectedGroup
  ) async {
    switch (selectedGroup) {
      case 'New Leads':
        return leads.where((lead) =>
          lead.callCount == 0 &&
          !_hasFeedback(lead.lead.leadStatus) &&
          !_isFollowUpLead(lead.lead)
        ).toList();

      case 'CNR Leads':
        final filteredLeads = <LeadWithCallInfo>[];
        for (final lead in leads) {
          if (_hasFeedback(lead.lead.leadStatus) || _isFollowUpLead(lead.lead)) {
            continue;
          }

          final hasRecentSuccess = await DatabaseService.instance.callHistoryRepository
              .hasRecentSuccessfulCall(lead.lead.mobileNo, 3);
          final recentFailedCount = await DatabaseService.instance.callHistoryRepository
              .countRecentFailedCalls(lead.lead.mobileNo, hasRecentSuccess ? 4 : 3);

          final shouldInclude = lead.callCount > 0 && (
            !hasRecentSuccess && recentFailedCount >= 3 ||
            hasRecentSuccess && recentFailedCount >= 4
          );

          if (shouldInclude) {
            filteredLeads.add(lead);
          }
        }
        return filteredLeads;

      case 'Called':
        final filteredLeads = <LeadWithCallInfo>[];
        for (final lead in leads) {
          if (_hasFeedback(lead.lead.leadStatus) || _isFollowUpLead(lead.lead)) {
            continue;
          }

          final hasRecentSuccess = await DatabaseService.instance.callHistoryRepository
              .hasRecentSuccessfulCall(lead.lead.mobileNo, 3);
          if (!hasRecentSuccess) continue;

          final recentFailedCount = await DatabaseService.instance.callHistoryRepository
              .countRecentFailedCalls(lead.lead.mobileNo, 3);

          if (recentFailedCount < 3) {
            filteredLeads.add(lead);
          }
        }
        return filteredLeads;

      case 'Failed':
        return leads.where((lead) =>
          ['Customer Denied', 'Docs Not Available', 'Already Carded', 'Recently Applied'].contains(lead.lead.leadStatus)
        ).toList();

      case 'Login':
        return leads.where((lead) =>
          lead.lead.leadStatus == 'IP Approved' || lead.lead.leadStatus == 'IP Decline'
        ).toList();

      case 'Follow Up':
        return leads.where((lead) => _isFollowUpLead(lead.lead)).toList();

      default:
        return leads;
    }
  }

  static bool _hasFeedback(String? leadStatus) {
    if (leadStatus == null || leadStatus.trim().isEmpty) {
      return false;
    }

    final feedbackStatuses = [
      'IP Approved',
      'IP Decline',
      'Customer Denied',
      'Docs Not Available',
      'Already Carded',
      'Recently Applied',
      'CNR',
    ];

    return feedbackStatuses.contains(leadStatus);
  }

  static bool _isFollowUpLead(LeadsModel lead) {
    return lead.leadStatus == 'Follow up' && lead.followUpDate != null;
  }
}
