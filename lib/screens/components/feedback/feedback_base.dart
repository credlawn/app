import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/helpers/ocr_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:credlawn/helpers/app_state_manager.dart';
import 'package:credlawn/helpers/database_service.dart';
import 'package:credlawn/models/feedback_model.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/helpers/feedback_sync_service.dart';
import 'package:credlawn/helpers/background_sync_service.dart';
import 'package:credlawn/helpers/error_logger.dart';
import 'widgets/status_chips.dart';
import 'widgets/follow_up_picker.dart';
import 'widgets/date_of_birth_picker.dart';

abstract class FeedbackBase extends StatefulWidget {
  final String mobileNo;

  const FeedbackBase({super.key, required this.mobileNo});
}

abstract class FeedbackBaseState<T extends FeedbackBase> extends State<T> {
  String? selectedStatus;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DateTime? selectedDateOfBirth;
  String? _errorMessage;
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
        title: Text(text, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
        onTap: () {
          Navigator.pop(context);
          OcrHelper.pickImage(source, (text) => setState(() => _referenceNoController.text = text.toUpperCase()));
        },
      ),
    );
  }

  Widget _buildReferenceNumberField() {
    return Container(
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
    );
  }

  Widget _buildRemarksField() {
    return Container(
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
    );
  }

  Widget _buildDateOfBirthField() {
    return Container(
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
      child: InkWell(
        onTap: () => _showDateOfBirthPicker(),
        child: Container(
          height: 55.0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: CustomColor.MainColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  selectedDateOfBirth != null
                      ? DateFormat('dd/MM/yyyy').format(selectedDateOfBirth!)
                      : 'Select Date of Birth',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: selectedDateOfBirth != null ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: CustomColor.MainColor),
            ],
          ),
        ),
      ),
    );
  }

  void _showDateOfBirthPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DateOfBirthPicker(
          initialDate: selectedDateOfBirth,
          onDateSelected: (date) {
            setState(() => selectedDateOfBirth = date);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget buildCustomerInfo() {
    return Container(
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: Colors.grey.shade100, height: 1),
              ),
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
    );
  }

  Widget buildStatusSection() {
    return Column(
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
        StatusChips(
          selectedStatus: selectedStatus,
          onStatusChanged: (status) {
            setState(() {
              selectedStatus = status;
              _errorMessage = null; // Clear error message when status changes
              _remarksController.clear();
              _referenceNoController.clear();
              selectedDateOfBirth = null; // Clear date of birth when status changes
              if (status == 'Follow up') {
                selectedDate = null;
                selectedTime = null;
              }
            });
          },
          statusOptions: statusOptions,
        ),
      ],
    );
  }

  Widget buildFormFields() {
    if (selectedStatus == 'IP Approved') {
      return Column(
        children: [
          _buildReferenceNumberField(),
          const SizedBox(height: 16),
          _buildDateOfBirthField(),
        ],
      );
    } else if (selectedStatus == 'Follow up') {
      return FollowUpPicker(
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        onDateChanged: (date) => setState(() => selectedDate = date),
        onTimeChanged: (time) => setState(() => selectedTime = time),
      );
    } else if (selectedStatus != null) {
      return _buildRemarksField();
    }
    return const SizedBox.shrink();
  }

  Widget buildErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logValidationError(String error) async {
    try {
      final currentUser = await SessionManager.getSessionData();
      await ErrorLogger.logError(
        title: 'Feedback Validation Failed',
        errorMessage: error,
        errorType: 'Validation',
        userId: currentUser?.userId,
      );
    } catch (e) {
      // Silent fail for logging
    }
  }



  Future<void> submitFeedback() async {
    // Clear any previous error message
    setState(() => _errorMessage = null);

    // Validation
    if (selectedStatus == null) {
      setState(() => _errorMessage = 'Please select a status.');
      await _logValidationError('No status selected');
      return;
    }

    if (selectedStatus == 'IP Approved' && _referenceNoController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter a reference number.');
      await _logValidationError('Reference number missing for IP Approved');
      return;
    }

    if (selectedStatus == 'Follow up') {
      if (selectedDate == null || selectedTime == null) {
        setState(() => _errorMessage = 'Please select a date and time.');
        await _logValidationError('Follow-up date/time missing');
        return;
      }
    }

    try {
      final lead = await DatabaseService.instance.leadsRepository.getLeadByMobileNo(widget.mobileNo);
      if (lead == null) {
        CustomColor.showErrorSnackBar(context, 'Lead not found in local database.');
        await _logValidationError('Lead not found: ${widget.mobileNo}');
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
        await DatabaseService.instance.leadsRepository.updateCallStatisticsForLead(lead.frappeId, lead.mobileNo);

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
          dateOfBirth: selectedStatus == 'IP Approved' && selectedDateOfBirth != null
              ? DateFormat('yyyy-MM-dd').format(selectedDateOfBirth!)
              : null,
          isDirty: 1,
          lastModifiedAt: DateTime.now().millisecondsSinceEpoch,
          lastFeedbackId: feedbackId,
          lastFeedbackTimestamp: newFeedback.timestamp,
        );

        if (rowsAffected > 0) {
          AppStateManager.clearPendingFeedbackMobile();
          AppStateManager.notifyLeadDirty();
          BackgroundSyncService.triggerSync(); // Trigger immediate background sync
          CustomColor.showSuccessSnackBar(context, 'Feedback submitted successfully!');
          _remarksController.clear();
          _referenceNoController.clear();
          onFeedbackSubmitted(true);
        } else {
          CustomColor.showErrorSnackBar(context, 'Failed to update lead with feedback info.');
          await _logValidationError('Failed to update lead local fields');
        }
      } else {
        CustomColor.showErrorSnackBar(context, 'Failed to save feedback to local database.');
        await _logValidationError('Failed to insert feedback to database');
      }
    } catch (e) {
      CustomColor.showErrorSnackBar(context, 'An error occurred while submitting feedback.');
      await ErrorLogger.logException(
        context: 'FeedbackBase.submitFeedback',
        exception: e,
        userId: (await SessionManager.getSessionData())?.userId,
      );
    }
  }

  void onFeedbackSubmitted(bool success);

  Widget buildFeedbackContent();
}
