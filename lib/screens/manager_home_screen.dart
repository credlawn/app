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

  Widget _buildDashboardCard(String title, int count, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bar_chart,
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onDetailsTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        IconButton(
          onPressed: onDetailsTap,
          icon: Icon(
            Icons.info_outline,
            color: CustomColor.MainColor,
            size: 24,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0.5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(0),
            bottomLeft: Radius.circular(0),
          ),
        ),
        title: Text(
          'Manager Dashboard',
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: CustomColor.MainColor,
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
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: [
                            _buildDashboardCard(
                              'IP Approved',
                              (_dashboardData!['today']['summary']['ip_approved'] ?? 0) as int,
                              const Color(0xFF10B981),
                            ),
                            _buildDashboardCard(
                              'IP Decline',
                              (_dashboardData!['today']['summary']['ip_decline'] ?? 0) as int,
                              const Color(0xFFEF4444),
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
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: [
                            _buildDashboardCard(
                              'IP Approved',
                              (_dashboardData!['mtd']['summary']['ip_approved'] ?? 0) as int,
                              const Color(0xFF10B981),
                            ),
                            _buildDashboardCard(
                              'IP Decline',
                              (_dashboardData!['mtd']['summary']['ip_decline'] ?? 0) as int,
                              const Color(0xFFEF4444),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
