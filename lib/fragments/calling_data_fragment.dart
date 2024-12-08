import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';
import '../screens/normal_lead_screen.dart';
import '../screens/interested_lead_screen.dart';
import '../screens/pre_approved_lead_screen.dart';
import '../screens/new_card_login_screen.dart';
import '../screens/card_login_list_screen.dart';

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
      'title': 'Normal Leads',
      'color': Colors.blue,
    },
    {
      'icon': Icons.phone_in_talk,
      'title': 'Interested Leads',
      'color': Colors.orange,
    },
    {
      'icon': Icons.phone_forwarded,
      'title': 'Pre Approved Leads',
      'color': Colors.green,
    },
    {
      'icon': Icons.login,
      'title': 'New Login',
      'count': '',
      'color': Colors.blue,
    },
    {
      'icon': Icons.card_travel,
      'title': 'Card Login List',
      'color': Colors.green, 
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AlignedGridView.count(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        itemCount: mockCallingData.length,
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (mockCallingData[index]['title'] == 'Interested Leads') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InterestedLeadsScreen(user: widget.user),
                  ),
                );
              } else if (mockCallingData[index]['title'] == 'Pre Approved Leads') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreApprovedLeadsScreen(user: widget.user),
                  ),
                );
              } else if (mockCallingData[index]['title'] == 'Normal Leads') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NormalLeadsScreen(user: widget.user),
                  ),
                );
              } else if (mockCallingData[index]['title'] == 'New Login') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewCardLoginScreen(),
                  ),
                );
              } else if (mockCallingData[index]['title'] == 'Card Login List') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardLoginListScreen(user: widget.user),
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
                      fontSize: 14,
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