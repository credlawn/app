import 'package:flutter/material.dart';
import 'package:credlawn/network/api_attendance_helper.dart';
import 'package:credlawn/models/attendance_record_model.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class AttendanceStatisticsScreen extends StatefulWidget {
  const AttendanceStatisticsScreen({super.key});

  @override
  State<AttendanceStatisticsScreen> createState() => _AttendanceStatisticsScreenState();
}

class _AttendanceStatisticsScreenState extends State<AttendanceStatisticsScreen> {
  bool _isLoading = true;
  List<AttendanceRecord> _allRecords = [];
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all attendance records (you might want to add pagination for large datasets)
      final records = await ApiAttendanceHelper.getAttendanceRecords(
        limit: 1000, // Load more records for statistics
        offset: 0,
      );

      setState(() {
        _allRecords = records;
        _statistics = _calculateStatistics(records);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load statistics: $e')),
        );
      }
    }
  }

  Map<String, dynamic> _calculateStatistics(List<AttendanceRecord> records) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);

    // Filter records for current month
    final thisMonthRecords = records.where((record) {
      final recordDate = DateTime.parse(record.date);
      return recordDate.year == thisMonth.year && recordDate.month == thisMonth.month;
    }).toList();

    // Filter records for last month
    final lastMonthRecords = records.where((record) {
      final recordDate = DateTime.parse(record.date);
      return recordDate.year == lastMonth.year && recordDate.month == lastMonth.month;
    }).toList();

    // Calculate attendance counts
    int presentCount = 0;
    int absentCount = 0;
    int lateCount = 0;
    int earlyLeftCount = 0;
    int holidayCount = 0;
    int pendingCount = 0;

    for (var record in thisMonthRecords) {
      final status = _getRecordStatus(record);
      // Check if it's a holiday first
      if (record.holidayName != null && record.holidayName!.isNotEmpty) {
        holidayCount++;
        continue;
      }

      switch (status) {
        case 'Present':
          presentCount++;
          break;
        case 'Absent':
          absentCount++;
          break;
        case 'Late Come':
          lateCount++;
          presentCount++; // Late is still present
          break;
        case 'Early Left':
          earlyLeftCount++;
          presentCount++; // Early left is still present
          break;
        case 'Working':
          // workingCount++; // Commented out since we're now counting holidays
          break;
        case 'Pending':
          pendingCount++;
          break;
      }
    }

    // Calculate working days in current month
    final totalWorkingDays = _getWorkingDaysInMonth(now.year, now.month);

    // Calculate attendance percentage (excluding holidays from working days)
    final workingDaysExcludingHolidays = totalWorkingDays - holidayCount;
    final attendancePercentage = workingDaysExcludingHolidays > 0
        ? ((presentCount + pendingCount) / workingDaysExcludingHolidays * 100).round()
        : 0;

    // Calculate average working hours
    double totalHours = 0;
    int recordsWithHours = 0;

    for (var record in thisMonthRecords) {
      if (record.inTime != null && record.inTime != 'N/A' &&
          record.outTime != null && record.outTime != 'N/A') {
        try {
          final inTime = DateFormat('HH:mm:ss').parse(record.inTime!);
          final outTime = DateFormat('HH:mm:ss').parse(record.outTime!);
          final hours = outTime.difference(inTime).inMinutes / 60.0;
          if (hours > 0 && hours < 24) { // Reasonable working hours
            totalHours += hours;
            recordsWithHours++;
          }
        } catch (e) {
          // Skip invalid time formats
        }
      }
    }

    final averageHours = recordsWithHours > 0 ? totalHours / recordsWithHours : 0.0;

    // Monthly trend data for chart
    final monthlyData = _generateMonthlyChartData(records);

    return {
      'thisMonth': {
        'present': presentCount,
        'absent': absentCount,
        'late': lateCount,
        'earlyLeft': earlyLeftCount,
        'holiday': holidayCount,
        'pending': pendingCount,
        'totalWorkingDays': totalWorkingDays,
        'attendancePercentage': attendancePercentage,
        'averageHours': averageHours,
      },
      'lastMonth': {
        'records': lastMonthRecords.length,
      },
      'monthlyChartData': monthlyData,
    };
  }

  int _getWorkingDaysInMonth(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    int workingDays = 0;

    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(year, month, day);
      // Exclude weekends (Saturday = 6, Sunday = 7)
      if (date.weekday != 6 && date.weekday != 7) {
        workingDays++;
      }
    }

    return workingDays;
  }

  String _getRecordStatus(AttendanceRecord record) {
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
      return isToday ? 'Pending' : 'Absent';
    }

    // If either check-in or check-out is missing
    if ((record.inTime == null || record.inTime == 'N/A') ||
        (record.outTime == null || record.outTime == 'N/A')) {
      if (isToday && record.inTime != null && record.inTime != 'N/A' &&
          (record.outTime == null || record.outTime == 'N/A')) {
        return 'Working';
      }
      if (!isToday && record.inTime != null && record.inTime != 'N/A' &&
          (record.outTime == null || record.outTime == 'N/A')) {
        return 'Pending';
      }
      return 'Incomplete';
    }

    // For complete records, check timing (simplified for statistics)
    return 'Present';
  }

  List<FlSpot> _generateMonthlyChartData(List<AttendanceRecord> records) {
    final now = DateTime.now();
    final spots = <FlSpot>[];

    // Get last 30 days
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayRecords = records.where((record) {
        final recordDate = DateTime.parse(record.date);
        return recordDate.year == date.year &&
               recordDate.month == date.month &&
               recordDate.day == date.day;
      }).toList();

      // Calculate attendance score (0-1)
      double score = 0;
      if (dayRecords.isNotEmpty) {
        final record = dayRecords.first;
        if (record.inTime != null && record.inTime != 'N/A') {
          score = 0.5; // Check-in done
          if (record.outTime != null && record.outTime != 'N/A') {
            score = 1.0; // Complete attendance
          }
        }
      }

      spots.add(FlSpot((29 - i).toDouble(), score));
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Statistics'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Month Overview
                    _buildOverviewCard(),

                    const SizedBox(height: 24),

                    // Monthly Trend Chart
                    _buildTrendChart(),

                    const SizedBox(height: 24),

                    // Detailed Statistics
                    _buildDetailedStats(),

                    const SizedBox(height: 24),

                    // Quick Insights
                    _buildInsightsCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewCard() {
    final stats = _statistics['thisMonth'] as Map<String, dynamic>;
    final attendancePercentage = stats['attendancePercentage'] as int;
    final averageHours = stats['averageHours'] as double;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text(
                  DateFormat('MMMM yyyy').format(DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '${attendancePercentage}%',
                    'Attendance Rate',
                    Icons.check_circle,
                  ),
                ),
                Container(height: 40, width: 1, color: Colors.white24),
                Expanded(
                  child: _buildStatItem(
                    '${averageHours.toStringAsFixed(1)}h',
                    'Avg Daily Hours',
                    Icons.schedule,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTrendChart() {
    final chartData = _statistics['monthlyChartData'] as List<FlSpot>;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '30-Day Attendance Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Absent', style: TextStyle(fontSize: 10));
                            case 1:
                              return const Text('Present', style: TextStyle(fontSize: 10));
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 7 == 0) {
                            final date = DateTime.now().subtract(Duration(days: 29 - value.toInt()));
                            return Text(DateFormat('dd').format(date), style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData,
                      isCurved: true,
                      color: const Color(0xFF2563EB),
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats() {
    final stats = _statistics['thisMonth'] as Map<String, dynamic>;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    stats['present'].toString(),
                    'Present Days',
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    stats['absent'].toString(),
                    'Absent Days',
                    Colors.red,
                    Icons.cancel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    stats['late'].toString(),
                    'Late Arrivals',
                    Colors.orange,
                    Icons.schedule,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    stats['earlyLeft'].toString(),
                    'Early Departures',
                    Colors.deepOrange,
                    Icons.schedule_send,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    stats['holiday'].toString(),
                    'holiday',
                    Colors.blue,
                    Icons.work,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    stats['pending'].toString(),
                    'Pending Check-out',
                    Colors.blue,
                    Icons.pending,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    final stats = _statistics['thisMonth'] as Map<String, dynamic>;
    final attendancePercentage = stats['attendancePercentage'] as int;
    final averageHours = stats['averageHours'] as double;

    final insights = <String>[];

    if (attendancePercentage >= 90) {
      insights.add('🎉 Excellent attendance this month!');
    } else if (attendancePercentage >= 75) {
      insights.add('👍 Good attendance record');
    } else {
      insights.add('⚠️ Consider improving attendance');
    }

    if (averageHours >= 8) {
      insights.add('⏰ Great working hours maintained');
    } else if (averageHours > 0) {
      insights.add('💡 Consider optimizing work schedule');
    }

    if (stats['late'] > stats['present'] * 0.1) {
      insights.add('🕐 Try to arrive on time more often');
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Insights & Recommendations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            if (insights.isEmpty)
              const Text(
                'No insights available yet. Keep tracking your attendance!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
