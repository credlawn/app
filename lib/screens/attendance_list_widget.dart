import 'package:flutter/material.dart';
import 'package:credlawn/network/api_attendance_helper.dart';
import 'package:credlawn/models/attendance_record_model.dart';
import 'package:intl/intl.dart'; // Added intl import

class AttendanceListWidget extends StatefulWidget {
  final DateTime? officeStartTime;
  final DateTime? officeEndTime;

  const AttendanceListWidget({
    super.key,
    this.officeStartTime,
    this.officeEndTime,
  });

  @override
  State<AttendanceListWidget> createState() => AttendanceListWidgetState();
}

class AttendanceListWidgetState extends State<AttendanceListWidget> {
  List<AttendanceRecord> _records = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  static const int _pageSize = 20;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final records = await ApiAttendanceHelper.getAttendanceRecords(
        limit: _pageSize,
        offset: 0,
      );

      setState(() {
        _records = records.reversed.toList(); // Reverse to show newest first
        _currentPage = 1;
        _hasMoreData = records.length >= _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final records = await ApiAttendanceHelper.getAttendanceRecords(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      setState(() {
        _records.addAll(records);
        _currentPage++;
        _hasMoreData = records.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingMore = false;
      });
    }
  }

  void refreshData() {
    _loadInitialData();
  }

  void refreshDataWithFilter(DateTime? startDate, DateTime? endDate) {
    _loadFilteredData(startDate, endDate);
  }

  Future<void> _loadFilteredData(DateTime? startDate, DateTime? endDate) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final records = await ApiAttendanceHelper.getAttendanceRecords(
        fromDate: startDate != null ? DateFormat('yyyy-MM-dd').format(startDate) : null,
        toDate: endDate != null ? DateFormat('yyyy-MM-dd').format(endDate) : null,
        limit: _pageSize,
        offset: 0,
      );

      setState(() {
        _records = records.reversed.toList(); // Reverse to show newest first
        _currentPage = 1;
        _hasMoreData = records.length >= _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String getDisplayStatus(AttendanceRecord record) {
    final DateTime recordDate = DateTime.parse(record.date);
    final DateTime today = DateTime.now();
    final bool isToday = recordDate.year == today.year &&
                        recordDate.month == today.month &&
                        recordDate.day == today.day;

    // Check if it's a holiday
    if (record.holidayName != null && record.holidayName!.isNotEmpty) {
      return record.holidayName!;
    }

    // If both check-in and check-out are missing
    if ((record.inTime == null || record.inTime == 'N/A') &&
        (record.outTime == null || record.outTime == 'N/A')) {
      // For current date, show "Pending" instead of "Absent"
      return isToday ? 'Pending' : 'Absent';
    }

    // If either check-in or check-out is missing
    if ((record.inTime == null || record.inTime == 'N/A') ||
        (record.outTime == null || record.outTime == 'N/A')) {
      // For current date, if check-in is done, show "Working"
      if (isToday && record.inTime != null && record.inTime != 'N/A' &&
          (record.outTime == null || record.outTime == 'N/A')) {
        return 'Working';
      }
      // For past dates, if check-in is done but check-out missing, show "Pending"
      if (!isToday && record.inTime != null && record.inTime != 'N/A' &&
          (record.outTime == null || record.outTime == 'N/A')) {
        return 'Pending';
      }
      // Otherwise show "Incomplete"
      return 'Incomplete';
    }

    // For complete records, check timing against office hours
    if (widget.officeStartTime != null && widget.officeEndTime != null) {
      final TimeOfDay officeStart = TimeOfDay.fromDateTime(widget.officeStartTime!);
      final TimeOfDay officeEnd = TimeOfDay.fromDateTime(widget.officeEndTime!);

      final DateTime checkInTime = DateFormat('HH:mm:ss').parse(record.inTime!);
      final DateTime checkOutTime = DateFormat('HH:mm:ss').parse(record.outTime!);
      final TimeOfDay checkIn = TimeOfDay.fromDateTime(checkInTime);
      final TimeOfDay checkOut = TimeOfDay.fromDateTime(checkOutTime);

      final bool isLate = (checkIn.hour > officeStart.hour) ||
                         (checkIn.hour == officeStart.hour && checkIn.minute > officeStart.minute);
      final bool isEarly = (checkOut.hour < officeEnd.hour) ||
                          (checkOut.hour == officeEnd.hour && checkOut.minute < officeEnd.minute);

      if (isLate && isEarly) {
        return 'Early-Late';
      } else if (isLate) {
        return 'Late Come';
      } else if (isEarly) {
        return 'Early Left';
      }
    }

    // Return Present for on-time complete attendance
    return 'Present';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load attendance records',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please try again later',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadInitialData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'No attendance records yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your attendance history will appear here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _records.length + (_hasMoreData ? 1 : 0),
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        if (index == _records.length) {
          // Load More Button
          return Container(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: _isLoadingMore
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _loadMoreData,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text('Load More'),
                    ),
            ),
          );
        }

        final record = _records[index];
        final isLast = index == _records.length - 1;

        // Date Formatting
        final DateTime recordDate = DateTime.parse(record.date);
        final String formattedDate = DateFormat('dd MMM yyyy').format(recordDate);
        final String dayName = DateFormat('EEEE').format(recordDate);

        // Time Formatting
        String formatTime(String? time) {
          if (time == null || time == 'N/A') return '--:--';
          try {
            final DateTime parsedTime = DateFormat('HH:mm:ss').parse(time);
            return DateFormat('hh:mm a').format(parsedTime);
          } catch (e) {
            return time;
          }
        }

        final String formattedInTime = formatTime(record.inTime);
        final String formattedOutTime = formatTime(record.outTime);

        // Office times for comparison
        final TimeOfDay? officeInTimeLimit = widget.officeStartTime != null
            ? TimeOfDay.fromDateTime(widget.officeStartTime!)
            : null;
        final TimeOfDay? officeOutTimeLimit = widget.officeEndTime != null
            ? TimeOfDay.fromDateTime(widget.officeEndTime!)
            : null;

        // Determine colors
        Color getInTimeColor() {
          if (officeInTimeLimit == null || record.inTime == null || record.inTime == 'N/A') return Colors.grey.shade600;
          try {
            final DateTime parsedInTime = DateFormat('HH:mm:ss').parse(record.inTime!);
            final TimeOfDay actualInTime = TimeOfDay.fromDateTime(parsedInTime);
            if (actualInTime.hour < officeInTimeLimit.hour ||
                (actualInTime.hour == officeInTimeLimit.hour && actualInTime.minute <= officeInTimeLimit.minute)) {
              return Colors.green.shade600;
            } else {
              return Colors.red.shade600;
            }
          } catch (e) {
            return Colors.grey.shade600;
          }
        }

        Color getOutTimeColor() {
          if (officeOutTimeLimit == null || record.outTime == null || record.outTime == 'N/A') return Colors.grey.shade600;
          try {
            final DateTime parsedOutTime = DateFormat('HH:mm:ss').parse(record.outTime!);
            final TimeOfDay actualOutTime = TimeOfDay.fromDateTime(parsedOutTime);
            if (actualOutTime.hour >= officeOutTimeLimit.hour &&
                actualOutTime.minute >= officeOutTimeLimit.minute) {
              return Colors.green.shade600;
            } else {
              return Colors.red.shade600;
            }
          } catch (e) {
            return Colors.grey.shade600;
          }
        }

        Color getStatusColor() {
          // Check if it's a holiday first
          if (record.holidayName != null && record.holidayName!.isNotEmpty) {
            return Colors.green.shade600; // Green color for holidays
          }

          final displayStatus = getDisplayStatus(record);
          switch (displayStatus) {
            case 'Present':
              return Colors.green.shade600;
            case 'Late Come':
              return Colors.orange.shade600;
            case 'Early Left':
              return Colors.deepOrange.shade600;
            case 'Early-Late':
              return Colors.deepOrange.shade700;
            case 'Absent':
              return Colors.red.shade600;
            case 'Incomplete':
              return Colors.orange.shade700; // Orange color for incomplete
            case 'Working':
              return Colors.blue.shade600; // Blue color for working
            case 'Pending':
              return Colors.blue.shade600; // Blue color for pending (same as working)
            default:
              return Colors.grey.shade600;
          }
        }

        IconData? getStatusIcon() {
          // Check if it's a holiday first
          if (record.holidayName != null && record.holidayName!.isNotEmpty) {
            return Icons.celebration; // Celebration icon for holidays
          }

          final displayStatus = getDisplayStatus(record);
          switch (displayStatus) {
            case 'Present':
              return Icons.check_circle;
            case 'Late Come':
              return Icons.schedule;
            case 'Early Left':
              return Icons.schedule_send;
            case 'Early-Late':
              return Icons.access_time; // Clock icon for both early and late
            case 'Absent':
              return Icons.cancel;
            case 'Working':
              return null; // No icon for Working status
            case 'Pending':
              return null; // No icon for Pending status (same as Working)
            case 'Incomplete':
              return Icons.warning; // Warning icon for incomplete
            default:
              return Icons.help;
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline indicator
              SizedBox(
                width: 60,
                child: Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: getStatusColor(),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: getStatusColor().withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 80,
                        color: Colors.grey.shade300,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                  ],
                ),
              ),

              // Content card
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 16, right: 16),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date and status
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dayName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                constraints: const BoxConstraints(maxWidth: 100),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: getStatusColor().withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: getStatusColor().withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (getStatusIcon() != null) ...[
                                      Icon(
                                        getStatusIcon(),
                                        size: 12,
                                        color: getStatusColor(),
                                      ),
                                      const SizedBox(width: 2),
                                    ],
                                    Flexible(
                                      child: Text(
                                        getDisplayStatus(record),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: getStatusColor(),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Time information
                          Row(
                            children: [
                              // Check-in time
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.login,
                                        color: Colors.green.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Check In',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        formattedInTime,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: getInTimeColor(),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Check-out time
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.logout,
                                        color: Colors.red.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Check Out',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.red.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        formattedOutTime,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: getOutTimeColor(),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
