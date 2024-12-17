import 'package:flutter/material.dart';
import 'package:credlawn/screens/login_screen.dart';
import 'package:credlawn/screens/home_screen.dart';
import 'package:credlawn/screens/app_update_screen.dart'; // Import AppUpdateScreen
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Global navigator key for global navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Ensure Flutter bindings are initialized before calling `runApp()`
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,  // Set the global navigator key
      title: 'Credlawn',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
        dialogBackgroundColor: Colors.white,
        buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
      ),
      home: FutureBuilder<User?>(
        future: _checkSession(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading session'));
          } else if (snapshot.hasData && snapshot.data != null) {
            return HomeScreen(user: snapshot.data!);
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }

  Future<User?> _checkSession(BuildContext context) async {
    var sessionData = await SessionManager.getSessionData();
    await _checkAppVersion(); // Check app version after loading session
    return sessionData;
  }

  Future<void> _checkAppVersion() async {
    try {
      // Get the current version from package_info_plus
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version; // Fetch current version

      // Fetch the latest version and changelog from the API
      final response = await http.get(Uri.parse('https://cipl.me/api/resource/Mobile App/latest'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Validate the response structure
        if (data != null && data['data'] != null) {
          String latestVersion = data['data']['latest_version'];
          String changeLog = data['data']['change_log'];
          String downloadUrl = data['data']['url'];

          if (currentVersion != latestVersion) {
            // Delay navigation to ensure context is valid
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Use the global navigator key to push the update screen
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => AppUpdateScreen(
                    currentVersion: currentVersion,
                    latestVersion: latestVersion,
                    changeLog: changeLog,
                    url: downloadUrl,
                  ),
                ),
              );
            });
          }
        } else {
          throw Exception('Invalid API response structure');
        }
      } else {
        throw Exception('Failed to fetch latest version');
      }
    } catch (e) {
      // You could show a Snackbar or some error UI here instead of just printing
      print('Error checking app version: $e');
      // You can also add error handling here like showing a Snackbar
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Error checking app version. Please try again later.')),
      );
    }
  }
}
