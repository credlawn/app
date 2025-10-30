
import 'package:credlawn/helpers/database_service.dart';
import 'package:credlawn/models/leads_model.dart';
import 'package:credlawn/network/api_leads_helper.dart';

class LeadWithCallInfo {
  final LeadsModel lead;
  final int callCount;
  final int? lastCallDuration;

  LeadWithCallInfo({required this.lead, required this.callCount, this.lastCallDuration});
}

Future<List<LeadWithCallInfo>> getLeadsWithCallCounts() async {
  await DatabaseService.instance.callHistoryRepository.syncPhoneCallLogs();

  final localLeads = await DatabaseService.instance.leadsRepository.getAllLeads();

  final List<LeadWithCallInfo> leadsWithCallInfo = [];
  for (var lead in localLeads) {
    final callCount = await DatabaseService.instance.callHistoryRepository.getCallCount(lead.mobileNo);
    final lastCallDuration = await DatabaseService.instance.callHistoryRepository.getLastCallDuration(lead.mobileNo);
    leadsWithCallInfo.add(LeadWithCallInfo(
      lead: lead,
      callCount: callCount,
      lastCallDuration: lastCallDuration,
    ));
  }
  return leadsWithCallInfo;
}
