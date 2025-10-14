// ignore_for_file: library_private_types_in_public_api, unused_field

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:call_log/call_log.dart';
import 'package:credlawn/helpers/call_log_sync_manager.dart';
import 'package:credlawn/custom/custom_color.dart';
import '../network/api_calling_data_helper.dart';
import '../models/calling_data_model.dart';
import '../models/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'lead_status_update_screen.dart'; // Import LeadStatusUpdateScreen
import 'customer_details_screen.dart'; // Import CustomerDetailsScreen

class PreApprovedLeadsScreen extends StatefulWidget {
  final User user;

  const PreApprovedLeadsScreen({super.key, required this.user});

  @override
  _PreApprovedLeadsScreenState createState() => _PreApprovedLeadsScreenState();
}

class _PreApprovedLeadsScreenState extends State<PreApprovedLeadsScreen> {
  late Future<List<CallingDataModel>> _employeeLeads;

  @override
  void initState() {
    super.initState();
    _employeeLeads = fetchEmployeeLeads(widget.user.userId, widget.user.sid);
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
      _employeeLeads = fetchEmployeeLeads(widget.user.userId, widget.user.sid);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Pre Approved Leads', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
        backgroundColor: CustomColor.MainColor,
        elevation: 0.5,
      ),
      body: FutureBuilder<List<CallingDataModel>>(
        future: _employeeLeads,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: SpinKitCircle(color: CustomColor.MainColor));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No leads available.'));
          } else {
            final leads = snapshot.data!;
            leads.sort((a, b) {
              final statusOrder = {
                'New Lead': 0,
                'CNR': 1,
              };
              final aOrder = statusOrder[a.leadStatus] ?? 2;
              final bOrder = statusOrder[b.leadStatus] ?? 2;
              return aOrder.compareTo(bOrder);
            });
            return RefreshIndicator(
              onRefresh: _refreshLeads,
              child: ListView.builder(
                itemCount: leads.length,
                itemBuilder: (context, index) {
                  final lead = leads[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    elevation: 1,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      title: Text(
                        lead.customerName,
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lead.leadStatus,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(lead.leadStatus),
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.message, color: Colors.blue, size: 22),
                            onPressed: () => _openWhatsApp(lead.mobileNo),
                          ),
                          IconButton(
                            icon: const Icon(Icons.call, color: Colors.green, size: 22),
                            onPressed: () => _callNumber(lead),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomerDetailsScreen(
                              mobileNo: lead.mobileNo,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }
        },
      ),    );
  }
}