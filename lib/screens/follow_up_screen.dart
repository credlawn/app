import 'package:credlawn/screens/customer_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/models/follow_up_model.dart';
import 'package:credlawn/network/api_follow_up_helper.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class FollowUpScreen extends StatefulWidget {
  const FollowUpScreen({super.key});

  @override
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen> {
  late Future<List<FollowUp>> _followUps;

  @override
  void initState() {
    super.initState();
    _followUps = getFollowUps();
  }

  void _openWhatsApp(String mobileNo) async {
    final mobileWithCode = '+91$mobileNo';
    final String androidUrl = "whatsapp://send?phone=$mobileWithCode&text=https://cipl.me/tata";
    final String iosUrl = "https://wa.me/$mobileWithCode?text=${Uri.parse('https://cipl.me/tata')}";

    try {
      if (Platform.isIOS) {
        await launchUrl(Uri.parse(iosUrl));
      } else {
        await launchUrl(Uri.parse(androidUrl));
      }
    } catch (e) {
      print("Could not open WhatsApp: $e");
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (date.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (date.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else {
      return DateFormat('EEEE, MMM d').format(date);
    }
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  void _showActionMenu(BuildContext context, FollowUp followUp) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.message, color: Colors.green),
                title: Text('Send Message', style: GoogleFonts.inter()),
                onTap: () {
                  Navigator.pop(context);
                  _openWhatsApp(followUp.mobileNo);
                },
              ),
              ListTile(
                leading: Icon(Icons.done_all, color: CustomColor.MainColor),
                title: Text('Mark As Done', style: GoogleFonts.inter()),
                onTap: () {
                  Navigator.pop(context);
                  _markAsDone(followUp.mobileNo);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _markAsDone(String mobileNo) {
    print('Mark as done for mobileNo: $mobileNo');
  }

  Widget _buildCustomerCard(FollowUp followUp, String header) {
    final time = DateFormat('hh:mm a').format(DateFormat('hh:mm:ss').parse(followUp.followUpTime));
    final isMissed = header == 'Missed';
    final isToday = header == 'Today';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isMissed 
            ? Border.all(color: Colors.red.withOpacity(0.3), width: 1)
            : isToday
              ? Border.all(color: Colors.green.withOpacity(0.3), width: 1)
              : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          title: Text(
            _toTitleCase(followUp.customerName),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          subtitle: Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: CustomColor.MainColor,
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey[600]!.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]!, size: 18),
                  onPressed: () => _showActionMenu(context, followUp),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CustomColor.MainColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.call, color: CustomColor.MainColor, size: 24),
                  onPressed: () async {
                    await FlutterPhoneDirectCaller.callNumber(followUp.mobileNo);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerDetailsScreen(
                          mobileNo: followUp.mobileNo,
                          isAutoOpenedAfterCall: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerDetailsScreen(
                  mobileNo: followUp.mobileNo,
                  isAutoOpenedAfterCall: false,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String header, int count) {
    Color headerColor;
    Color backgroundColor;

    if (header == 'Missed') {
      headerColor = Colors.red;
      backgroundColor = Colors.red.withOpacity(0.1);
    } else if (header == 'Today') {
      headerColor = Colors.green;
      backgroundColor = Colors.green.withOpacity(0.1);
    } else if (header == 'Tomorrow') {
      headerColor = Colors.orange;
      backgroundColor = Colors.orange.withOpacity(0.1);
    } else {
      headerColor = CustomColor.MainColor;
      backgroundColor = CustomColor.MainColor.withOpacity(0.1);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            header,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: headerColor,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: headerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Follow Ups',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: CustomColor.MainColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: FutureBuilder<List<FollowUp>>(
        future: _followUps,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitCircle(
                    color: CustomColor.MainColor,
                    size: 40.0,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading follow-ups...',
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load follow-ups',
                    style: GoogleFonts.inter(
                      color: Colors.grey[800],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please try again later',
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule,
                    color: Colors.grey[400],
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No follow-ups scheduled',
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All caught up!',
                    style: GoogleFonts.inter(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          } else {
            final allFollowUps = snapshot.data!;
            final Map<String, List<FollowUp>> groupedFollowUps = {};

            final missedFollowUps = allFollowUps.where((fu) => fu.status == 'Missed').toList();
            if (missedFollowUps.isNotEmpty) {
              groupedFollowUps['Missed'] = missedFollowUps;
            }

            final upcomingFollowUps = allFollowUps.where((fu) => fu.status == 'Upcoming').toList();
            upcomingFollowUps.sort((a, b) {
              final dateTimeA = DateFormat('yyyy-MM-dd hh:mm:ss').parse('${a.followUpDate} ${a.followUpTime}');
              final dateTimeB = DateFormat('yyyy-MM-dd hh:mm:ss').parse('${b.followUpDate} ${b.followUpTime}');
              return dateTimeA.compareTo(dateTimeB);
            });

            for (var followUp in upcomingFollowUps) {
              final date = DateFormat('yyyy-MM-dd').parse(followUp.followUpDate);
              final header = _formatDateHeader(date);
              if (!groupedFollowUps.containsKey(header)) {
                groupedFollowUps[header] = [];
              }
              groupedFollowUps[header]!.add(followUp);
            }

            final List<Widget> followUpWidgets = [];

            groupedFollowUps.forEach((header, followUps) {
              followUpWidgets.add(_buildSectionHeader(header, followUps.length));
              for (var followUp in followUps) {
                followUpWidgets.add(_buildCustomerCard(followUp, header));
              }
              followUpWidgets.add(const SizedBox(height: 4));
            });

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: followUpWidgets,
            );
          }
        },
      ),
    );
  }
}