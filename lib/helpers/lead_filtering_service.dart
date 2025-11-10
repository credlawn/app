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
      return leads.where((lead) => lead.lead.leadStatus == 'New').toList();

      case 'CNR':
        return leads.where((lead) =>
          lead.lead.leadStatus == 'CNR' || lead.lead.leadStatus == 'Voicemail'
        ).toList();

      case 'Inactive':
        return leads.where((lead) => lead.lead.leadStatus == 'Inactive').toList();

      case 'Called':
        return leads.where((lead) =>
          lead.lead.leadStatus == 'Called' ||
          lead.lead.leadStatus == 'Hold'
        ).toList();

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

  static bool _isHoldLeadOlderThan2Days(LeadsModel lead) {
    if (lead.leadStatus != 'Hold' || lead.leadStatusDate == null) {
      return false;
    }

    try {
      final statusDate = DateTime.parse(lead.leadStatusDate!);
      final now = DateTime.now();
      final difference = now.difference(statusDate).inDays;

      return difference > 2;
    } catch (e) {
      // If date parsing fails, don't treat as old
      return false;
    }
  }
}
