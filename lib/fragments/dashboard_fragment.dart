import 'package:flutter/material.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/screens/cards.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/attendance_screen.dart'; 

class DashboardFragment extends StatefulWidget {
  const DashboardFragment({super.key});

  @override
  State<DashboardFragment> createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment> {
  User? _user;
  List<Map<String, dynamic>> _dashboardItems = [];

  @override
  void initState() {
    super.initState();
    _loadUserDataAndBuildDashboard();
  }

  Future<void> _loadUserDataAndBuildDashboard() async {
    _user = await SessionManager.getSessionData();
    _buildDashboardItems();
    setState(() {});
  }

  void _buildDashboardItems() {
    final allItems = [
      {
        'icon': Icons.how_to_reg,
        'title': 'Attendance',
        'count': '',
        'color': Colors.green,
        'screen': const AttendanceScreen(),
      },
      {
        'icon': Icons.card_travel,
        'title': 'Cards',
        'count': '2',
        'color': Colors.green,
        'screen': const CardsScreen(),
      },
      
    ];

    _dashboardItems = allItems.where((item) {
      if (item['title'] == 'Cards') {
        return _user?.role == 'Manager';
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: AlignedGridView.count(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        itemCount: _dashboardItems.length,
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _dashboardItems[index]['screen'],
                ),
              );
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
                children: [
                  Icon(
                    _dashboardItems[index]['icon'],
                    size: 30.0, 
                    color: _dashboardItems[index]['color'],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        _dashboardItems[index]['title'],
                        style: GoogleFonts.poppins(
                          fontSize: 12, 
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        textAlign: TextAlign.center,
                        _dashboardItems[index]['count'],
                        style: GoogleFonts.poppins(
                          fontSize: 12, 
                          fontWeight: FontWeight.w700,
                          color: _dashboardItems[index]['color'],
                        ),
                      ),
                    ],
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
