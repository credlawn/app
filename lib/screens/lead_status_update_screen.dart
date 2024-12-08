// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, unused_local_variable

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/network/api_network.dart';
import 'package:http/http.dart' as http;
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';

class LeadStatusUpdateScreen extends StatefulWidget {
  final String leadName;
  final String customerName;
  final String mobileNo;

  const LeadStatusUpdateScreen({super.key, required this.leadName, required this.customerName, required this.mobileNo});

  @override

  _LeadStatusUpdateScreenState createState() => _LeadStatusUpdateScreenState();
}

class _LeadStatusUpdateScreenState extends State<LeadStatusUpdateScreen> {
  bool _isLoading = false;
  String? selectedLeadStatus;
  DateTime? followUpDate;
  final List<String> leadStatusOptions = [
    'Login Done',
    'CNR',
    'Not Interested',
    'Follow-up',
    'Already Carded'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: CustomColor.MainColor,
        title: Text('Update Lead Status', style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Customer Name: ${widget.customerName}\n\nMobile Number: ${widget.mobileNo}',
                      style: GoogleFonts.poppins(fontSize: 15, color: CustomColor.MainColor),
                    ),
                  ),
                  SizedBox(height: 30),
                  _buildDropdown(leadStatusOptions, 'Select Lead Status', selectedLeadStatus, (value) {
                    setState(() {
                      selectedLeadStatus = value;
                    });
                  }),
                  SizedBox(height: 15),
                  if (selectedLeadStatus == 'Follow-up') 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: GestureDetector(
                        onTap: () => _selectFollowUpDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: CustomColor.MainColor),
                          ),
                          child: Row(
                            children: [
                              Text(
                                followUpDate == null ? 'Select Follow-up Date' : '${followUpDate!.toLocal()}'.split(' ')[0],
                                style: GoogleFonts.poppins(fontSize: 16, color: CustomColor.MainColor),
                              ),
                              Spacer(),
                              Icon(Icons.calendar_today, color: CustomColor.MainColor),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 30),
                  CustomColor.customButton(
                    context: context,
                    text: 'Submit',
                    onPressed: () async {
                      await submitDataToServer();
                    },
                  ),
                ],
              ),
            ),
            CustomColor.showFullScreenLoading(isLoading: _isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String hint, String? value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: CustomColor.MainColor),
      ),
      child: DropdownButton<String>(
        underline: SizedBox(),
        isExpanded: true,
        value: value,
        hint: Text(hint, style: GoogleFonts.poppins(fontSize: 16, color: CustomColor.MainColor)),
        onChanged: onChanged,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(item, style: GoogleFonts.poppins(fontSize: 16)),
            ),
          );
        }).toList(),
        dropdownColor: Colors.white,
      ),
    );
  }

  Future<void> _selectFollowUpDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime oneYearFromToday = today.add(Duration(days: 365));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: followUpDate ?? today,
      firstDate: today,
      lastDate: oneYearFromToday,
    );

    if (pickedDate != null && pickedDate != followUpDate) {
      setState(() {
        followUpDate = pickedDate;
      });
    }
  }

  Future<void> submitDataToServer() async {
    if (selectedLeadStatus?.isEmpty ?? true) {
      return CustomColor.showErrorSnackBar(context, 'Please select Lead Status');
    }

    if (selectedLeadStatus == 'Follow-up' && followUpDate == null) {
      return CustomColor.showErrorSnackBar(context, 'Please select Follow-up Date');
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('${ApiNetwork.updateLeadStatus}/${widget.leadName}');

      // Format follow_up_date as string in 'YYYY-MM-DD' format
      final followUpDateString = followUpDate != null ? followUpDate!.toLocal().toString().split(' ')[0] : '';

      final body = {
        'lead_status': selectedLeadStatus,
        'follow_up_date': followUpDateString,
      };

      User? user = await SessionManager.getSessionData();
      if (user == null) {
        CustomColor.showErrorSnackBar(context, 'Please log out & log in again.');
        return;
      }
      String sid = user.sid;
      String userId = user.userId;

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'sid=$sid',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        CustomColor.showSuccessSnackBar(context, 'Lead Status Updated Successfully');
        Navigator.pop(context);
      } else {
        CustomColor.showErrorSnackBar(context, 'Please log out & log in again.');
      }
    } catch (e) {
      CustomColor.showErrorSnackBar(context, 'Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}