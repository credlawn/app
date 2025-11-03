

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:credlawn/helpers/app_state_manager.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/helpers/lead_data_helper.dart';
import 'package:credlawn/models/leads_model.dart';
import 'package:credlawn/helpers/database_service.dart';
import 'package:credlawn/network/api_leads_helper.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/api/server_api.dart';
import 'package:credlawn/helpers/error_logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:credlawn/helpers/call_log_sync_manager.dart';
import 'package:collection/collection.dart';

import 'package:credlawn/screens/components/lead_list_item.dart';
import 'package:credlawn/screens/components/lead_group_chips.dart';
import 'package:credlawn/screens/components/lead_list.dart';
import 'package:credlawn/screens/components/error_view.dart';
import 'package:credlawn/screens/components/empty_view.dart';
import 'package:credlawn/screens/components/feedback/feedback_bottom_sheet.dart';

class PreApprovedLeadsScreen extends StatefulWidget {
  final User user;

  const PreApprovedLeadsScreen({super.key, required this.user});

  @override
  _PreApprovedLeadsScreenState createState() => _PreApprovedLeadsScreenState();
}

class _PreApprovedLeadsScreenState extends State<PreApprovedLeadsScreen> with WidgetsBindingObserver {
  late Future<List<LeadWithCallInfo>> _leadsFuture;
  String? _expandedLeadId;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<LeadWithCallInfo> _allLeads = [];
  List<LeadWithCallInfo> _filteredLeads = [];
  String _selectedLeadGroup = 'New Leads';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _leadsFuture = _fetchAndSyncLeads();
    _searchController.addListener(() {
      _filterLeads();
    });

    AppStateManager.dirtyLeadNotifier.addListener(_onDirtyLeadNotification);
  }

  void _onDirtyLeadNotification() {
    if (AppStateManager.dirtyLeadNotifier.value) {
      _refreshLeads();
      AppStateManager.dirtyLeadNotifier.value = false;
    }
  }

  void _expandItem(String mobileNo) {
    setState(() {
      if (_expandedLeadId == mobileNo) {
        _expandedLeadId = null;
      } else {
        _expandedLeadId = mobileNo;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    AppStateManager.dirtyLeadNotifier.removeListener(_onDirtyLeadNotification);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshLeads();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _closeExpandedItem();
    }
  }

  void _closeExpandedItem() {
    setState(() {
      _expandedLeadId = null;
    });
  }

  void _filterLeads() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLeads = _allLeads.where((leadWithInfo) {
        final nameMatches = leadWithInfo.lead.customerName.toLowerCase().contains(query);
        final mobileMatches = leadWithInfo.lead.mobileNo.toLowerCase().contains(query);
        return nameMatches || mobileMatches;
      }).toList();
    });
  }

  List<LeadWithCallInfo> _getPendingFeedbackLeads(List<LeadWithCallInfo> allLeads) {
    return allLeads.where((lead) =>
      (lead.callCount ?? 0) > 0 &&
      (lead.lastCallDuration ?? 0) > 0 &&
      !_hasFeedback(lead.lead.leadStatus) &&
      !_isFollowUpLead(lead.lead)
    ).toList();
  }

  void _showMultiplePendingFeedbackDialog(int count, LeadsModel originalLead) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Column(
            children: [
              Icon(Icons.feedback_outlined, color: CustomColor.MainColor, size: 48),
              const SizedBox(height: 10),
              Text(
                'Pending Feedback',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Text.rich(
            TextSpan(
              text: 'You have ',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '$count leads',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade700,
                  ),
                ),
                TextSpan(
                  text: ' pending for feedback.',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Divider(color: Colors.grey.shade200, height: 10),
            const SizedBox(height: 10),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: CustomColor.MainColor.withOpacity(0.1),
              ),
              child: Text(
                'Check Pending Leads',
                style: GoogleFonts.poppins(color: CustomColor.MainColor, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedLeadGroup = 'Called';
                  _expandedLeadId = null;
                });
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.green.withOpacity(0.1),
              ),
              child: Text(
                'Call Anyway',
                style: GoogleFonts.poppins(color: Colors.green.shade700, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _initiateCall(originalLead);
              },
            ),
          ],
        );
      },
    );
  }

  void _initiateCall(LeadsModel lead) async {
    try {
      final currentUser = await SessionManager.getSessionData();
      await ErrorLogger.logError(
        title: 'Call Initiated',
        errorMessage: 'Initiating call to mobile: ${lead.mobileNo}, customer: ${lead.customerName}',
        errorType: 'User Action',
        userId: currentUser?.userId,
      );

      AppStateManager.setPendingFeedbackMobile(lead.mobileNo);
      await FlutterPhoneDirectCaller.callNumber(lead.mobileNo);

      Future.delayed(const Duration(seconds: 5), () async {
        try {
          await _refreshLeads();
          final leadsAfterRefresh = await getLeadsWithCallCounts();
          final updatedLeadWithInfo = leadsAfterRefresh.firstWhereOrNull(
              (l) => l.lead.mobileNo == lead.mobileNo);

          if (updatedLeadWithInfo != null &&
              updatedLeadWithInfo.callCount > 0 &&
              (updatedLeadWithInfo.lastCallDuration ?? 0) > 0 &&
              !_hasFeedback(updatedLeadWithInfo.lead.leadStatus)) {
            await ErrorLogger.logError(
              title: 'Feedback Prompt Triggered',
              errorMessage: 'Showing feedback prompt for mobile: ${lead.mobileNo} after call',
              errorType: 'User Action',
              userId: currentUser?.userId,
            );
            _showFeedbackBottomSheet(updatedLeadWithInfo.lead);
          } else {
            AppStateManager.clearPendingFeedbackMobile();
          }
        } catch (e) {
          final currentUser = await SessionManager.getSessionData();
          await ErrorLogger.logException(
            context: 'PreApprovedLeadsScreen._initiateCall.delayedCallback',
            exception: e,
            userId: currentUser?.userId,
          );
          AppStateManager.clearPendingFeedbackMobile();
        }
      });
    } catch (e) {
      final currentUser = await SessionManager.getSessionData();
      await ErrorLogger.logException(
        context: 'PreApprovedLeadsScreen._initiateCall',
        exception: e,
        userId: currentUser?.userId,
      );
    }
  }

  void _callNumber(LeadsModel lead) async {
    if (_selectedLeadGroup == 'Called') {
      _initiateCall(lead);
      return;
    }

    final pendingLeads = _getPendingFeedbackLeads(_allLeads);

    if (pendingLeads.isEmpty) {
      _initiateCall(lead);
    } else if (pendingLeads.length == 1) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return FeedbackBottomSheet(
            mobileNo: pendingLeads.first.lead.mobileNo,
            onCallAnyway: (mobile) {
              Navigator.of(context).pop();
              _initiateCall(lead);
            },
          );
        },
      ).then((result) {
        if (result == true) {
          _refreshLeads();
        }
        AppStateManager.clearPendingFeedbackMobile();
      });
    } else {
      _showMultiplePendingFeedbackDialog(pendingLeads.length, lead);
    }
  }

  void _showFeedbackBottomSheet(LeadsModel lead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return FeedbackBottomSheet(
          mobileNo: lead.mobileNo,
          onCallAnyway: (mobile) {
            Navigator.of(context).pop();
            _callNumber(lead);
          },
        );
      },
    ).then((result) {
      if (result == true) {
        _refreshLeads();
      }
      AppStateManager.clearPendingFeedbackMobile();
    });
  }

  void _openWhatsApp(LeadsModel lead) async {
    try {
      final mobileWithCode = '+91${lead.mobileNo}';
      final String androidUrl = "whatsapp://send?phone=$mobileWithCode&text=${ServerApi.whatsAppMessageUrl}";
      final String iosUrl = "https://wa.me/$mobileWithCode?text=${Uri.encodeComponent(ServerApi.whatsAppMessageUrl)}";

      final currentUser = await SessionManager.getSessionData();
      await ErrorLogger.logError(
        title: 'WhatsApp Opened',
        errorMessage: 'Opening WhatsApp for mobile: ${lead.mobileNo}',
        errorType: 'User Action',
        userId: currentUser?.userId,
      );

      if (Platform.isIOS) {
        final success = await launchUrl(Uri.parse(iosUrl), mode: LaunchMode.externalApplication);
        if (!success) {
          await ErrorLogger.logError(
            title: 'WhatsApp Launch Failed',
            errorMessage: 'Failed to launch WhatsApp on iOS for mobile: ${lead.mobileNo}',
            errorType: 'External App',
            userId: currentUser?.userId,
          );
        }
      } else {
        final success = await launchUrl(Uri.parse(androidUrl), mode: LaunchMode.externalApplication);
        if (!success) {
          await ErrorLogger.logError(
            title: 'WhatsApp Launch Failed',
            errorMessage: 'Failed to launch WhatsApp on Android for mobile: ${lead.mobileNo}',
            errorType: 'External App',
            userId: currentUser?.userId,
          );
        }
      }
    } catch (e) {
      final currentUser = await SessionManager.getSessionData();
      await ErrorLogger.logException(
        context: 'PreApprovedLeadsScreen._openWhatsApp',
        exception: e,
        userId: currentUser?.userId,
      );
    }
  }

  Future<List<LeadWithCallInfo>> _fetchAndSyncLeads() async {
    final User? currentUser = await SessionManager.getSessionData();
    if (currentUser == null) {
      await ErrorLogger.logError(
        title: 'User Not Logged In',
        errorMessage: 'Attempted to fetch leads without authentication',
        errorType: 'Authentication',
      );
      return Future.error('User not logged in');
    }

    try {
      await ErrorLogger.logError(
        title: 'Lead Sync Started',
        errorMessage: 'Starting lead synchronization for user: ${currentUser.userId}',
        errorType: 'Data Sync',
        userId: currentUser.userId,
      );

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
            await ErrorLogger.logError(
              title: 'Lead Sync Success',
              errorMessage: 'Successfully synced lead: ${lead.frappeId}',
              errorType: 'Data Sync',
              userId: currentUser.userId,
            );
          } else {
            await ErrorLogger.logError(
              title: 'Lead Sync Failed',
              errorMessage: 'Failed to sync lead: ${lead.frappeId}',
              errorType: 'Data Sync',
              userId: currentUser.userId,
            );
          }
        } catch (e) {
          await ErrorLogger.logException(
            context: 'PreApprovedLeadsScreen._fetchAndSyncLeads.syncLeadUpdate',
            exception: e,
            userId: currentUser.userId,
          );
        }
      }

      final apiLeads = await fetchEmployeeLeadsFromApi(currentUser.userId, currentUser.sid);
      final Set<String> apiFrappeIds = apiLeads.map((lead) => lead.frappeId).toSet();

      // Upsert all leads from the server first
      for (final apiLead in apiLeads) {
        await DatabaseService.instance.leadsRepository.upsertLeadFromApi(apiLead);
      }

      // Now, get the full list of local leads and mark the inactive ones
      final allLocalLeads = await DatabaseService.instance.leadsRepository.getAllLeads();
      for (final localLead in allLocalLeads) {
        if (localLead.allocationStatus == 'Active' && !apiFrappeIds.contains(localLead.frappeId)) {
          await DatabaseService.instance.leadsRepository.markLeadAsInactive(localLead.frappeId);
        }
      }

      final leadsForDisplay = await getLeadsWithCallCounts();
      await ErrorLogger.logError(
        title: 'Lead Sync Completed',
        errorMessage: 'Successfully synced ${leadsForDisplay.length} leads for user: ${currentUser.userId}',
        errorType: 'Data Sync',
        userId: currentUser.userId,
      );

      return leadsForDisplay;
    } on Exception catch (e) {
      final currentUser = await SessionManager.getSessionData();
      await ErrorLogger.logException(
        context: 'PreApprovedLeadsScreen._fetchAndSyncLeads',
        exception: e,
        userId: currentUser?.userId,
      );
      // If API fetch fails, still try to display local leads
      final leadsForDisplay = await getLeadsWithCallCounts();
      return leadsForDisplay;
    }
  }

  Future<void> _refreshLeads() async {
    setState(() {
      _allLeads = [];
      _leadsFuture = _fetchAndSyncLeads();
    });
  }

  bool _hasFeedback(String? leadStatus) {
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

  bool _isFollowUpLead(LeadsModel lead) {
    return lead.leadStatus == 'Follow up' && lead.followUpDate != null;
  }

  List<LeadWithCallInfo> _getFilteredLeadsByGroup(List<LeadWithCallInfo> leads) {
    switch (_selectedLeadGroup) {
      case 'New Leads':
        return leads.where((lead) =>
          lead.callCount == 0 &&
          !_hasFeedback(lead.lead.leadStatus) &&
          !_isFollowUpLead(lead.lead)
        ).toList();
      case 'CNR Leads':
        return leads.where((lead) =>
          (lead.lastCallDuration ?? 0) == 0 &&
          (lead.callCount ?? 0) > 0 &&
          !_hasFeedback(lead.lead.leadStatus) &&
          !_isFollowUpLead(lead.lead)
        ).toList();
      case 'Used Leads':
        return leads.where((lead) => _hasFeedback(lead.lead.leadStatus)).toList();
      case 'Follow Up':
        return leads.where((lead) => _isFollowUpLead(lead.lead)).toList();
      case 'Called':
        return leads.where((lead) =>
          (lead.callCount ?? 0) > 0 &&
          (lead.lastCallDuration ?? 0) > 0 &&
          !_hasFeedback(lead.lead.leadStatus) &&
          !_isFollowUpLead(lead.lead)
        ).toList();
      default:
        return leads;
    }
  }

  AppBar _buildAppBar() {
    if (_isSearching) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by name or mobile...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: () {
              _searchController.clear();
            },
          ),
        ],
        backgroundColor: CustomColor.MainColor,
      );
    } else {
      return AppBar(
        title: Text('Pre Approved Leads', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
        backgroundColor: CustomColor.MainColor,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: FutureBuilder<List<LeadWithCallInfo>>(
        future: _leadsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: SpinKitCircle(color: CustomColor.MainColor, size: 50));
          } else if (snapshot.hasError) {
            return ErrorView(
              errorMessage: 'Error: ${snapshot.error}',
              onRetry: _refreshLeads,
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return EmptyView(
              message: 'No leads available.',
              onRefresh: _refreshLeads,
            );
          } else {
            _allLeads = snapshot.data!;
            _filteredLeads = _allLeads;

            final filteredLeads = _getFilteredLeadsByGroup(_filteredLeads);

            return RefreshIndicator(
              onRefresh: _refreshLeads,
              child: ListView(
                padding: const EdgeInsets.only(top: 8),
                children: [
                  LeadGroupChips(
                    selectedGroup: _selectedLeadGroup,
                    onGroupSelected: (group) {
                      setState(() {
                        _selectedLeadGroup = group;
                      });
                    },
                  ),
                  if (filteredLeads.isNotEmpty)
                    LeadList(
                      leads: filteredLeads,
                      expandedLeadId: _expandedLeadId,
                      onExpandItem: _expandItem,
                      onNavigate: _closeExpandedItem,
                      onCallPressed: _callNumber,
                    )
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 32.0),
                        child: Text(
                          'No leads available in this category.',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
