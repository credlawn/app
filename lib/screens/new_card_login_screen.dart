import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/mobile_field.dart';
import 'package:credlawn/custom/customer_name_field.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/helpers/ocr_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:credlawn/helpers/database_service.dart';
import 'package:credlawn/models/case_login_model.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';


class NewCardLoginScreen extends StatefulWidget {
  const NewCardLoginScreen({super.key});

  @override
  State<NewCardLoginScreen> createState() => _NewCardLoginScreenState();
}

class _NewCardLoginScreenState extends State<NewCardLoginScreen> {
  bool _isLoading = false;
  final _customerNameController = TextEditingController();
  final _mobileNoController = TextEditingController();
  final _referenceNoController = TextEditingController(); // For ARN No

  String? selectedStatus;
  final TextEditingController _remarksController = TextEditingController();

  // Updated statusOptions - removed 'CNR', 'Follow up'
  final List<String> statusOptions = [
    'IP Approved',
    'IP Decline',
    'Customer Denied',
    'Docs Not Available',
    'Already Carded',
    'Recently Applied',
  ];

  @override
  void dispose() {
    _customerNameController.dispose();
    _mobileNoController.dispose();
    _referenceNoController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: CustomColor.MainColor,
        title: Text('New Case Login', style: GoogleFonts.poppins(color: Colors.white)), // Changed title
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomerNameField(controller: _customerNameController, enable: true),
                    SizedBox(height: 15),
                    MobileField(controller: _mobileNoController, label: 'Mobile No'),
                    SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Status',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedStatus,
                      hint: const Text('Select Status'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedStatus = newValue;
                          _remarksController.clear();
                          _referenceNoController.clear();
                        });
                      },
                      items: statusOptions.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    if (selectedStatus == 'IP Approved')
                      TextField(
                        controller: _referenceNoController,
                        decoration: InputDecoration(
                          labelText: 'ARN No',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Wrap(
                                    children: <Widget>[
                                      ListTile(
                                        leading: const Icon(Icons.camera_alt),
                                        title: const Text('Camera'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          OcrHelper.pickImage(ImageSource.camera, (text) {
                                            setState(() {
                                              _referenceNoController.text = text;
                                            });
                                          });
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.photo_library),
                                        title: const Text('Gallery'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          OcrHelper.pickImage(ImageSource.gallery, (text) {
                                            setState(() {
                                              _referenceNoController.text = text;
                                            });
                                          });
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      )
                    else if (selectedStatus != null)
                      TextField(
                        controller: _remarksController,
                        decoration: const InputDecoration(
                          labelText: 'Remarks',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    const SizedBox(height: 20),

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
            ),
            CustomColor.showFullScreenLoading(isLoading: _isLoading),
          ],
        ),
      ),
    );
  }

  Future<void> submitDataToServer() async {
    if (_customerNameController.text.isEmpty) {
      CustomColor.showErrorSnackBar(context, 'Please enter Customer Full Name');
      return;
    }

    if (_mobileNoController.text.length < 10) {
      CustomColor.showErrorSnackBar(context, 'Please enter correct mobile number');
      return;
    }

    if (selectedStatus == null) {
      CustomColor.showErrorSnackBar(context, 'Please select a status.');
      return;
    }
    if (selectedStatus == 'IP Approved' && _referenceNoController.text.isEmpty) {
      CustomColor.showErrorSnackBar(context, 'Please enter ARN number.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String frappeId = DateTime.now().millisecondsSinceEpoch.toString();
      final String loginDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final String arnNo = selectedStatus == 'IP Approved' ? _referenceNoController.text : '';
      final String remarks = _remarksController.text;

      User? user = await SessionManager.getSessionData();
      if (user == null) {
        CustomColor.showErrorSnackBar(context, 'User session not found. Please log in again.');
        return;
      }
      final String userId = user.userId;

      final caseLogin = CaseLoginModel(
        frappeId: frappeId,
        customerName: _customerNameController.text,
        mobileNo: _mobileNoController.text,
        loginDate: loginDate,
        ipStatus: selectedStatus! ,
        arnNo: arnNo,
        remarks: remarks,
        user: userId,
      );

      final int id = await DatabaseService.instance.caseLoginRepository.insertCaseLogin(caseLogin);

      if (id > 0) {
        CustomColor.showSuccessSnackBar(context, 'Case Login Submitted Successfully!');
        // Clear fields after successful submission
        _customerNameController.clear();
        _mobileNoController.clear();
        _referenceNoController.clear();
        _remarksController.clear();
        setState(() {
          selectedStatus = null;
        });
      } else {
        CustomColor.showErrorSnackBar(context, 'Failed to submit Case Login to local database.');
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