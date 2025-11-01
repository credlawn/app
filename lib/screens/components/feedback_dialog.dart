
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:intl/intl.dart';
import 'package:credlawn/helpers/ocr_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:credlawn/helpers/app_state_manager.dart';
import 'package:credlawn/helpers/database_service.dart';

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
    'Follow up'
  ];

  @override
  void dispose() {
    _remarksController.dispose();
    _referenceNoController.dispose();
    super.dispose();
  }

  Future<String> getCustomerName(String mobileNo) async {
    final lead = await DatabaseService.instance.leadsRepository.getLeadByMobileNo(mobileNo);
    return lead?.customerName ?? 'N/A';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: CustomColor.MainColor,
        title: Text('Provide Feedback', style: GoogleFonts.poppins(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _remarksController.clear();
            _referenceNoController.clear();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: FutureBuilder<String>(
                    future: getCustomerName(widget.mobileNo),
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          // Customer info
                          Row(
                            children: [
                              Icon(Icons.person, color: Colors.blue.shade800, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  snapshot.hasData ? snapshot.data! : 'Loading...',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          // Separator line
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Divider(
                              color: Colors.grey.shade100,
                              height: 1,
                            ),
                          ),
                          // Mobile info
                          Row(
                            children: [
                              Icon(Icons.phone, color: Colors.green.shade800, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.mobileNo,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

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
                              // Unfocus any text field and hide keyboard
                              FocusScope.of(context).unfocus();

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
                  Container(
                    height: 55.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(100),
                          blurRadius: 1.5,
                          spreadRadius: 1.5,
                          offset: const Offset(0.3, 0.3),
                        ),
                      ],
                    ),
                    child: TextField(
                      key: const ValueKey('arn_no_field'),
                      controller: _referenceNoController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Reference No',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: CustomColor.MainColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        labelStyle: TextStyle(color: CustomColor.MainColor),
                        prefixIcon: Icon(Icons.confirmation_number_outlined, color: CustomColor.MainColor),
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
                                          'Scan Reference Number',
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
                    ),
                  )
                else if (selectedStatus == 'Follow up')
                  Column(
                    children: [
                      ListTile(
                        title: Text(
                          selectedDate == null
                              ? 'Select Date'
                              : 'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
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
                        title: Text(
                          selectedTime == null
                              ? 'Select Time'
                              : 'Time: ${selectedTime!.format(context)}',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
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
                  Container(
                    height: 55.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(100),
                          blurRadius: 1.5,
                          spreadRadius: 1.5,
                          offset: const Offset(0.3, 0.3),
                        ),
                      ],
                    ),
                    child: TextField(
                      key: const ValueKey('remarks_field'),
                      controller: _remarksController,
                      decoration: InputDecoration(
                        labelText: 'Remarks',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: CustomColor.MainColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        labelStyle: TextStyle(color: CustomColor.MainColor),
                        prefixIcon: Icon(Icons.feedback_outlined, color: CustomColor.MainColor),
                      ),
                      maxLines: 1,
                    ),
                  ),
                const SizedBox(height: 40),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.MainColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
                    }

                    final lead = await DatabaseService.instance.leadsRepository.getLeadByMobileNo(widget.mobileNo);

                    if (lead == null) {
                      CustomColor.showErrorSnackBar(context, 'Lead not found in local database.');
                      return;
                    }

                    final int rowsAffected = await DatabaseService.instance.leadsRepository.updateLeadLocalFields(
                      lead.frappeId,
                      leadStatus: selectedStatus,
                      remarks: _remarksController.text,
                      arnNo: selectedStatus == 'IP Approved' ? _referenceNoController.text : null,
                      followUpDate: selectedStatus == 'Follow up' ? DateFormat('yyyy-MM-dd').format(selectedDate!) : null,
                      followUpTime: selectedStatus == 'Follow up' ? selectedTime!.format(context) : null,
                      isDirty: 1,
                    );

                    if (rowsAffected > 0) {
                      AppStateManager.clearPendingFeedbackMobile();
                      AppStateManager.notifyLeadDirty();
                      CustomColor.showSuccessSnackBar(context, 'Feedback submitted successfully!');
                      _remarksController.clear();
                      _referenceNoController.clear();
                      Navigator.of(context).pop(true);
                    } else {
                      CustomColor.showErrorSnackBar(context, 'Failed to submit feedback to local database.');
                    }
                  },
                  child: Text('Submit', style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
