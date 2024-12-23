import 'package:credlawn/screens/follow_up_lead_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';
import '../screens/normal_lead_screen.dart';
import '../screens/interested_lead_screen.dart';
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
  final List<Map<String, dynamic>> mockCallingData = [
    {
      'icon': Icons.phone,
      'title': 'Normal',
      'color': Colors.blue,
    },
    {
      'icon': Icons.phone_in_talk,
      'title': 'Interested',
      'color': Colors.orange,
    },
    {
      'icon': Icons.phone_forwarded,
      'title': 'Pre Approved',
      'color': Colors.green,
    },
    {
      'icon': Icons.call_missed,
      'title': 'CNR',
      'color': Colors.red,
    },
    {
      'icon': Icons.calendar_today,
      'title': 'Follow-up',
      'color': Colors.purple,
    },
    {
      'icon': Icons.today,
      'title': 'Today\'s Login',
      'color': Colors.green,
    },
    {
      'icon': Icons.calendar_month,
      'title': 'Month Login',
      'color': Colors.teal,
    },
    {
      'icon': Icons.login,
      'title': 'New Login',
      'color': Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AlignedGridView.count(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        itemCount: mockCallingData.length,
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (mockCallingData[index]['title'] == 'Interested') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InterestedLeadsScreen(user: widget.user),
                  ),
                );
              } else if (mockCallingData[index]['title'] == 'Pre Approved') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreApprovedLeadsScreen(user: widget.user),
                  ),
                );
              } else if (mockCallingData[index]['title'] == 'Normal') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NormalLeadsScreen(user: widget.user),
                  ),
                );
              } else if (mockCallingData[index]['title'] == 'CNR') {
                if (widget.user.designation != null && widget.user.designation == 'Branch Manager') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManagerCnrLeadScreen(user: widget.user),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CnrLeadScreen(user: widget.user),
                    ),
                  );
                }
              } else if (mockCallingData[index]['title'] == 'Follow-up') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FollowUpLeadScreen(user: widget.user),
                  ),
                );
              } else if (mockCallingData[index]['title'] == 'Today\'s Login') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TodayLoginListScreen(user: widget.user),
                  ),
                );
              } else if (mockCallingData[index]['title'] == 'Month Login') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MonthLoginListScreen(user: widget.user),
                  ),
                );
              } else if (mockCallingData[index]['title'] == 'New Login') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewCardLoginScreen(),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(80),
                    blurRadius: 1.5,
                    spreadRadius: 1.5,
                  )
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    mockCallingData[index]['icon'],
                    size: 30.0,
                    color: mockCallingData[index]['color'],
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    mockCallingData[index]['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
