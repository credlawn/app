import 'package:credlawn/screens/follow_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';
import '../network/api_follow_up_helper.dart';
import '../screens/pre_approved_lead_screen.dart';
import '../screens/new_card_login_screen.dart';
import '../screens/today_login_list_screen.dart';
import '../screens/month_login_list_screen.dart';
import '../screens/cnr_lead_screen.dart';
import '../screens/manager_cnr_lead_screen.dart';

class CallingDataFragment extends StatefulWidget {
  final User user;

  const CallingDataFragment({super.key, required this.user});

  @override
  State<CallingDataFragment> createState() => _CallingDataFragmentState();
}

class _CallingDataFragmentState extends State<CallingDataFragment> {
  int _followUpCount = 0;
  final List<Map<String, dynamic>> _dashboardItems = [
    {
      'icon': Icons.phone_forwarded,
      'title': 'Pre Approved',
      'color': Color(0xFF10B981),
      'background': Color(0xFFECFDF5),
    },
    {
      'icon': Icons.call_missed,
      'title': 'CNR',
      'color': Color(0xFFEF4444),
      'background': Color(0xFFFEF2F2),
    },
    {
      'icon': Icons.calendar_today,
      'title': 'Follow-up',
      'color': Color(0xFF8B5CF6),
      'background': Color(0xFFF5F3FF),
    },
    {
      'icon': Icons.today,
      'title': 'Today\'s Login',
      'color': Color(0xFF06B6D4),
      'background': Color(0xFFF0FDFA),
    },
    {
      'icon': Icons.calendar_month,
      'title': 'Month Login',
      'color': Color(0xFFF59E0B),
      'background': Color(0xFFFFFBEB),
    },
    {
      'icon': Icons.login,
      'title': 'New Login',
      'color': Color(0xFF3B82F6),
      'background': Color(0xFFEFF6FF),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.isCurrent == true) {
      _fetchFollowUpCount();
    }
  }

  Future<void> _loadData() async {
    setState(() {});
  }

  Future<void> _fetchFollowUpCount() async {
    final count = await getUpcomingFollowUpsCount();
    setState(() {
      _followUpCount = count;
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
    };

    if (screenMap.containsKey(title)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screenMap[title]!),
      );
    }
  }

  Widget _buildDashboardItem(Map<String, dynamic> item, int index) {
    final hasNotification = item['title'] == 'Follow-up' && _followUpCount > 0;
    
    return Container(
      decoration: BoxDecoration(
        color: item['background'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 1,
            offset: Offset(0, 2),
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
                        color: item['color'].withOpacity(0.1),
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
              if (hasNotification)
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
                      _followUpCount > 99 ? '99+' : _followUpCount.toString(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AlignedGridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: _dashboardItems.length,
          itemBuilder: (context, index) {
            return _buildDashboardItem(_dashboardItems[index], index);
          },
        ),
      ),
    );
  }
}