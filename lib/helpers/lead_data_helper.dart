
import 'package:credlawn/helpers/local_database_helper.dart';
import 'package:credlawn/models/calling_data_model.dart';
import 'package:credlawn/network/api_calling_data_helper.dart';

// Helper class to combine lead data with call log info
class LeadWithCallInfo {
  final CallingDataModel lead;
  final int callCount;
  final int? lastCallDuration;

  LeadWithCallInfo({required this.lead, required this.callCount, this.lastCallDuration});
}

Future<List<LeadWithCallInfo>> getLeadsWithCallCounts(String userId, String sid) async {
  // First, sync the local DB with the phone's call log
  await LocalDatabaseHelper.instance.syncPhoneCallLogs();

  // Then, fetch the leads from the API
  final leads = await fetchEmployeeLeads(userId, sid);

  // Now, for each lead, get the call count and last call duration from our local DB
  final List<LeadWithCallInfo> leadsWithCallInfo = [];
  for (var lead in leads) {
    final callCount = await LocalDatabaseHelper.instance.getCallCount(lead.mobileNo);
    final lastCallDuration = await LocalDatabaseHelper.instance.getLastCallDuration(lead.mobileNo);
    leadsWithCallInfo.add(LeadWithCallInfo(
      lead: lead,
      callCount: callCount,
      lastCallDuration: lastCallDuration,
    ));
  }
  return leadsWithCallInfo;
}
