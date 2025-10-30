// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/fragments/calling_data_fragment.dart';
import 'package:credlawn/fragments/cards_fragment.dart';
import 'package:credlawn/fragments/dashboard_fragment.dart';
import 'package:credlawn/models/user.dart';
import 'drawer_home_screen.dart'; // Import drawer
import 'package:credlawn/helpers/call_log_sync_manager.dart';
import 'package:credlawn/network/api_error_logger_helper.dart'; // Import api_error_logger_helper


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

  String title = 'HR';

  @override
  void initState() {
    super.initState();
    _navBar = widget.selectedTab;
    title = _navBar == 0 ? 'HR' : (_navBar == 1 ? 'Cards' : 'Dashboard');
  }

  @override
  Widget build(BuildContext context) {
    // Initialize the fragments here where widget.user is accessible
    _fragment = [
      const DashboardFragment(),
      CardsFragment(user: widget.user),
      CallingDataFragment(user: widget.user), // Now this works correctly
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
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please Wait...'),
                  backgroundColor: Colors.blueGrey,
                ),
              );
              try {
                await CallLogSyncManager.syncCallLogs();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lead Status synced successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                logAppError(errorMessage: e.toString(), errorContext: "Home Screen - Manual Sync Button");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sync failed: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      drawer: DrawerHomeScreen(user: widget.user),
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
                ? const Icon(Icons.business)
                : const Icon(Icons.business),
            label: 'HR',
          ),
          BottomNavigationBarItem(
            icon: _navBar == 1
                ? const Icon(Icons.credit_card)
                : const Icon(Icons.credit_card),
            label: 'Cards',
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
                ? 'HR'
                : _navBar == 1
                    ? 'Cards'
                    : 'Dashboard';
          });
        },
      ),
    );
  }
}
