import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:credlawn/helpers/error_logger.dart';
import 'package:credlawn/helpers/session_manager.dart';

class FollowUpPicker extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final Function(DateTime?) onDateChanged;
  final Function(TimeOfDay?) onTimeChanged;

  const FollowUpPicker({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  Future<void> _logValidationError(String error) async {
    try {
      final currentUser = await SessionManager.getSessionData();
      await ErrorLogger.logError(
        title: 'Follow-up Validation Error',
        errorMessage: error,
        errorType: 'Validation',
        userId: currentUser?.userId,
      );
    } catch (e) {
      // Silent fail for logging
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                onDateChanged(picked);
              } else if (picked == null) {
                await _logValidationError('User cancelled date selection for follow-up');
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
                onTimeChanged(picked);
              } else if (picked == null) {
                await _logValidationError('User cancelled time selection for follow-up');
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
    );
  }
}
