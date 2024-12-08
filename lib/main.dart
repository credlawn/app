import 'package:flutter/material.dart';
import 'package:credlawn/screens/login_screen.dart';
import 'package:credlawn/screens/home_screen.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Credlawn',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: FutureBuilder<User?>(
        future: _checkSession(),
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

  Future<User?> _checkSession() async {
    var sessionData = await SessionManager.getSessionData();
    return sessionData;
  }
}
