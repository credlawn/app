
import 'package:flutter/material.dart';

class NotificationDetailScreen extends StatelessWidget {
  final String title;
  final String body;

  const NotificationDetailScreen({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            body,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
