import 'package:flutter/material.dart';

class SampleScreen extends StatelessWidget {
  const SampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sample Screen')),
      body: Center(
        child: Text('This is a sample screen.'),
      ),
    );
  }
}
