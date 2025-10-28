
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/network/api_feedback_helper.dart';
import 'package:credlawn/screens/login_screen.dart';
import 'package:credlawn/screens/pre_approved_lead_screen.dart';
import 'package:intl/intl.dart';
import 'package:credlawn/helpers/ocr_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:credlawn/helpers/app_state_manager.dart';

class FeedbackDialog extends StatefulWidget {
  final String mobileNo;

  const FeedbackDialog({super.key, required this.mobileNo});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  String? selectedStatus;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _referenceNoController = TextEditingController();

  final List<String> statusOptions = [
    'IP Approved',
    'IP Decline',
    'Customer Denied',
    'Docs Not Available',
    'Already Carded',
    'Recently Applied',
    'CNR',
    'Follow up'
  ];

  @override
  void dispose() {
    _remarksController.dispose();
    _referenceNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Provide Feedback', style: GoogleFonts.poppins()),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Mobile Number: ${widget.mobileNo}', style: GoogleFonts.poppins()),
              const SizedBox(height: 20),
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
                    labelText: 'Reference No',
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
              else if (selectedStatus == 'Follow up')
                Column(
                  children: [
                    ListTile(
                      title: Text(selectedDate == null
                          ? 'Select Date'
                          : 'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: Text(selectedTime == null
                          ? 'Select Time'
                          : 'Time: ${selectedTime!.format(context)}'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );
                        if (picked != null && picked != selectedTime) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                    ),
                  ],
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
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.red)),
          onPressed: () {
            _remarksController.clear();
            _referenceNoController.clear();
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('Submit', style: GoogleFonts.poppins(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: CustomColor.MainColor),
          onPressed: () async {
            if (selectedStatus == null) {
              CustomColor.showErrorSnackBar(context, 'Please select a status.');
              return;
            }
            if (selectedStatus == 'IP Approved' && _referenceNoController.text.isEmpty) {
              CustomColor.showErrorSnackBar(context, 'Please enter a reference number.');
              return;
            }

            if (selectedStatus == 'Follow up') {
              if (selectedDate == null || selectedTime == null) {
                CustomColor.showErrorSnackBar(context, 'Please select a date and time.');
                return;
              }

              final user = await SessionManager.getSessionData();
              if (user == null) {
                CustomColor.showErrorSnackBar(context, 'User session not found. Please log in again.');
                return;
              }

              bool success = await saveCustomerFeedback(
                mobileNo: widget.mobileNo,
                remarks: _remarksController.text,
                status: selectedStatus,
                referenceNo: _referenceNoController.text,
                userId: user.userId,
                followUpDate: DateFormat('yyyy-MM-dd').format(selectedDate!),
                followUpTime: selectedTime!.format(context),
              );

              if (success) {
                CustomColor.showSuccessSnackBar(context, 'Follow-up scheduled successfully!');
                _remarksController.clear();
                _referenceNoController.clear();
                Navigator.of(context).pop(true); // Return true on success
              } else {
                CustomColor.showErrorSnackBar(context, 'Failed to schedule follow-up.');
              }
              return;
            }

            final user = await SessionManager.getSessionData();
            if (user == null) {
              CustomColor.showErrorSnackBar(context, 'User session not found. Please log in again.');
              return;
            }

            bool success = await saveCustomerFeedback(
              mobileNo: widget.mobileNo,
              remarks: _remarksController.text,
              status: selectedStatus,
              referenceNo: _referenceNoController.text,
              userId: user.userId,
            );
            if (success) {
              AppStateManager.clearPendingFeedbackMobile();
              CustomColor.showSuccessSnackBar(context, 'Feedback submitted successfully!');
              _remarksController.clear();
              _referenceNoController.clear();
              Navigator.of(context).pop(true); // Return true on success
            } else {
              CustomColor.showErrorSnackBar(context, 'Failed to submit feedback.');
            }
          },
        ),
      ],
    );
  }
}
