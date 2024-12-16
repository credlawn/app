import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/network/api_network.dart';
import 'package:http/http.dart' as http;
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/custom/reference_field.dart';

class LeadStatusUpdateScreen extends StatefulWidget {
  final String leadName;
  String customerName;  // Changed to mutable
  final String mobileNo;

  final _referenceNoController = TextEditingController();

  LeadStatusUpdateScreen({
    super.key,
    required this.leadName,
    required this.customerName,
    required this.mobileNo,
  });

  @override
  _LeadStatusUpdateScreenState createState() => _LeadStatusUpdateScreenState();
}

class _LeadStatusUpdateScreenState extends State<LeadStatusUpdateScreen> {
  bool _isLoading = false;
  bool _isEditingCustomerName = false;
  String _editableCustomerName = '';
  TextEditingController _customerNameController = TextEditingController();

  // Selected values for dropdowns
  String? selectedLeadStatus;
  String? selectedIpStatus;
  String? selectedKycStatus;
  String? selectedRejectionReason;
  String? selectedIncompleteReason;
  DateTime? followUpDate;

  // Dropdown options for each field
  final List<String> leadStatusOptions = [
    'Login Done',
    'CNR',
    'Not Interested',
    'Follow-up',
    'Already Carded'
  ];

  final List<String> ipStatusOptions = [
    'IP Approved',
    'IP Rejected',
    'Incomplete Journey'
  ];

  final List<String> kycStatusOptions = [
    'VKYC Success',
    'VKYC Pending',
    'BKYC'
  ];

  final List<String> rejectionReasonOptions = [
    'Recently Applied',
    'No Offer'
  ];

  final List<String> incompleteReasonOptions = [
    'Docs Not Available',
    'Customer Denied'
  ];

  @override
  void initState() {
    super.initState();
    _editableCustomerName = widget.customerName;
    _customerNameController = TextEditingController(text: widget.customerName); 
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: CustomColor.MainColor,
        title: Text(
          'Update Lead Status',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Displaying Customer Name, Mobile Number with Edit Icon
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        // Editable Customer Name
                        Expanded(
                          child: _isEditingCustomerName
                              ? TextField(
                                  cursorColor: CustomColor.MainColor,
                                  controller: _customerNameController,  // Use the controller to bind to the TextField
                                  style: GoogleFonts.poppins(fontSize: 15, color: CustomColor.MainColor),
                                  onChanged: (value) {
                                    setState(() {
                                      _editableCustomerName = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Customer Name",
                                    border: OutlineInputBorder(borderSide: BorderSide(color: CustomColor.MainColor, width: 2.0)),
                                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: CustomColor.MainColor, width: 2.0)),
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: CustomColor.MainColor, width: 2.0)),
                                  ),
                                )
                              : Text(
                                  'Customer Name: $_editableCustomerName',
                                  style: GoogleFonts.poppins(fontSize: 15, color: CustomColor.MainColor),
                                ),
                        ),
                        // Edit Icon
                        IconButton(
                          icon: Icon(
                            _isEditingCustomerName ? Icons.check : Icons.edit,
                            color: CustomColor.MainColor,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_isEditingCustomerName) {
                                // Update widget's customerName after editing
                                widget.customerName = _editableCustomerName;
                              }
                              _isEditingCustomerName = !_isEditingCustomerName;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),

                  // Display Mobile Number (Non-editable)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Mobile No: ${widget.mobileNo}',
                          style: GoogleFonts.poppins(fontSize: 15, color: CustomColor.MainColor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),

                  // Dropdown for Lead Status
                  _buildDropdown(
                    leadStatusOptions,
                    'Select Lead Status',
                    selectedLeadStatus,
                    (value) {
                      setState(() {
                        selectedLeadStatus = value;

                        // Reset all dependent dropdowns when Lead Status changes
                        selectedIpStatus = null;
                        selectedKycStatus = null;
                        selectedRejectionReason = null;
                        selectedIncompleteReason = null;
                        followUpDate = null;
                        widget._referenceNoController.clear();
                      });
                    },
                  ),
                  SizedBox(height: 15),

                  // Conditional rendering of other dropdowns based on Lead Status selection
                  if (selectedLeadStatus == 'Login Done') 
                    _buildDropdown(
                      ipStatusOptions,
                      'Select IP Status',
                      selectedIpStatus,
                      (value) {
                        setState(() {
                          selectedIpStatus = value;

                          // Reset dependent dropdowns based on IP Status selection
                          selectedKycStatus = null;
                          selectedRejectionReason = null;
                          selectedIncompleteReason = null;
                        });
                      },
                    ),
                  SizedBox(height: 15),

                  // Show KYC Status dropdown if IP Approved is selected
                  if (selectedIpStatus == 'IP Approved') 
                    _buildDropdown(
                      kycStatusOptions,
                      'Select KYC Status',
                      selectedKycStatus,
                      (value) {
                        setState(() {
                          selectedKycStatus = value;
                        });
                      },
                    ),
                  
                  // Show Rejection Reason dropdown if IP Rejected is selected
                  if (selectedIpStatus == 'IP Rejected') 
                    _buildDropdown(
                      rejectionReasonOptions,
                      'Select Rejection Reason',
                      selectedRejectionReason,
                      (value) {
                        setState(() {
                          selectedRejectionReason = value;
                        });
                      },
                    ),

                  // Show Incomplete Reason dropdown if Incomplete Journey is selected
                  if (selectedIpStatus == 'Incomplete Journey') 
                    _buildDropdown(
                      incompleteReasonOptions,
                      'Select Incomplete Reason',
                      selectedIncompleteReason,
                      (value) {
                        setState(() {
                          selectedIncompleteReason = value;
                        });
                      },
                    ),
                  
                  SizedBox(height: 15),
                  if (selectedIpStatus == 'IP Approved' && selectedKycStatus != null)
                    ReferenceNoField(controller: widget._referenceNoController, enable: true),
                  
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

                  // Submit Button
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
        hint: Text(
          hint,
          style: GoogleFonts.poppins(fontSize: 16, color: CustomColor.MainColor),
        ),
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

  // Submit data to the server (kept as is)
  Future<void> submitDataToServer() async {
    if (selectedLeadStatus?.isEmpty ?? true) {
      return CustomColor.showErrorSnackBar(context, 'Please select Lead Status');
    }

    // Follow-up Date validation for "Follow-up" status
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
      final referenceNo = widget._referenceNoController.text;

      final body = {
        'lead_status': selectedLeadStatus,
        'follow_up_date': followUpDateString,
        'ip_status': selectedIpStatus,
        'kyc_status': selectedKycStatus,
        'rejection_reason': selectedRejectionReason,
        'incomplete_reason': selectedIncompleteReason,
        'customer_name': _editableCustomerName,
        'reference_no': referenceNo,

      };

      // Get user session info
      User? user = await SessionManager.getSessionData();
      if (user == null) {
        CustomColor.showErrorSnackBar(context, 'Please log out & log in again.');
        return;
      }

      String sid = user.sid;
      String userId = user.userId;

      // Send PUT request to the server
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'sid=$sid',
        },
        body: json.encode(body),
      );

      // Handle server response
      if (response.statusCode == 200) {
        CustomColor.showSuccessSnackBar(context, 'Lead Status Updated Successfully');
        Navigator.pop(context);
      } else {
        CustomColor.showErrorSnackBar(context, 'Error updating lead status. Please try again.');
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
