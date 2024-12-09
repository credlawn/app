// ignore_for_file: library_private_types_in_public_api, unused_field

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
import 'lead_status_update_screen.dart'; // Import LeadStatusUpdateScreen

class PreApprovedLeadsScreen extends StatefulWidget {
  final User user;

  const PreApprovedLeadsScreen({super.key, required this.user});

  @override
  _PreApprovedLeadsScreenState createState() => _PreApprovedLeadsScreenState();
}

class _PreApprovedLeadsScreenState extends State<PreApprovedLeadsScreen> with WidgetsBindingObserver {
  late Future<List<CallingDataModel>> _preApprovedLeads;
  late String _lastCallDuration;
  bool _isLoading = false;
  bool _isCallLogFetched = false;

  @override
  void initState() {
    super.initState();
    _preApprovedLeads = fetchPreApprovedCallingData(widget.user.userId, widget.user.sid, widget.user.designation);
    _lastCallDuration = '';
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Future.delayed(Duration(seconds: 2), () {
        _fetchLastCallDuration();
      });
    }
  }

  void _callNumber(String mobileNo) async {
    await FlutterPhoneDirectCaller.callNumber(mobileNo);
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

  Future<void> _fetchLastCallDuration() async {
    setState(() {
      _isLoading = true;
    });

    final Iterable<CallLogEntry> logs = await CallLog.query(
      dateFrom: DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch,
    );

    final latestCall = logs.firstWhere(
      (log) => log.duration != null,
      orElse: () => CallLogEntry(),
    );

    if (latestCall.duration != null) {
      final formattedDuration = _formatDuration(latestCall.duration!);
      setState(() {
        _lastCallDuration = formattedDuration;
        _isLoading = false;
        _isCallLogFetched = true;
      });
    }
  }

  String _formatDuration(int durationInSeconds) {
    final minutes = (durationInSeconds / 60).floor();
    final seconds = durationInSeconds % 60;
    return '$minutes minutes $seconds seconds';
  }

  void _showCallDurationPopup() {
    if (_isCallLogFetched) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Call Duration"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Duration: $_lastCallDuration'),
                SizedBox(height: 10),
                Text('Would you like to submit this call data?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _submitCallData();
                  Navigator.pop(context);
                },
                child: Text("Submit"),
              ),
            ],
          );
        },
      );
    }
  }

  void _submitCallData() {
    print("Call data submitted: $_lastCallDuration");
  }

  Future<void> _refreshLeads() async {
    setState(() {
      _preApprovedLeads = fetchPreApprovedCallingData(widget.user.userId, widget.user.sid, widget.user.designation);
    });
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
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshLeads,
              child: FutureBuilder<List<CallingDataModel>>(
                future: _preApprovedLeads,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SpinKitWaveSpinner(
                          color: Colors.greenAccent.shade700,
                          waveColor: Colors.greenAccent.shade700),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No Pre Approved leads available.'));
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
