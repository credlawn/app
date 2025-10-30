import 'package:flutter/material.dart';
import 'package:credlawn/network/api_attendance_helper.dart';
import 'package:credlawn/models/attendance_record_model.dart';
import 'package:intl/intl.dart'; // Added intl import

class AttendanceListWidget extends StatefulWidget {
  const AttendanceListWidget({super.key});

  @override
  State<AttendanceListWidget> createState() => AttendanceListWidgetState();
}

class AttendanceListWidgetState extends State<AttendanceListWidget> {
  late Future<List<AttendanceRecord>> _attendanceRecordsFuture;

  @override
  void initState() {
    super.initState();
    _attendanceRecordsFuture = _fetchRecords();
  }

  Future<List<AttendanceRecord>> _fetchRecords() {
    return ApiAttendanceHelper.getAttendanceRecords();
  }

  void refreshData() {
    setState(() {
      _attendanceRecordsFuture = _fetchRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AttendanceRecord>>(
      future: _attendanceRecordsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No attendance records found for this month.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
          } else {
            final reversedRecords = snapshot.data!.reversed.toList();
            return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Re-added to prevent inner scrolling
            itemCount: reversedRecords.length,
              itemBuilder: (context, index) {
                final record = reversedRecords[index];

                // Date Formatting
                final DateTime recordDate = DateTime.parse(record.date);
                final String formattedDate = DateFormat('dd-MM-yyyy').format(recordDate);

                // Time Formatting and N/A replacement
                String formatTime(String time) {
                  if (time == 'N/A') return ''; // Return empty string for N/A
                  try {
                    final DateTime parsedTime = DateFormat('HH:mm:ss').parse(time);
                    return DateFormat('hh:mm a').format(parsedTime);
                  } catch (e) {
                    return time; // Return original if parsing fails
                  }
                }

                final String formattedInTime = formatTime(record.inTime);
                final String formattedOutTime = formatTime(record.outTime);

                // Define office times for comparison
                final TimeOfDay officeInTimeLimit = const TimeOfDay(hour: 10, minute: 16);
                final TimeOfDay officeOutTimeLimit = const TimeOfDay(hour: 18, minute: 31);

                Color inTimeColor = Colors.black; // Default color
                Color outTimeColor = Colors.black; // Default color

                // Determine In Time color
                if (record.inTime != 'N/A') {
                  try {
                    final DateTime parsedInTime = DateFormat('HH:mm:ss').parse(record.inTime);
                    final TimeOfDay actualInTime = TimeOfDay.fromDateTime(parsedInTime);
                    if (actualInTime.hour < officeInTimeLimit.hour || (actualInTime.hour == officeInTimeLimit.hour && actualInTime.minute <= officeInTimeLimit.minute)) {
                      inTimeColor = Colors.green;
                    } else {
                      inTimeColor = Colors.red;
                    }
                  } catch (e) { /* Handle parsing error if necessary */ }
                }

                // Determine Out Time color
                if (record.outTime != 'N/A') {
                  try {
                    final DateTime parsedOutTime = DateFormat('HH:mm:ss').parse(record.outTime);
                    final TimeOfDay actualOutTime = TimeOfDay.fromDateTime(parsedOutTime);
                    if (actualOutTime.hour < officeOutTimeLimit.hour || (actualOutTime.hour == officeOutTimeLimit.hour && actualOutTime.minute < officeOutTimeLimit.minute)) {
                      outTimeColor = Colors.red;
                    } else {
                      outTimeColor = Colors.green;
                    }
                  } catch (e) { /* Handle parsing error if necessary */ }
                }

                Color statusColor;
                switch (record.status) {
                  case 'Present':
                    statusColor = Colors.green;
                    break;
                  case 'Late Come':
                    statusColor = Colors.orange;
                    break;
                  case 'Early Left':
                    statusColor = Colors.deepOrange;
                    break;
                  case 'Absent':
                    statusColor = Colors.red;
                    break;
                  default:
                    statusColor = Colors.grey;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              record.status,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: $formattedDate',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text('In: $formattedInTime', style: TextStyle(color: inTimeColor)),
                            Text('Out: $formattedOutTime', style: TextStyle(color: outTimeColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
    );
  }
}
