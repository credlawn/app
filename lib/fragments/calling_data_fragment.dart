import 'package:credlawn/network/api_fcm_log_helper.dart';
import 'package:credlawn/screens/follow_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';
import '../network/api_follow_up_helper.dart';
import '../screens/pre_approved_lead_screen.dart';
import '../screens/new_card_login_screen.dart';
import '../screens/today_login_list_screen.dart';
import '../screens/month_login_list_screen.dart';
import '../screens/cnr_lead_screen.dart';
import '../screens/manager_cnr_lead_screen.dart';
import '../screens/fcm_log_screen.dart';

class CallingDataFragment extends StatefulWidget {
  final User user;

  const CallingDataFragment({super.key, required this.user});

  @override
  State<CallingDataFragment> createState() => _CallingDataFragmentState();
}

class _CallingDataFragmentState extends State<CallingDataFragment> {
  int _followUpCount = 0;
  int _unreadNotificationCount = 0;
  
  final List<Map<String, dynamic>> _leadsSection = [
    {
      'icon': Icons.phone_forwarded,
      'title': 'Pre Approved',
      'color': Color(0xFF10B981),
      'background': Color(0xFFFFFFFF),
    },
    {
      'icon': Icons.call_missed,
      'title': 'CNR',
      'color': Color(0xFFEF4444),
      'background': Color(0xFFFFFFFF),
    },
    {
      'icon': Icons.calendar_today,
      'title': 'Follow-up',
      'color': Color(0xFF8B5CF6),
      'background': Color(0xFFFFFFFF),
    },
  ];

  final List<Map<String, dynamic>> _loginSection = [
    {
      'icon': Icons.today,
      'title': 'Today\'s Login',
      'color': Color(0xFF06B6D4),
      'background': Color(0xFFFFFFFF),
    },
    {
      'icon': Icons.calendar_month,
      'title': 'Month Login',
      'color': Color(0xFFF59E0B),
      'background': Color(0xFFFFFFFF),
    },
    {
      'icon': Icons.login,
      'title': 'New Login',
      'color': Color(0xFF3B82F6),
      'background': Color(0xFFFFFFFF),
    },
  ];

  final List<Map<String, dynamic>> _systemSection = [
    {
      'icon': Icons.notifications,
      'title': 'Notifications',
      'color': Color(0xFFEC4899),
      'background': Color(0xFFFFFFFF),
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchFollowUpCount();
    _fetchUnreadNotificationCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.isCurrent == true) {
      _fetchFollowUpCount();
      _fetchUnreadNotificationCount();
    }
  }

  Future<void> _fetchFollowUpCount() async {
    final count = await getUpcomingFollowUpsCount();
    setState(() {
      _followUpCount = count;
    });
  }

  Future<void> _fetchUnreadNotificationCount() async {
    final count = await getUnreadFcmLogsCount();
    setState(() {
      _unreadNotificationCount = count;
    });
  }

  void _navigateToScreen(String title) {
    final Map<String, Widget> screenMap = {
      'Pre Approved': PreApprovedLeadsScreen(user: widget.user),
      'CNR': widget.user.designation != null && widget.user.designation == 'Branch Manager' 
          ? ManagerCnrLeadScreen(user: widget.user)
          : CnrLeadScreen(user: widget.user),
      'Follow-up': FollowUpScreen(),
      'Today\'s Login': TodayLoginListScreen(user: widget.user),
      'Month Login': MonthLoginListScreen(user: widget.user),
      'New Login': const NewCardLoginScreen(),
      'Notifications': const FcmLogScreen(),
    };

    if (screenMap.containsKey(title)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screenMap[title]!),
      );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 16, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(Map<String, dynamic> item, int notificationCount) {
    return Container(
      decoration: BoxDecoration(
        color: item['background'],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToScreen(item['title']),
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item['color'].withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'],
                        size: 22,
                        color: item['color'],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              if (notificationCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 3,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      notificationCount > 99 ? '99+' : notificationCount.toString(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(List<Map<String, dynamic>> items, String sectionTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(sectionTitle),
        GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            int notificationCount = 0;
            if (item['title'] == 'Follow-up') {
              notificationCount = _followUpCount;
            } else if (item['title'] == 'Notifications') {
              notificationCount = _unreadNotificationCount;
            }
            return _buildDashboardItem(item, notificationCount);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(_leadsSection, "Leads Management"),
            SizedBox(height: 20),
            _buildSection(_loginSection, "Login Data"),
            SizedBox(height: 20),
            _buildSection(_systemSection, "System"),
          ],
        ),
      ),
    );
  }
}