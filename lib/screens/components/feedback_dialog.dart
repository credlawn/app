import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:intl/intl.dart';
import 'package:credlawn/helpers/ocr_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:credlawn/helpers/app_state_manager.dart';
import 'package:credlawn/helpers/database_service.dart';
import 'package:credlawn/models/feedback_model.dart'; // Import FeedbackModel
import 'package:credlawn/helpers/session_manager.dart'; // Import SessionManager for userId
import 'package:credlawn/helpers/feedback_sync_service.dart'; // Import FeedbackSyncService

class FeedbackScreen extends StatefulWidget {
  final String mobileNo;

  const FeedbackScreen({super.key, required this.mobileNo});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
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
                      spacing: 22.0,
                      runSpacing: 10.0,
                      children: statusOptions.map((String status) {
                        final chipWidth = (MediaQuery.of(context).size.width - 30 - 12) * 0.42;

                        // Define color schemes for each status type
                        Color backgroundColor, selectedColor, borderColor, textColor;
                        IconData? icon;

                        switch (status) {
                          case 'IP Approved':
                            backgroundColor = Colors.green.shade50.withOpacity(0.5);
                            selectedColor = Colors.green.shade600;
                            borderColor = Colors.green.shade100;
                            textColor = Colors.green.shade800;
                            icon = Icons.check_circle_outline;
                            break;
                          case 'IP Decline':
                            backgroundColor = Colors.red.shade50.withOpacity(0.5);
                            selectedColor = Colors.red.shade600;
                            borderColor = Colors.red.shade100;
                            textColor = Colors.red.shade800;
                            icon = Icons.cancel_outlined;
                            break;
                          case 'Customer Denied':
                            backgroundColor = Colors.orange.shade50.withOpacity(0.5);
                            selectedColor = Colors.orange.shade600;
                            borderColor = Colors.orange.shade100;
                            textColor = Colors.orange.shade800;
                            icon = Icons.block_outlined;
                            break;
                          case 'Docs Not Available':
                            backgroundColor = Colors.blue.shade50.withOpacity(0.5);
                            selectedColor = Colors.blue.shade600;
                            borderColor = Colors.blue.shade100;
                            textColor = Colors.blue.shade800;
                            icon = Icons.description_outlined;
                            break;
                          case 'Already Carded':
                            backgroundColor = Colors.purple.shade50.withOpacity(0.5);
                            selectedColor = Colors.purple.shade600;
                            borderColor = Colors.purple.shade100;
                            textColor = Colors.purple.shade800;
                            icon = Icons.credit_card_outlined;
                            break;
                          case 'Recently Applied':
                            backgroundColor = Colors.teal.shade50.withOpacity(0.5);
                            selectedColor = Colors.teal.shade600;
                            borderColor = Colors.teal.shade100;
                            textColor = Colors.teal.shade800;
                            icon = Icons.history_outlined;
                            break;
                          case 'Follow up':
                            backgroundColor = Colors.indigo.shade50.withOpacity(0.5);
                            selectedColor = Colors.indigo.shade600;
                            borderColor = Colors.indigo.shade100;
                            textColor = Colors.indigo.shade800;
                            icon = Icons.access_time_outlined;
                            break;
                          default:
                            backgroundColor = Colors.grey.shade100;
                            selectedColor = CustomColor.MainColor;
                            borderColor = Colors.grey.shade200;
                            textColor = Colors.black54;
                            icon = null;
                        }

                        return SizedBox(
                          width: chipWidth,
                          child: ChoiceChip(
                            label: Container(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (icon != null) ...[
                                    Icon(icon, size: 14, color: selectedStatus == status ? Colors.white : textColor),
                                    const SizedBox(width: 3),
                                  ],
                                  Flexible(
                                    child: Text(
                                      status,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        color: selectedStatus == status ? Colors.white : textColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            selected: selectedStatus == status,
                            selectedColor: selectedColor,
                            backgroundColor: backgroundColor,
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
                                if (status == 'Follow up') {
                                  selectedDate = null; // Clear follow-up date
                                  selectedTime = null; // Clear follow-up time
                                }
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(
                                color: selectedStatus == status ? selectedColor : borderColor,
                                width: 1.2,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                            labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                            elevation: selectedStatus == status ? 1.5 : 0.5,
                            shadowColor: selectedStatus == status ? selectedColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
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
                          borderSide: BorderSide(color: Colors.green),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.green.shade600),
                        ),
                        labelStyle: TextStyle(color: Colors.green.shade700),
                        prefixIcon: Icon(Icons.confirmation_number_outlined, color: Colors.green.shade700),
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.shade50.withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: Colors.indigo.shade100),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Date selection
                        InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Colors.indigo, // Header background color
                                      onPrimary: Colors.white, // Header text color
                                      onSurface: Colors.indigo.shade800, // Body text color
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.indigo, // Button text color
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null && picked != selectedDate) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.indigo.shade100),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.indigo.shade700, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  selectedDate == null
                                      ? 'Select Follow-up Date'
                                      : 'Date: ${DateFormat('dd MMM yyyy').format(selectedDate!)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.indigo.shade700,
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.arrow_drop_down, color: Colors.indigo.shade600, size: 24),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Time selection
                        InkWell(
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime ?? TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Colors.indigo, // Header background color
                                      onPrimary: Colors.white, // Header text color
                                      onSurface: Colors.indigo.shade800, // Body text color
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.indigo, // Button text color
                                      ),
                                    ),
                                    timePickerTheme: TimePickerThemeData(
                                      dialBackgroundColor: Colors.indigo.shade50,
                                      hourMinuteTextColor: Colors.indigo.shade800,
                                      hourMinuteColor: Colors.indigo.shade100,
                                      dialHandColor: Colors.indigo.shade700,
                                      entryModeIconColor: Colors.indigo.shade700,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null && picked != selectedTime) {
                              setState(() {
                                selectedTime = picked;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.indigo.shade100),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.indigo.shade700, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  selectedTime == null
                                      ? 'Select Follow-up Time'
                                      : 'Time: ${selectedTime!.format(context)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.indigo.shade700,
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.arrow_drop_down, color: Colors.indigo.shade600, size: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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

                    final currentUser = await SessionManager.getSessionData();
                    final userId = currentUser?.userId;

                      final newFeedback = FeedbackModel(
                        leadFrappeId: lead.frappeId,
                        status: selectedStatus!,
                        remarks: _remarksController.text.isNotEmpty ? _remarksController.text : null,
                        arnNo: selectedStatus == 'IP Approved' && _referenceNoController.text.isNotEmpty
                            ? _referenceNoController.text
                            : null,
                        followUpDate: selectedStatus == 'Follow up' && selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                            : null,
                        followUpTime: selectedStatus == 'Follow up' && selectedTime != null
                            ? selectedTime!.format(context)
                            : null,
                        timestamp: DateTime.now().millisecondsSinceEpoch,
                        userId: userId,
                        mobileNo: lead.mobileNo,
                        customerName: lead.customerName,
                      );

                      final feedbackId = await DatabaseService.instance.feedbackRepository.insertFeedback(newFeedback);

                      if (feedbackId > 0) {
                        // Get the newly created feedback with ID
                        final createdFeedback = await DatabaseService.instance.feedbackRepository.getFeedbackForLead(lead.frappeId);
                        final currentFeedback = createdFeedback.firstWhere((f) => f.id == feedbackId);

                        // Try to sync immediately
                        await FeedbackSyncService.syncFeedback(currentFeedback);

                        String? updatedFollowUpDate = selectedStatus == 'Follow up'
                            ? (selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : null)
                            : (lead.leadStatus == 'Follow up' ? '' : lead.followUpDate);

                        String? updatedFollowUpTime = selectedStatus == 'Follow up'
                            ? (selectedTime != null ? selectedTime!.format(context) : null)
                            : (lead.leadStatus == 'Follow up' ? '' : lead.followUpTime);

                        final int rowsAffected = await DatabaseService.instance.leadsRepository.updateLeadLocalFields(
                          lead.frappeId,
                          leadStatus: selectedStatus,
                          remarks: _remarksController.text,
                          arnNo: selectedStatus == 'IP Approved' ? _referenceNoController.text : null,
                          followUpDate: updatedFollowUpDate,
                          followUpTime: updatedFollowUpTime,
                          isDirty: 1,
                          lastSyncedAt: DateTime.now().millisecondsSinceEpoch,
                          lastFeedbackId: feedbackId,
                          lastFeedbackTimestamp: newFeedback.timestamp,
                        );

                        if (rowsAffected > 0) {
                          AppStateManager.clearPendingFeedbackMobile();
                          AppStateManager.notifyLeadDirty();
                          CustomColor.showSuccessSnackBar(context, 'Feedback submitted successfully!');
                          _remarksController.clear();
                          _referenceNoController.clear();
                          Navigator.of(context).pop(true);
                        } else {
                          CustomColor.showErrorSnackBar(context, 'Failed to update lead with feedback info.');
                        }
                      } else {
                        CustomColor.showErrorSnackBar(context, 'Failed to save feedback to local database.');
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

class FeedbackBottomSheet extends StatefulWidget {
  final String mobileNo;
  final Function(String mobileNo) onCallAnyway;

  const FeedbackBottomSheet({
    super.key,
    required this.mobileNo,
    required this.onCallAnyway,
  });

  @override
  State<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<FeedbackBottomSheet> {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 15,
        bottom: MediaQuery.of(context).viewInsets.bottom + 15,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Feedback for ${widget.mobileNo}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CustomColor.MainColor,
              ),
            ),
            const SizedBox(height: 15),
            FutureBuilder<String>(
              future: getCustomerName(widget.mobileNo),
              builder: (context, snapshot) {
                return Text(
                  snapshot.hasData ? snapshot.data! : 'Loading...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
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
                  spacing: 22.0,
                  runSpacing: 10.0,
                  children: statusOptions.map((String status) {
                    final chipWidth = (MediaQuery.of(context).size.width - 30 - 12) * 0.42;

                    Color backgroundColor, selectedColor, borderColor, textColor;
                    IconData? icon;

                    switch (status) {
                      case 'IP Approved':
                        backgroundColor = Colors.green.shade50.withOpacity(0.5);
                        selectedColor = Colors.green.shade600;
                        borderColor = Colors.green.shade100;
                        textColor = Colors.green.shade800;
                        icon = Icons.check_circle_outline;
                        break;
                      case 'IP Decline':
                        backgroundColor = Colors.red.shade50.withOpacity(0.5);
                        selectedColor = Colors.red.shade600;
                        borderColor = Colors.red.shade100;
                        textColor = Colors.red.shade800;
                        icon = Icons.cancel_outlined;
                        break;
                      case 'Customer Denied':
                        backgroundColor = Colors.orange.shade50.withOpacity(0.5);
                        selectedColor = Colors.orange.shade600;
                        borderColor = Colors.orange.shade100;
                        textColor = Colors.orange.shade800;
                        icon = Icons.block_outlined;
                        break;
                      case 'Docs Not Available':
                        backgroundColor = Colors.blue.shade50.withOpacity(0.5);
                        selectedColor = Colors.blue.shade600;
                        borderColor = Colors.blue.shade100;
                        textColor = Colors.blue.shade800;
                        icon = Icons.description_outlined;
                        break;
                      case 'Already Carded':
                        backgroundColor = Colors.purple.shade50.withOpacity(0.5);
                        selectedColor = Colors.purple.shade600;
                        borderColor = Colors.purple.shade100;
                        textColor = Colors.purple.shade800;
                        icon = Icons.credit_card_outlined;
                        break;
                      case 'Recently Applied':
                        backgroundColor = Colors.teal.shade50.withOpacity(0.5);
                        selectedColor = Colors.teal.shade600;
                        borderColor = Colors.teal.shade100;
                        textColor = Colors.teal.shade800;
                        icon = Icons.history_outlined;
                        break;
                      case 'Follow up':
                        backgroundColor = Colors.indigo.shade50.withOpacity(0.5);
                        selectedColor = Colors.indigo.shade600;
                        borderColor = Colors.indigo.shade100;
                        textColor = Colors.indigo.shade800;
                        icon = Icons.access_time_outlined;
                        break;
                      default:
                        backgroundColor = Colors.grey.shade100;
                        selectedColor = CustomColor.MainColor;
                        borderColor = Colors.grey.shade200;
                        textColor = Colors.black54;
                        icon = null;
                    }

                    return SizedBox(
                      width: chipWidth,
                      child: ChoiceChip(
                        label: Container(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (icon != null) ...[
                                Icon(icon, size: 14, color: selectedStatus == status ? Colors.white : textColor),
                                const SizedBox(width: 3),
                              ],
                              Flexible(
                                child: Text(
                                  status,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: selectedStatus == status ? Colors.white : textColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        selected: selectedStatus == status,
                        selectedColor: selectedColor,
                        backgroundColor: backgroundColor,
                        onSelected: (bool selected) {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            if (selected) {
                              selectedStatus = status;
                            } else {
                              selectedStatus = null;
                            }
                            _remarksController.clear();
                            _referenceNoController.clear();
                            if (status == 'Follow up') {
                              selectedDate = null; // Clear follow-up date
                              selectedTime = null; // Clear follow-up time
                            }
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(
                            color: selectedStatus == status ? selectedColor : borderColor,
                            width: 1.2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                        elevation: selectedStatus == status ? 1.5 : 0.5,
                        shadowColor: selectedStatus == status ? selectedColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
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
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.green.shade600),
                    ),
                    labelStyle: TextStyle(color: Colors.green.shade700),
                    prefixIcon: Icon(Icons.confirmation_number_outlined, color: Colors.green.shade700),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CustomColor.MainColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, color: CustomColor.MainColor, size: 20),
                        onPressed: () {
                          // This part is not needed for bottom sheet, but keeping for consistency if reused
                        },
                      ),
                    ),
                  ),
                ),
              )
            else if (selectedStatus == 'Follow up')
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.shade50.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Colors.indigo,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.indigo.shade800,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.indigo,
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.indigo.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.indigo.shade700, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              selectedDate == null
                                  ? 'Select Follow-up Date'
                                  : 'Date: ${DateFormat('dd MMM yyyy').format(selectedDate!)}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.indigo.shade700,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.arrow_drop_down, color: Colors.indigo.shade600, size: 24),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Colors.indigo,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.indigo.shade800,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.indigo,
                                  ),
                                ),
                                timePickerTheme: TimePickerThemeData(
                                  dialBackgroundColor: Colors.indigo.shade50,
                                  hourMinuteTextColor: Colors.indigo.shade800,
                                  hourMinuteColor: Colors.indigo.shade100,
                                  dialHandColor: Colors.indigo.shade700,
                                  entryModeIconColor: Colors.indigo.shade700,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != selectedTime) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.indigo.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.indigo.shade700, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              selectedTime == null
                                  ? 'Select Follow-up Time'
                                  : 'Time: ${selectedTime!.format(context)}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.indigo.shade700,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.arrow_drop_down, color: Colors.indigo.shade600, size: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false); // Remind Me Later / Dismiss
                    },
                    child: Text('Remind Me Later', style: GoogleFonts.poppins(color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColor.MainColor,
                      minimumSize: const Size(double.infinity, 45),
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

                      final currentUser = await SessionManager.getSessionData();
                      final userId = currentUser?.userId;

                      final newFeedback = FeedbackModel(
                        leadFrappeId: lead.frappeId,
                        status: selectedStatus!,
                        remarks: _remarksController.text.isNotEmpty ? _remarksController.text : null,
                        arnNo: selectedStatus == 'IP Approved' && _referenceNoController.text.isNotEmpty
                            ? _referenceNoController.text
                            : null,
                        followUpDate: selectedStatus == 'Follow up' && selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                            : null,
                        followUpTime: selectedStatus == 'Follow up' && selectedTime != null
                            ? selectedTime!.format(context)
                            : null,
                        timestamp: DateTime.now().millisecondsSinceEpoch,
                        userId: userId,
                        mobileNo: lead.mobileNo,
                        customerName: lead.customerName,
                      );

                      final feedbackId = await DatabaseService.instance.feedbackRepository.insertFeedback(newFeedback);

                      if (feedbackId > 0) {
                        // Get the newly created feedback with ID
                        final createdFeedback = await DatabaseService.instance.feedbackRepository.getFeedbackForLead(lead.frappeId);
                        final currentFeedback = createdFeedback.firstWhere((f) => f.id == feedbackId);

                        // Try to sync immediately
                        await FeedbackSyncService.syncFeedback(currentFeedback);

                        String? updatedFollowUpDate = selectedStatus == 'Follow up'
                            ? (selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : null)
                            : (lead.leadStatus == 'Follow up' ? '' : lead.followUpDate);

                        String? updatedFollowUpTime = selectedStatus == 'Follow up'
                            ? (selectedTime != null ? selectedTime!.format(context) : null)
                            : (lead.leadStatus == 'Follow up' ? '' : lead.followUpTime);

                        final int rowsAffected = await DatabaseService.instance.leadsRepository.updateLeadLocalFields(
                          lead.frappeId,
                          leadStatus: selectedStatus,
                          remarks: _remarksController.text,
                          arnNo: selectedStatus == 'IP Approved' ? _referenceNoController.text : null,
                          followUpDate: updatedFollowUpDate,
                          followUpTime: updatedFollowUpTime,
                          isDirty: 1,
                          lastSyncedAt: DateTime.now().millisecondsSinceEpoch,
                          lastFeedbackId: feedbackId,
                          lastFeedbackTimestamp: newFeedback.timestamp,
                        );

                        if (rowsAffected > 0) {
                          AppStateManager.clearPendingFeedbackMobile();
                          AppStateManager.notifyLeadDirty();
                          CustomColor.showSuccessSnackBar(context, 'Feedback submitted successfully!');
                          Navigator.of(context).pop(true);
                        } else {
                          CustomColor.showErrorSnackBar(context, 'Failed to update lead with feedback info.');
                        }
                      } else {
                        CustomColor.showErrorSnackBar(context, 'Failed to save feedback to local database.');
                      }
                    },
                    child: Text('Submit', style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Dismiss and proceed with call
                widget.onCallAnyway(widget.mobileNo);
              },
              child: Text(
                'Call Anyway',
                style: GoogleFonts.poppins(
                  color: CustomColor.MainColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
