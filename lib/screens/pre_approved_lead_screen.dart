// ignore_for_file: library_private_types_in_public_api, unused_field

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:call_log/call_log.dart';
import 'package:credlawn/helpers/call_log_sync_manager.dart';
import 'package:credlawn/helpers/app_state_manager.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/helpers/lead_data_helper.dart';
import '../network/api_calling_data_helper.dart';
import '../models/calling_data_model.dart';
import '../models/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'lead_status_update_screen.dart'; // Import LeadStatusUpdateScreen
import 'customer_details_screen.dart'; // Import CustomerDetailsScreen

import 'package:credlawn/screens/components/lead_list_item.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _leadsFuture = getLeadsWithCallCounts(widget.user.userId, widget.user.sid);
    _searchController.addListener(() {
      _filterLeads();
    });
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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshLeads();
    }
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

  void _callNumber(CallingDataModel lead) async {
    await FlutterPhoneDirectCaller.callNumber(lead.mobileNo);
  }

  void _openWhatsApp(String mobileNo) async {
    final mobileWithCode = '+91$mobileNo';
    final String androidUrl = "whatsapp://send?phone=$mobileWithCode&text=https://cipl.me/tata";
    final String iosUrl = "https://wa.me/$mobileWithCode?text=${Uri.parse('https://cipl.me/tata')}";

    try {
      if (Platform.isIOS) {
        await launchUrl(Uri.parse(iosUrl));
      } else {
        await launchUrl(Uri.parse(androidUrl));
      }
    } catch (e) {
      print("Could not open WhatsApp: $e");
    }
  }

  Future<void> _refreshLeads() async {
    setState(() {
      _allLeads = [];
      _leadsFuture = getLeadsWithCallCounts(widget.user.userId, widget.user.sid);
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'New Lead':
        return Colors.blue;
      case 'CNR':
        return Colors.red;
      default:
        return Colors.grey.shade600;
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
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: FutureBuilder<List<LeadWithCallInfo>>(
        future: _leadsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: SpinKitCircle(color: CustomColor.MainColor));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No leads available.'));
          } else {
            if (_allLeads.isEmpty) {
              _allLeads = snapshot.data!;
              _allLeads.sort((a, b) {
                final statusOrder = {
                  'New Lead': 0,
                  'CNR': 1,
                };
                final aOrder = statusOrder[a.lead.leadStatus] ?? 2;
                final bOrder = statusOrder[b.lead.leadStatus] ?? 2;
                return aOrder.compareTo(bOrder);
              });
              _filteredLeads = _allLeads;
            }
            return RefreshIndicator(
              onRefresh: _refreshLeads,
              child: ListView.builder(
                itemCount: _filteredLeads.length,
                itemBuilder: (context, index) {
                  final leadWithInfo = _filteredLeads[index];
                  return LeadListItem(
                    leadWithInfo: leadWithInfo,
                    isExpanded: _expandedLeadId == leadWithInfo.lead.mobileNo,
                    onTap: () => _expandItem(leadWithInfo.lead.mobileNo),
                  );
                },
              ),
            );
          }
        },
      ),    );
  }
}