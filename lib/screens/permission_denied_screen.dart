import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDeniedScreen extends StatelessWidget {
  const PermissionDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone_missed, size: 80, color: Colors.redAccent),
              SizedBox(height: 20),
              Text(
                'Call Log Permission Required',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'This app requires access to your call logs to function correctly. Please grant the permission in your device settings.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Open app settings to allow user to grant permission manually
                  openAppSettings();
                },
                child: Text('Open App Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
