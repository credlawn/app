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
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:credlawn/screens/customer_details_screen.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDashboardData,
          ),
        ],
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
                    _buildSummaryCards(),
                    const SizedBox(height: 24),
                    _buildCallSummary(),
                    const SizedBox(height: 24),
                    _buildStatusChart(),
                    const SizedBox(height: 24),
                    _buildRecentLeads(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildSummaryCard(
          title: 'IP Approved',
          value: _ipApprovedToday.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        _buildSummaryCard(
          title: 'IP Decline',
          value: _ipDeclineToday.toString(),
          icon: Icons.cancel,
          color: Colors.red,
        ),
        _buildSummaryCard(
          title: 'Today Login',
          value: _todayLogin.toString(),
          icon: Icons.login,
          color: Colors.blue,
        ),
        _buildSummaryCard(
          title: 'Approval Rate',
          value: '${_approvalRate.toStringAsFixed(1)}%',
          icon: Icons.trending_up,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Call Performance Summary',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildCallSummaryItem(
            icon: Icons.phone,
            label: 'Total Attempts',
            value: _totalAttempted.toString(),
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildCallSummaryItem(
            icon: Icons.call,
            label: 'Connected Calls',
            value: _totalConnected.toString(),
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildCallSummaryItem(
            icon: Icons.timer,
            label: 'Total Talk Time',
            value: _formatDuration(_totalDuration),
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildCallSummaryItem(
            icon: Icons.av_timer,
            label: 'Avg Call Duration',
            value: _formatAverageDuration(),
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildCallSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leads by Status',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          if (_statusCounts.isEmpty)
            Container(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Have you started your work today?',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No leads worked on yet',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: _getPieChartSections(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      centerSpaceColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildChartLegend(),
              ],
            ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    final sections = <PieChartSectionData>[];
    int colorIndex = 0;

    final totalFilteredLeads = _statusCounts.values.fold(0, (sum, count) => sum + count);

    _statusCounts.forEach((status, count) {
      final percentage = (totalFilteredLeads > 0) ? (count / totalFilteredLeads) * 100 : 0;
      sections.add(
        PieChartSectionData(
          value: count.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          color: colors[colorIndex % colors.length],
        ),
      );
      colorIndex++;
    });

    return sections;
  }

  Widget _buildChartLegend() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: _statusCounts.entries.map((entry) {
        final index = _statusCounts.keys.toList().indexOf(entry.key);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${entry.key}: ${entry.value}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRecentLeads() {
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Leads',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentLeads.length,
            itemBuilder: (context, index) {
              final leadWithInfo = recentLeads[index];
              return _buildRecentLeadItem(leadWithInfo);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLeadItem(LeadWithCallInfo leadWithInfo) {
    final lead = leadWithInfo.lead;

    Color statusColor;
    switch (lead.leadStatus) {
      case 'New':
        statusColor = Colors.blue;
        break;
      case 'Called':
        statusColor = Colors.green;
        break;
      case 'Failed':
      case 'Customer Denied':
      case 'Docs Not Available':
        statusColor = Colors.red;
        break;
      case 'IP Approved':
      case 'IP Decline':
        statusColor = Colors.orange;
        break;
      case 'Follow up':
        statusColor = Colors.purple;
        break;
      default:
        statusColor = Colors.grey;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      title: Text(
        lead.customerName,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Container(
        padding: const EdgeInsets.only(top: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: IntrinsicWidth(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 100, minWidth: 50),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                lead.leadStatus ?? 'Unknown',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${leadWithInfo.callCount} calls',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          if (leadWithInfo.lastCallDuration != null && leadWithInfo.lastCallDuration! > 0)
            Text(
              '${leadWithInfo.lastCallDuration}s',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerDetailsScreen(mobileNo: lead.mobileNo),
          ),
        );
      },
    );
  }

  String _formatAllocationDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd').format(date);
    } catch (e) {
      return 'N/A';
    }
  }
}
