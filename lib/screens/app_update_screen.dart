import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';

class AppUpdateScreen extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;
  final String changeLog;
  final String url;

  const AppUpdateScreen({
    super.key,
    required this.currentVersion,
    required this.latestVersion,
    required this.changeLog,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AlertDialog(
        title: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey[100]!,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'Update Available',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CustomColor.MainColor,
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(
                'A new version of the app is available!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: CustomColor.MainColor,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Current Version: $currentVersion',
                style: GoogleFonts.poppins(fontSize: 14, color: CustomColor.MainColor, fontWeight: FontWeight.w400,),

              ),
              Text(
                'Latest Version: $latestVersion',
                style: GoogleFonts.poppins(fontSize: 14, color: CustomColor.MainColor, fontWeight: FontWeight.w400,),
              ),
              SizedBox(height: 20),
              Text(
                'What\'s New:',
                style: GoogleFonts.poppins(fontSize: 16, color: CustomColor.MainColor, fontWeight: FontWeight.w500,),
              ),
              SizedBox(height: 6),
              Text(
                changeLog,
                style: GoogleFonts.poppins(fontSize: 14, color: CustomColor.MainColor, fontWeight: FontWeight.w400,),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.MainColor,
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () async {
                final Uri uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open the update URL.')),
                  );
                }
              },
              child: Text(
                'Download Update',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> showAppUpdateDialog(
      BuildContext context, String currentVersion, String latestVersion, String changeLog, String url) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AppUpdateScreen(
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          changeLog: changeLog,
          url: url,
        );
      },
    );
  }
}
