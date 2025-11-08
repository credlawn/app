import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';

class DateOfBirthPicker extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime) onDateSelected;

  const DateOfBirthPicker({
    super.key,
    this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<DateOfBirthPicker> createState() => _DateOfBirthPickerState();
}

class _DateOfBirthPickerState extends State<DateOfBirthPicker> {
  late int selectedDay;
  late int selectedMonth;
  late int selectedYear;

  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      selectedDay = widget.initialDate!.day;
      selectedMonth = widget.initialDate!.month;
      selectedYear = widget.initialDate!.year;
    } else {
      // Default to 25 years ago
      final defaultDate = DateTime.now().subtract(const Duration(days: 25 * 365));
      selectedDay = defaultDate.day;
      selectedMonth = defaultDate.month;
      selectedYear = defaultDate.year;
    }
  }

  List<int> getDaysInMonth(int month, int year) {
    if (month == 2) {
      // February - check for leap year
      if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return List.generate(29, (index) => index + 1);
      } else {
        return List.generate(28, (index) => index + 1);
      }
    } else if ([4, 6, 9, 11].contains(month)) {
      // April, June, September, November
      return List.generate(30, (index) => index + 1);
    } else {
      // January, March, May, July, August, October, December
      return List.generate(31, (index) => index + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final pickerHeight = screenHeight * 0.5; // At least half screen height

    return Container(
      height: pickerHeight,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Title at top
          Text(
            'Select Date of Birth',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          // Expanded space for date selectors
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Day, Month, Year selectors in one row - center aligned
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Day - same width as year
                      SizedBox(
                        width: 85,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Day',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<int>(
                                value: selectedDay,
                                isExpanded: true,
                                underline: const SizedBox(),
                                icon: Icon(Icons.arrow_drop_down, color: CustomColor.MainColor, size: 20),
                                items: getDaysInMonth(selectedMonth, selectedYear)
                                    .map((day) => DropdownMenuItem(
                                          value: day,
                                          child: Text(
                                            day.toString(),
                                            style: GoogleFonts.poppins(fontSize: 16),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => selectedDay = value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Month - reasonable width
                      SizedBox(
                        width: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Month',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<int>(
                                value: selectedMonth,
                                isExpanded: true,
                                underline: const SizedBox(),
                                icon: Icon(Icons.arrow_drop_down, color: CustomColor.MainColor, size: 20),
                                items: List.generate(12, (index) => index + 1)
                                    .map((month) => DropdownMenuItem(
                                          value: month,
                                          child: Text(
                                            months[month - 1],
                                            style: GoogleFonts.poppins(fontSize: 16),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedMonth = value;
                                      // Adjust day if necessary (e.g., Feb 30 -> Feb 28/29)
                                      final maxDays = getDaysInMonth(selectedMonth, selectedYear).length;
                                      if (selectedDay > maxDays) {
                                        selectedDay = maxDays;
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Year - same width as day
                      SizedBox(
                        width: 85,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Year',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<int>(
                                value: selectedYear,
                                isExpanded: true,
                                underline: const SizedBox(),
                                icon: Icon(Icons.arrow_drop_down, color: CustomColor.MainColor, size: 20),
                                items: List.generate(80, (index) => DateTime.now().year - 17 - index)
                                    .map((year) => DropdownMenuItem(
                                          value: year,
                                          child: Text(
                                            year.toString(),
                                            style: GoogleFonts.poppins(fontSize: 16),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedYear = value;
                                      // Adjust day if necessary for leap years
                                      final maxDays = getDaysInMonth(selectedMonth, selectedYear).length;
                                      if (selectedDay > maxDays) {
                                        selectedDay = maxDays;
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Action buttons at bottom with more spacing
          const SizedBox(height: 40),

          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.grey.shade100,
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final selectedDate = DateTime(selectedYear, selectedMonth, selectedDay);
                    widget.onDateSelected(selectedDate);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.MainColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Select',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
