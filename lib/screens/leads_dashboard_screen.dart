import 'dart:io';
import 'package:flutter/material.dart';
import 'package:credlawn/helpers/app_state_manager.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/helpers/lead_data_helper.dart';
import 'package:credlawn/models/leads_model.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/helpers/database_service.dart';
import 'package:credlawn/helpers/call_history_repository.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:credlawn/screens/components/dashboard/summary_cards_widget.dart';
import 'package:credlawn/screens/components/dashboard/call_summary_widget.dart';
import 'package:credlawn/screens/components/dashboard/status_chart_widget.dart';
import 'package:credlawn/screens/components/dashboard/recent_leads_widget.dart' show RecentLeadsWidget;
import 'package:credlawn/screens/components/dashboard/conversion_funnel_widget.dart';
import 'package:credlawn/screens/components/dashboard/performance_trends_widget.dart';

class LeadsDashboardScreen extends StatefulWidget {
  final User user;

  const LeadsDashboardScreen({super.key, required this.user});

  @override
  _LeadsDashboardScreenState createState() => _LeadsDashboardScreenState();
}

class _LeadsDashboardScreenState extends State<LeadsDashboardScreen> {
  List<LeadWithCallInfo> _allLeads = [];
  bool _isLoading = true;
  Map<String, int> _statusCounts = {};
  int _totalAttempted = 0;
  int _totalConnected = 0;
  int _totalDuration = 0;
  int _pendingFeedback = 0;
  int _todaysLeads = 0;
  double _conversionRate = 0.0;
  int _ipApprovedToday = 0;
  int _ipDeclineToday = 0;
  int _todayLogin = 0;
  double _approvalRate = 0.0;
  double _hourlyCallEfficiency = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final leads = await getLeadsWithCallCounts();
      await _computeMetrics(leads);

      setState(() {
        _allLeads = leads;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error - could show snackbar
    }
  }

  Future<void> _computeMetrics(List<LeadWithCallInfo> leads) async {
    _statusCounts.clear();
    _totalAttempted = 0;
    _totalConnected = 0;
    _totalDuration = 0;
    _pendingFeedback = 0;
    _todaysLeads = 0;
    _ipApprovedToday = 0;
    _ipDeclineToday = 0;
    _todayLogin = 0;
    _approvalRate = 0.0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayString = DateFormat('yyyy-MM-dd').format(today);
    final todayStart = today.millisecondsSinceEpoch;
    final todayEnd = now.millisecondsSinceEpoch;

    // Get all unique mobile numbers from leads
    final leadNumbers = leads.map((l) => l.lead.mobileNo).where((num) => num.isNotEmpty).toSet();

    // Calculate today's call metrics from local call log
    final db = await DatabaseService.instance.appDatabase.database;

    for (final number in leadNumbers) {
      final normalizedNumber = CallHistoryRepository.normalizeNumber(number);

      // Attempted calls (outgoing calls today)
      final attemptedResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM call_history WHERE normalized_number = ? AND call_type = ? AND timestamp >= ? AND timestamp <= ?',
        [normalizedNumber, 'outgoing', todayStart, todayEnd],
      );
      _totalAttempted += (attemptedResult.first['count'] as int?) ?? 0;

      // Connected calls (duration > 0 today)
      final connectedResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM call_history WHERE normalized_number = ? AND duration > 0 AND timestamp >= ? AND timestamp <= ?',
        [normalizedNumber, todayStart, todayEnd],
      );
      _totalConnected += (connectedResult.first['count'] as int?) ?? 0;

      // Total duration (sum of durations today)
      final durationResult = await db.rawQuery(
        'SELECT SUM(duration) as total FROM call_history WHERE normalized_number = ? AND duration > 0 AND timestamp >= ? AND timestamp <= ?',
        [normalizedNumber, todayStart, todayEnd],
      );
      _totalDuration += (durationResult.first['total'] as int?) ?? 0;
    }

    // Calculate other metrics
    for (var leadWithInfo in leads) {
      final lead = leadWithInfo.lead;

      // Status counts for pie chart (exclude "New" and only today)
      if (lead.leadStatus != 'New' && lead.leadStatusDate == todayString) {
        final status = lead.leadStatus ?? 'Unknown';
        _statusCounts[status] = (_statusCounts[status] ?? 0) + 1;
      }

      // Pending feedback
      if (leadWithInfo.callCount > 0 &&
          leadWithInfo.lastCallDuration != null &&
          leadWithInfo.lastCallDuration! > 0 &&
          !_hasFeedback(lead.leadStatus)) {
        _pendingFeedback++;
      }

      // Today's leads
      try {
        final allocationDate = DateTime.parse(lead.allocationDate);
        final allocationDay = DateTime(allocationDate.year, allocationDate.month, allocationDate.day);
        if (allocationDay == today) {
          _todaysLeads++;
        }
      } catch (e) {
        // Invalid date, skip
      }

      // IP Approved and IP Decline counts for today
      if (lead.leadStatus == 'IP Approved' && lead.leadStatusDate == todayString) {
        _ipApprovedToday++;
      } else if (lead.leadStatus == 'IP Decline' && lead.leadStatusDate == todayString) {
        _ipDeclineToday++;
      }
    }

    // Calculate Today Login and Approval Rate
    _todayLogin = _ipApprovedToday + _ipDeclineToday;
    if (_todayLogin > 0) {
      _approvalRate = (_ipApprovedToday / _todayLogin) * 100;
    }

    // Conversion rate
    if (_totalAttempted > 0) {
      _conversionRate = (_totalConnected / _totalAttempted) * 100;
    }

    // Calculate hourly call efficiency
    final workStartHour = 9; // Assuming work starts at 9 AM
    final currentHour = now.hour;

    if (currentHour >= workStartHour) {
      final hoursWorked = currentHour - workStartHour + 1; // +1 to include current hour
      if (hoursWorked > 0) {
        _hourlyCallEfficiency = _totalAttempted / hoursWorked;
      }
    }
  }

  bool _hasFeedback(String? leadStatus) {
    if (leadStatus == null || leadStatus.trim().isEmpty) {
      return false;
    }

    final feedbackStatuses = [
      'IP Approved',
      'IP Decline',
      'Customer Denied',
      'Docs Not Available',
      'Already Carded',
      'Recently Applied',
      'CNR',
    ];

    return feedbackStatuses.contains(leadStatus);
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String _formatAverageDuration() {
    if (_totalConnected == 0) return '00:00';
    final avgSeconds = _totalDuration ~/ _totalConnected;
    final minutes = avgSeconds ~/ 60;
    final seconds = avgSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  List<LeadWithCallInfo> _getRecentLeads() {
    final recentLeads = _allLeads.take(10).toList();
    recentLeads.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.lead.allocationDate);
        final dateB = DateTime.parse(b.lead.allocationDate);
        return dateB.compareTo(dateA); // Newest first
      } catch (e) {
        return 0;
      }
    });
    return recentLeads;
  }

  List<PerformanceData> _getPerformanceData() {
    // For now, return sample data. In a real implementation,
    // this would query the database for historical performance data
    final List<PerformanceData> data = [];
    final now = DateTime.now();

    // Start from 6 days ago (i=6) to today (i=0) to show chronological order
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateString = DateFormat('yyyy-MM-dd').format(date);

      // Sample data - in real implementation, query database for each day's data
      final approved = (i == 0) ? _ipApprovedToday : (_ipApprovedToday + (i * 2) - 3).clamp(0, 20);
      final declined = (i == 0) ? _ipDeclineToday : (_ipDeclineToday + i - 2).clamp(0, 15);
      final connected = (i == 0) ? _totalConnected : (_totalConnected + (i * 5) - 10).clamp(0, 50);

      data.add(PerformanceData(
        date: dateString,
        approved: approved,
        declined: declined,
        totalCalls: connected + (i * 3),
        connectedCalls: connected,
      ));
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Leads Dashboard',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: CustomColor.MainColor,
        elevation: 0.5,
      ),
      body: _isLoading
          ? Center(
              child: SpinKitFadingCircle(
                color: CustomColor.MainColor,
                size: 50.0,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SummaryCardsWidget(
                      ipApprovedToday: _ipApprovedToday,
                      ipDeclineToday: _ipDeclineToday,
                      todayLogin: _todayLogin,
                      approvalRate: _approvalRate,
                    ),
                    const SizedBox(height: 24),
                    CallSummaryWidget(
                      totalAttempted: _totalAttempted,
                      totalConnected: _totalConnected,
                      totalDuration: _totalDuration,
                      averageDuration: _formatAverageDuration(),
                      hourlyEfficiency: _hourlyCallEfficiency,
                    ),
                    const SizedBox(height: 24),
                    StatusChartWidget(statusCounts: _statusCounts),
                    const SizedBox(height: 24),
                    PerformanceTrendsWidget(
                      performanceData: _getPerformanceData(),
                    ),
                    const SizedBox(height: 24),
                    ConversionFunnelWidget(
                      totalLeads: _allLeads.length,
                      calledLeads: _allLeads.where((l) => l.callCount > 0).length,
                      connectedLeads: _allLeads.where((l) => l.lastCallDuration != null && l.lastCallDuration! > 0).length,
                      feedbackGiven: _allLeads.where((l) => _hasFeedback(l.lead.leadStatus)).length,
                      approvedLeads: _ipApprovedToday,
                    ),
                    const SizedBox(height: 24),
                    RecentLeadsWidget(recentLeads: _getRecentLeads()),
                  ],
                ),
              ),
            ),
    );
  }


}
