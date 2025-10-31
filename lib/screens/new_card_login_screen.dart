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
import 'package:credlawn/network/api_case_login_helper.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class NewCardLoginScreen extends StatefulWidget {
  const NewCardLoginScreen({super.key});

  @override
  State<NewCardLoginScreen> createState() => _NewCardLoginScreenState();
}

class _NewCardLoginScreenState extends State<NewCardLoginScreen> {
  bool _isLoading = false;
  final _customerNameController = TextEditingController();
  final _mobileNoController = TextEditingController();
  final _referenceNoController = TextEditingController();

  String? selectedStatus;
  final TextEditingController _remarksController = TextEditingController();

  final Uuid _uuid = Uuid();

  final List<String> statusOptions = [
    'IP Approved',
    'Docs Not Available',
    'IP Decline',
    'Customer Denied',
    'Recently Applied',
    'Already Carded',
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
        title: Text('New Case Login', style: GoogleFonts.poppins(color: Colors.white)),
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
                    const SizedBox(height: 15),
                    CustomerNameField(controller: _customerNameController, enable: true),
                    SizedBox(height: 15),
                    MobileField(controller: _mobileNoController, label: 'Mobile No'),
                    SizedBox(height: 15),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Status',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: statusOptions.map((String status) {
                            final chipWidth = (MediaQuery.of(context).size.width - 30 - 8) / 2;
                            return SizedBox(
                              width: chipWidth,
                              child: ChoiceChip(
                                label: Container(
                                  width: double.infinity,
                                  child: Text(
                                    status,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: selectedStatus == status
                                          ? Colors.white
                                          : Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                selected: selectedStatus == status,
                                selectedColor: CustomColor.MainColor,
                                backgroundColor: Colors.grey[200],
                                onSelected: (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedStatus = status;
                                    } else {
                                      selectedStatus = null;
                                    }
                                    _remarksController.clear();
                                    _referenceNoController.clear();
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: BorderSide(
                                    color: selectedStatus == status
                                        ? CustomColor.MainColor
                                        : Colors.grey[400]!,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (selectedStatus == 'IP Approved')
                      TextField(
                        key: const ValueKey('arn_no_field'),
                        controller: _referenceNoController,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(16),
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'ARN No',
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: CustomColor.MainColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: CustomColor.MainColor),
                          ),
                          labelStyle: TextStyle(color: CustomColor.MainColor),
                          suffixIcon: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: CustomColor.MainColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.camera_alt, color: CustomColor.MainColor, size: 20),
                              onPressed: () {
                                showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                builder: (context) {
                                  return Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Scan ARN Number',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildCameraOption(
                                                Icons.camera_alt,
                                                'Camera',
                                                ImageSource.camera,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildCameraOption(
                                                Icons.photo_library,
                                                'Gallery',
                                                ImageSource.gallery,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  );
                                },
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    else if (selectedStatus != null)
                      TextField(
                        key: const ValueKey('remarks_field'),
                        controller: _remarksController,
                        decoration: InputDecoration(
                          labelText: 'Remarks',
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: CustomColor.MainColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: CustomColor.MainColor),
                          ),
                          labelStyle: TextStyle(color: CustomColor.MainColor),
                        ),
                        maxLines: 1,
                      ),
                    const SizedBox(height: 40),

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
      final String currentSyncId = _uuid.v4(); // Generate a UUID
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
        syncId: currentSyncId,
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

        try {

            final Map<String, dynamic> serverResponse = await submitCaseLoginToServer(
              customerName: caseLogin.customerName,
              mobileNo: caseLogin.mobileNo,
              loginDate: caseLogin.loginDate,
              ipStatus: caseLogin.ipStatus,
              arnNo: caseLogin.arnNo,
              remarks: caseLogin.remarks,
              user: caseLogin.user!,
              sid: user.sid,
              syncId: currentSyncId,
            );

            if (serverResponse['message'] != null && serverResponse['message']['status'] == 'success') {
              final String serverFrappeName = serverResponse['message']['frappe_id'];
              final String modified = serverResponse['message']['modified'];
              await DatabaseService.instance.caseLoginRepository.updateCaseLoginLocalFields(
                caseLogin.frappeId!,
                newFrappeId: serverFrappeName,
                isDirty: 0,
                syncError: null,
                modified: modified,
              );
              CustomColor.showSuccessSnackBar(context, 'Data Synced Successfully');
            } else {
            await DatabaseService.instance.caseLoginRepository.updateCaseLoginLocalFields(
              caseLogin.frappeId!,
              isDirty: 1,
              syncError: serverResponse['message'] ?? 'Server sync failed',
            );
            CustomColor.showSuccessSnackBar(context, 'Data Saved Successfully');
          }
        } catch (syncE) {
          await DatabaseService.instance.caseLoginRepository.updateCaseLoginLocalFields(
            caseLogin.frappeId!,
            isDirty: 1,
            syncError: syncE.toString(),
          );
          CustomColor.showSuccessSnackBar(context, 'Data Saved Successfully');
        }

        _customerNameController.clear();
        _mobileNoController.clear();
        _referenceNoController.clear();
        _remarksController.clear();
        setState(() {
          selectedStatus = null;
        });
      } else {
        CustomColor.showErrorSnackBar(context, 'Failed to Submit Data.');
      }
    } catch (e) {
      CustomColor.showErrorSnackBar(context, 'Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildCameraOption(IconData icon, String text, ImageSource source) {
    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        leading: Icon(icon, color: CustomColor.MainColor),
        title: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        onTap: () {
          Navigator.pop(context);
          OcrHelper.pickImage(source, (text) {
            setState(() {
              _referenceNoController.text = text.toUpperCase();
            });
          });
        },
      ),
    );
  }
}
