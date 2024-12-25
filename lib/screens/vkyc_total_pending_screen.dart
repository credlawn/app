// ignore_for_file: unused_field

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:credlawn/custom/custom_color.dart';
import '../network/api_adobe_database_helper.dart';
import '../models/adobe_database_model.dart';
import '../models/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'lead_status_update_screen.dart';
import 'package:intl/intl.dart';

class VkycTotalPendingScreen extends StatefulWidget {
  final User user;

  const VkycTotalPendingScreen({super.key, required this.user});

  @override
  _VkycTotalPendingScreenState createState() => _VkycTotalPendingScreenState();
}

class _VkycTotalPendingScreenState extends State<VkycTotalPendingScreen>
    with WidgetsBindingObserver {
  late Future<List<AdobeDatabaseModel>> _vkycTotalPending;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _vkycTotalPending = fetchTotalPendingVkyc(
        widget.user.userId, widget.user.sid, widget.user.designation);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _callNumber(String mobileNo) async {
    await FlutterPhoneDirectCaller.callNumber(mobileNo);
  }

  void _openWhatsApp(String mobileNo, String vkycLink) async {
    final mobileWithCode = '+91$mobileNo';
    final String androidUrl = "whatsapp://send?phone=$mobileWithCode&text=$vkycLink";
    final String iosUrl =
        "https://wa.me/$mobileWithCode?text=${Uri.encodeComponent(vkycLink)}";

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
      _vkycTotalPending = fetchTotalPendingVkyc(
          widget.user.userId, widget.user.sid, widget.user.designation);
    });
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final DateTime date =
          DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateString);
      return DateFormat('dd-MMM-yyyy hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('VKYC Total Pending',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
        backgroundColor: CustomColor.MainColor,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshLeads,
              child: FutureBuilder<List<AdobeDatabaseModel>>(
                future: _vkycTotalPending,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SpinKitWaveSpinner(
                          color: Colors.greenAccent.shade700,
                          waveColor: Colors.greenAccent.shade700),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('${snapshot.error}',
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.red)));
                  } else {
                    final leads = snapshot.data!;
                    return ListView.builder(
                      itemCount: leads.length,
                      itemBuilder: (context, index) {
                        final lead = leads[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                spreadRadius: 0.5,
                                blurRadius: 0.5,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[100],
                              child: Icon(Icons.person,
                                  color: CustomColor.MainColor),
                            ),
                            title: InkWell(
                              onTap: () {
                                // Navigate to LeadStatusUpdateScreen and pass the name
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LeadStatusUpdateScreen(
                                      leadName: lead.name, // Pass the lead name here
                                      customerName: lead.customerName,
                                      mobileNo: lead.mobileNo,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                lead.customerName,
                                style: GoogleFonts.poppins(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: CustomColor.MainColor),
                              ),
                            ),
                            subtitle: InkWell(
                              onTap: () {
                                // Navigate to LeadStatusUpdateScreen when the lead status is tapped
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LeadStatusUpdateScreen(
                                      leadName: lead.name, // Pass the lead name here
                                      customerName: lead.customerName,
                                      mobileNo: lead.mobileNo,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                _formatDate(lead.vkycExpireDate),
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.chat,
                                    size: 22,
                                    color: Colors.greenAccent.shade700,
                                  ),
                                  onPressed: () =>
                                      _openWhatsApp(lead.mobileNo, lead.vkycLink),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.call,
                                    size: 30,
                                    color: Colors.greenAccent.shade700,
                                  ),
                                  onPressed: () => _callNumber(lead.mobileNo),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
