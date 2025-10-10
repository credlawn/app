import 'package:flutter/material.dart';
import 'package:credlawn/network/api_attendance_helper.dart';
import 'package:credlawn/models/attendance_record_model.dart';
import 'package:credlawn/custom/custom_color.dart';

class AttendanceListWidget extends StatefulWidget {
  const AttendanceListWidget({Key? key}) : super(key: key);

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: ${record.date}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('In Time: ${record.inTime}'),
                          Text('Out Time: ${record.outTime}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'Status: ${record.status}',
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                          ),
                        ),
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
