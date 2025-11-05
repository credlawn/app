import 'package:flutter/material.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/screens/cards.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/attendance_screen.dart';
import '../screens/attendance_statistics_screen.dart';

class HrFragment extends StatefulWidget {
  const HrFragment({super.key});

  @override
  State<HrFragment> createState() => _HrFragmentState();
}

class _HrFragmentState extends State<HrFragment> {
  User? _user;
  List<Map<String, dynamic>> _hrSection = [];

  @override
  void initState() {
    super.initState();
    _loadUserDataAndBuildDashboard();
  }

  Future<void> _loadUserDataAndBuildDashboard() async {
    _user = await SessionManager.getSessionData();
    _buildHrItems();
    setState(() {});
  }

  void _buildHrItems() {
    final allItems = [
      {
        'icon': Icons.how_to_reg,
        'title': 'Attendance',
        'count': 0,
        'color': Color(0xFF10B981),
        'background': Color(0xFFFFFFFF),
        'screen': const AttendanceScreen(),
      },
      {
        'icon': Icons.bar_chart,
        'title': 'Statistics',
        'count': 0,
        'color': Color(0xFFF59E0B),
        'background': Color(0xFFFFFFFF),
        'screen': const AttendanceStatisticsScreen(),
      },
      {
        'icon': Icons.card_travel,
        'title': 'Cards',
        'count': 2,
        'color': Color(0xFF8B5CF6),
        'background': Color(0xFFFFFFFF),
        'screen': const CardsScreen(),
      },

    ];

    _hrSection = allItems.where((item) {
      if (item['title'] == 'Cards') {
        return _user?.role == 'Manager';
      }
      return true;
    }).toList();
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
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

  Widget _buildHrItem(Map<String, dynamic> item) {
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
          onTap: () => _navigateToScreen(item['screen']),
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
              if (item['count'] > 0)
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
                      item['count'] > 99 ? '99+' : item['count'].toString(),
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
            return _buildHrItem(item);
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
            _buildSection(_hrSection, "HR Management"),
          ],
        ),
      ),
    );
  }
}
