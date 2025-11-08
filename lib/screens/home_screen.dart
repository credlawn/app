// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/fragments/dashboard_fragment.dart';
import 'package:credlawn/fragments/cards_fragment.dart';
import 'package:credlawn/fragments/hr_fragment.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'login_screen.dart';
import 'profile_screen.dart';


class HomeScreen extends StatefulWidget {
  final User user;
  final int selectedTab;

  const HomeScreen({super.key, required this.user, this.selectedTab = 2});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _navBar;
  late List<Widget> _fragment; // Declare fragments as a late list

  String title = 'Dashboard';

  @override
  void initState() {
    super.initState();
    _navBar = widget.selectedTab;
    title = _navBar == 0 ? 'Cards' : (_navBar == 1 ? 'HR' : 'Dashboard');
  }

  @override
  Widget build(BuildContext context) {
    // Initialize the fragments here where widget.user is accessible
    _fragment = [
      CardsFragment(user: widget.user),
      const HrFragment(),
      DashboardFragment(user: widget.user),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(0),
            bottomLeft: Radius.circular(0),
          ),
        ),
        title: Text(
          title,
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

      body: _fragment[_navBar], // Display selected fragment based on navBar index
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.poppins(),
        selectedItemColor: CustomColor.MainColor,
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: _navBar == 0
                ? const Icon(Icons.credit_card)
                : const Icon(Icons.credit_card),
            label: 'Cards',
          ),
          BottomNavigationBarItem(
            icon: _navBar == 1
                ? const Icon(Icons.business)
                : const Icon(Icons.business),
            label: 'HR',
          ),
          BottomNavigationBarItem(
            icon: _navBar == 2
                ? const Icon(Icons.home)
                : const Icon(Icons.home),
            label: 'Dashboard',
          ),
        ],
        currentIndex: _navBar,
        onTap: (value) {
          setState(() {
            _navBar = value;
            title = _navBar == 0
                ? 'Cards'
                : _navBar == 1
                    ? 'HR'
                    : 'Dashboard';
          });
        },
      ),
    );
  }
}
