import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/network/api_manager_dashboard_helper.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'today_details_screen.dart';
import 'mtd_details_screen.dart';

class ManagerHomeScreen extends StatefulWidget {
  final User user;

  const ManagerHomeScreen({super.key, required this.user});

  @override
  _ManagerHomeScreenState createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    final data = await getManagerDashboardData();
    setState(() {
      _dashboardData = data;
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchDashboardData();
  }

  double _calculateApprovalRatio(int approved, int declined) {
    int total = approved + declined;
    if (total == 0) return 0.0;
    return (approved / total) * 100;
  }

  Widget _buildDashboardCard(String title, dynamic value, Color color, {bool isPercentage = false, IconData? icon, bool showTrend = false, String? trend}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.04),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.06),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 6,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon ?? Icons.bar_chart,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 8),

          // Value with trend indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isPercentage ? '${value.toStringAsFixed(1)}%' : value.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (showTrend && trend != null) ...[
                const SizedBox(width: 4),
                Text(
                  trend,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 4),

          // Title
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onDetailsTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  color: CustomColor.MainColor,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: onDetailsTap,
            icon: Icon(
              Icons.info_outline,
              color: CustomColor.MainColor,
              size: 18,
            ),
            tooltip: 'View Details',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF8FAFC),
              const Color(0xFFF1F5F9),
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 2,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                CustomColor.MainColor,
                CustomColor.MainColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        title: Text(
          'Manager Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.person, color: Colors.white),
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen(user: widget.user)),
                );
              } else if (value == 'logout') {
                await SessionManager.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: CustomColor.MainColor),
                    const SizedBox(width: 8),
                    Text('Profile', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: CustomColor.MainColor),
                    const SizedBox(width: 8),
                    Text('Logout', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dashboardData == null
              ? Center(
                  child: Text(
                    'Failed to load dashboard data',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: CustomColor.MainColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Today', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TodayDetailsScreen(
                                employees: _dashboardData!['today']['employees'] ?? [],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                          children: [
                            _buildDashboardCard(
                              'IP Approved',
                              (_dashboardData!['today']['summary']['ip_approved'] ?? 0) as int,
                              const Color(0xFF16A34A), // Professional green
                              icon: Icons.check_circle,
                            ),
                            _buildDashboardCard(
                              'IP Decline',
                              (_dashboardData!['today']['summary']['ip_decline'] ?? 0) as int,
                              const Color(0xFFDC2626), // Professional red
                              icon: Icons.cancel,
                            ),
                            _buildDashboardCard(
                              'Approval Ratio',
                              _calculateApprovalRatio(
                                (_dashboardData!['today']['summary']['ip_approved'] ?? 0) as int,
                                (_dashboardData!['today']['summary']['ip_decline'] ?? 0) as int,
                              ),
                              const Color(0xFF2563EB), // Professional blue
                              icon: Icons.pie_chart,
                              isPercentage: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildSectionHeader('Month to Date', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MtdDetailsScreen(
                                employees: _dashboardData!['mtd']['employees'] ?? [],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                          children: [
                            _buildDashboardCard(
                              'IP Approved',
                              (_dashboardData!['mtd']['summary']['ip_approved'] ?? 0) as int,
                              const Color(0xFF16A34A), // Professional green
                              icon: Icons.check_circle,
                            ),
                            _buildDashboardCard(
                              'IP Decline',
                              (_dashboardData!['mtd']['summary']['ip_decline'] ?? 0) as int,
                              const Color(0xFFDC2626), // Professional red
                              icon: Icons.cancel,
                            ),
                            _buildDashboardCard(
                              'Approval Ratio',
                              _calculateApprovalRatio(
                                (_dashboardData!['mtd']['summary']['ip_approved'] ?? 0) as int,
                                (_dashboardData!['mtd']['summary']['ip_decline'] ?? 0) as int,
                              ),
                              const Color(0xFF2563EB), // Professional blue
                              icon: Icons.pie_chart,
                              isPercentage: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
