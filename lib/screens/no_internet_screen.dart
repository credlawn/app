import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:credlawn/api/server_api.dart';
import 'package:credlawn/helpers/error_logger.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.wifi_off, color: Colors.orange.shade600, size: 64),
              const SizedBox(height: 24),
              Text(
                'No Internet Connection',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to check for app updates. Please check your internet connection and try again.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isRetrying ? null : _retryConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRetrying ? Colors.grey : Colors.blue.shade600,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isRetrying
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Checking...',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Retry',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _retryConnection() async {
    setState(() {
      _isRetrying = true;
    });

    try {
      // Perform the version check directly
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      final response = await http.get(ServerApi.appVersion);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data != null && data['data'] != null) {
          String latestVersion = data['data']['latest_version'];
          String changeLog = data['data']['change_log'];
          String downloadUrl = data['data']['url'];

          if (currentVersion != latestVersion) {
            // Update available - pop this screen and let main.dart handle the update screen
            Navigator.of(context).pop(true); // Pop with success
            return;
          } else {
            // No update needed - pop this screen and continue to app
            Navigator.of(context).pop(true); // Pop with success
            return;
          }
        }
      }

      // If we reach here, there was still an error - keep the screen
      setState(() {
        _isRetrying = false;
      });

    } catch (e) {
      // Still no internet or other error - keep the screen
      await ErrorLogger.logException(
        context: 'NoInternetScreen._retryConnection',
        exception: e,
      );
      setState(() {
        _isRetrying = false;
      });
    }
  }
}
