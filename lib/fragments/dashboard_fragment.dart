import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/sample_screen.dart'; // Make sure this path is correct

class DashboardFragment extends StatefulWidget {
  const DashboardFragment({super.key});

  @override
  State<DashboardFragment> createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment> {
  // Sample data to replace Dashboard.dashboardList for now
  final List<Map<String, dynamic>> mockData = [
    {
      'icon': Icons.home,
      'title': 'Home',
      'count': '5',
      'color': Colors.blue,
    },
    {
      'icon': Icons.card_travel,
      'title': 'Cards',
      'count': '2',
      'color': Colors.green,
    },
    {
      'icon': Icons.notifications,
      'title': 'Notifications',
      'count': '10',
      'color': Colors.red,
    },
    {
      'icon': Icons.settings,
      'title': 'Settings',
      'count': '8',
      'color': Colors.orange,
    },
    // Add more mock data if needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,  // Set the background color to white
      body: AlignedGridView.count(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        itemCount: mockData.length,
        crossAxisCount: 3,  // Set this to 3 to display 3 items per row
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Navigate to SampleScreen when any icon box is tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SampleScreen(),
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
                    mockData[index]['icon'],
                    size: 30.0,  // Smaller size for the icons (adjust as needed)
                    color: mockData[index]['color'],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        mockData[index]['title'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,  // Slightly smaller font size for the title
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        textAlign: TextAlign.center,
                        mockData[index]['count'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,  // Slightly smaller font size for the count
                          fontWeight: FontWeight.w700,
                          color: mockData[index]['color'],
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
