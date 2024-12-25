// kyc_status_update_screen.dart

import 'package:flutter/material.dart';

class KYCStatusUpdateScreen extends StatelessWidget {
  final String customerName;
  final String kycStatus;

  const KYCStatusUpdateScreen({
    super.key,
    required this.customerName,
    required this.kycStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update KYC Status'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer: $customerName',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Current KYC Status: $kycStatus',
              style: TextStyle(fontSize: 16),
            ),
            // You can add the actual update form here
          ],
        ),
      ),
    );
  }
}
