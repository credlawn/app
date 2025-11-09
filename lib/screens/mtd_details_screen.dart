import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class MtdDetailsScreen extends StatefulWidget {
  final List<dynamic> employees;

  const MtdDetailsScreen({super.key, required this.employees});

  @override
  _MtdDetailsScreenState createState() => _MtdDetailsScreenState();
}

class _MtdDetailsScreenState extends State<MtdDetailsScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _shareScreenshot() async {
    try {
      final imageBytes = await _screenshotController.capture();
      if (imageBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final fileName = 'manager_dashboard_month_to_date_$timestamp.png';
        final file = File('${tempDir.path}/$fileName');

        await file.writeAsBytes(imageBytes);
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Manager Dashboard Month to Date Report - ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
          subject: 'Manager Dashboard MTD Screenshot',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to share screenshot'), duration: Duration(seconds: 2)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalApproved = widget.employees.fold(0, (sum, emp) => sum + ((emp['ip_approved'] ?? 0) as int));
    int totalDecline = widget.employees.fold(0, (sum, emp) => sum + ((emp['ip_decline'] ?? 0) as int));
    int grandTotal = totalApproved + totalDecline;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Month to Date Details', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
        backgroundColor: CustomColor.MainColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareScreenshot,
            tooltip: 'Share MTD Report',
          ),
        ],
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text('Employee Name', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]))),
                      Expanded(flex: 2, child: Text('IP Approved', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]), textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: Text('IP Decline', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]), textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: Text('Total', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]), textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                // Table Rows
                ...widget.employees.map((employee) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1))),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(employee['employee_name'] ?? 'Unknown', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]))),
                        Expanded(flex: 2, child: Text(((employee['ip_approved'] ?? 0) as int).toString(), style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF10B981), fontWeight: FontWeight.w500), textAlign: TextAlign.center)),
                        Expanded(flex: 2, child: Text(((employee['ip_decline'] ?? 0) as int).toString(), style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFFEF4444), fontWeight: FontWeight.w500), textAlign: TextAlign.center)),
                        Expanded(flex: 2, child: Text(((employee['total'] ?? 0) as int).toString(), style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800], fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                      ],
                    ),
                  );
                }),
                // Total Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text('TOTAL', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[800]))),
                      Expanded(flex: 2, child: Text(totalApproved.toString(), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)), textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: Text(totalDecline.toString(), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444)), textAlign: TextAlign.center)),
                      Expanded(flex: 2, child: Text(grandTotal.toString(), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[800]), textAlign: TextAlign.center)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
