import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:credlawn/custom/mobile_field.dart';
import 'package:credlawn/custom/customer_name_field.dart';
import 'package:credlawn/custom/reference_field.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/network/api_network.dart';
import 'package:credlawn/network/api_profile_helper.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/models/profile_model.dart';
import 'today_login_list_screen.dart';

class NewCardLoginScreen extends StatefulWidget {
  const NewCardLoginScreen({super.key});

  @override
  State<NewCardLoginScreen> createState() => _NewCardLoginScreenState();
}

class _NewCardLoginScreenState extends State<NewCardLoginScreen> {
  bool _isLoading = false;
  final _customerNameController = TextEditingController();
  final _mobileNoController = TextEditingController();
  final _panNoController = TextEditingController();
  final _referenceNoController = TextEditingController();

  String? selectIpStatus, selectKycStatus, selectIncompleteReason, selectIpRejectedReason;
  List<String> ipStatus = ['IP Approved', 'IP Rejected', 'Incomplete Journey'];
  List<String> kycStatus = ['VKYC Success', 'VKYC Pending', 'BKYC'];
  List<String> incompleteReason = ['Docs Not Available', 'Customer Denied'];
  List<String> ipRejectedReason = ['Recently Applied', 'No Offer'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: CustomColor.MainColor,
        title: Text('New Card Login', style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomerNameField(controller: _customerNameController, enable: true),
                  SizedBox(height: 15),
                  MobileField(controller: _mobileNoController, label: 'Mobile No'),
                  SizedBox(height: 15),
                  _buildDropdown(ipStatus, 'Select IP Status', selectIpStatus, (value) {
                    setState(() {
                      selectIpStatus = value;
                      selectKycStatus = null;
                      selectIncompleteReason = null;
                      selectIpRejectedReason = null;
                      _referenceNoController.clear();
                    });
                  }),
                  SizedBox(height: 15),
                  if (selectIpStatus == 'IP Approved') 
                    _buildDropdown(kycStatus, 'Select KYC Status', selectKycStatus, (value) {
                      setState(() {
                        selectKycStatus = value;
                      });
                    }),
                  if (selectIpStatus == 'Incomplete Journey') 
                    _buildDropdown(incompleteReason, 'Select Incomplete Reason', selectIncompleteReason, (value) {
                      setState(() {
                        selectIncompleteReason = value;
                      });
                    }),
                  if (selectIpStatus == 'IP Rejected')
                    _buildDropdown(ipRejectedReason, 'Select Rejection Reason', selectIpRejectedReason, (value) {
                      setState(() {
                        selectIpRejectedReason = value;
                      });
                    }), 
                  SizedBox(height: 15),
                  if (selectIpStatus == 'IP Approved' && selectKycStatus != null)
                    ReferenceNoField(controller: _referenceNoController, enable: true),

                  SizedBox(height: 20),
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

  Future<void> submitDataToServer() async {
    if (_customerNameController.text.isEmpty) {
      return CustomColor.showErrorSnackBar(context, 'Please enter Customer Full Name');
    }

    if (_mobileNoController.text.length < 10) {
      return CustomColor.showErrorSnackBar(context, 'Please enter correct mobile number');
    }

    if (selectIpStatus?.isEmpty ?? true) {
      return CustomColor.showErrorSnackBar(context, 'Please select IP Status');
    }

    if (selectIpStatus == 'IP Approved' && (selectKycStatus?.isEmpty ?? true)) {
      return CustomColor.showErrorSnackBar(context, 'Please select KYC Status');
    }

    if (selectIpStatus == 'IP Approved' && _referenceNoController.text.length != 16) {
      return CustomColor.showErrorSnackBar(context, 'Please enter correct Reference No');
    }

    if (selectIpStatus == 'Incomplete Journey' && (selectIncompleteReason?.isEmpty ?? true)) {
      return CustomColor.showErrorSnackBar(context, 'Please select Incomplete Reason');
    }

    if (selectIpStatus == 'IP Rejected' && (selectIpRejectedReason?.isEmpty ?? true)) {
      return CustomColor.showErrorSnackBar(context, 'Please select Rejection Reason');
    }

    setState(() {
      _isLoading = true;
    });


    try {
      final url = Uri.parse(ApiNetwork.newCardLogin);

      final body = {
        'customer_name': _customerNameController.text,
        'mobile_no': _mobileNoController.text,
        'pan_no': _panNoController.text,
        'reference_no': _referenceNoController.text,
        'ip_status': selectIpStatus,
        'kyc_status': selectKycStatus,
        'incomplete_reason': selectIncompleteReason,
        'rejection_reason': selectIpRejectedReason,
      };

      User? user = await SessionManager.getSessionData();
      if (user == null) {
        CustomColor.showErrorSnackBar(context, 'Please log out & log in again.');
        return;
      }

      String sid = user.sid;
      String userId = user.userId;

      ProfileModel? profile = await fetchProfileData(userId, sid);
      body['employee_code'] = profile.employeeCode;
    
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'sid=$sid',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        CustomColor.showSuccessSnackBar(context, 'Data Submitted Successfully');

        Future.delayed(Duration(milliseconds: 300), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TodayLoginListScreen(user: user)),
          );
        });
      } else {
        CustomColor.showErrorSnackBar(context, 'Please log out & log in again');
        return;
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
