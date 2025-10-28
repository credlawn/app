
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/models/login_link_model.dart';
import 'package:credlawn/network/api_login_link_helper.dart';
import 'package:credlawn/network/api_error_logger_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginLinksSection extends StatefulWidget {
  const LoginLinksSection({super.key});

  @override
  State<LoginLinksSection> createState() => _LoginLinksSectionState();
}

class _LoginLinksSectionState extends State<LoginLinksSection> {
  late Future<List<LoginLinkModel>> _loginLinks;

  @override
  void initState() {
    super.initState();
    _loginLinks = fetchLoginLinks();
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LoginLinkModel>>(
      future: _loginLinks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          String errorMessage = snapshot.error.toString();
          logAppError(errorMessage: errorMessage, errorContext: "Customer Details Screen - Login Links FutureBuilder");
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No login links available.'));
        } else {
          final links = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: links.map((link) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Link for ',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          link.linkType,
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await _launchUrl(link.link);
                        } catch (e) {
                          logAppError(errorMessage: e.toString(), errorContext: "Customer Details Screen - Launch URL");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.MainColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      child: Text(
                        'Apply',
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }
}
