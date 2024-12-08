import 'package:flutter/material.dart';
import 'sample_page.dart'; // Import your sample page

class Dashboard {
  IconData? icon;
  String? title;
  String? count;
  Color? color;

  Dashboard({this.title, this.icon, this.count, this.color});

  static List<Dashboard> dashboardList = [
    Dashboard(title: 'Total Leads', count: '10', icon: Icons.leaderboard_rounded, color: Colors.red),
    Dashboard(title: 'Today Leads', count: '50', icon: Icons.today, color: Colors.cyan),
    Dashboard(title: 'Total Calls', count: '40', icon: Icons.call_missed_outgoing_sharp, color: Colors.green),
    Dashboard(title: 'Today Calls', count: '50', icon: Icons.call_missed, color: Colors.deepPurple),
  ];
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: ListView.builder(
        itemCount: Dashboard.dashboardList.length,
        itemBuilder: (context, index) {
          var dashboardItem = Dashboard.dashboardList[index];
          return GestureDetector(
            onTap: () {
              // Navigate to SamplePage on first item (index == 0)
              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SamplePage()), // Navigate to SamplePage
                );
              }
              // You can add more navigation conditions based on other icons
            },
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.all(10),
              child: ListTile(
                leading: Icon(dashboardItem.icon, color: dashboardItem.color),
                title: Text(dashboardItem.title ?? 'No Title'),
                subtitle: Text(dashboardItem.count ?? 'No Count'),
              ),
            ),
          );
        },
      ),
    );
  }
}
