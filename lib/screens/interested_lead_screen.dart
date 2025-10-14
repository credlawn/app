// ignore_for_file: unused_field

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:call_log/call_log.dart';
import 'package:credlawn/custom/custom_color.dart';
import '../network/api_calling_data_helper.dart';
import '../models/calling_data_model.dart';
import '../models/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'lead_status_update_screen.dart'; // Import the LeadStatusUpdateScreen

class InterestedLeadsScreen extends StatefulWidget {
  final User user;

  const InterestedLeadsScreen({super.key, required this.user});

  @override
  _InterestedLeadsScreenState createState() => _InterestedLeadsScreenState();
}

class _InterestedLeadsScreenState extends State<InterestedLeadsScreen> {
  late Future<List<CallingDataModel>> _interestedLeads;

  @override
  void initState() {
    super.initState();
    _interestedLeads = fetchInterestedCallingData(widget.user.userId, widget.user.sid, widget.user.designation);
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
      _interestedLeads = fetchInterestedCallingData(widget.user.userId, widget.user.sid, widget.user.designation);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Interested Leads', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
        backgroundColor: CustomColor.MainColor,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshLeads,
              child: FutureBuilder<List<CallingDataModel>>(
                future: _interestedLeads,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SpinKitWaveSpinner(
                          color: Colors.greenAccent.shade700,
                          waveColor: Colors.greenAccent.shade700),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('${snapshot.error}', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.red)));
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
                                vertical: 10, horizontal: 15),
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[100],
                              child: Icon(Icons.person, color: CustomColor.MainColor),
                              
                            ),
                            title: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LeadStatusUpdateScreen(
                                      leadName: lead.name,
                                      customerName: lead.customerName,
                                      mobileNo: lead.mobileNo,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                lead.customerName,
                                style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w500, color: CustomColor.MainColor),
                              ),
                            ),
                            subtitle: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LeadStatusUpdateScreen(
                                      leadName: lead.name,
                                      customerName: lead.customerName,
                                      mobileNo: lead.mobileNo,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                lead.leadStatus,
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.teal),
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
                                  onPressed: () => _openWhatsApp(lead.mobileNo),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.call,
                                    size: 30,
                                    color: Colors.greenAccent.shade700,
                                  ),
                                  onPressed: () => _callNumber(lead),
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
