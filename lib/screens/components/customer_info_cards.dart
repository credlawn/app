
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/models/customer_details_model.dart';

class CustomerInfoCard extends StatelessWidget {
  final CustomerDetailsModel customer;
  final String mobileNo;

  const CustomerInfoCard({
    super.key,
    required this.customer,
    required this.mobileNo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRowInCard('Name', customer.fullName),
            const Divider(color: Colors.grey),
            _buildDetailRowInCard('Mobile', mobileNo),
            const Divider(color: Colors.grey),
            _buildDetailRowInCard('City', customer.city),
            const Divider(color: Colors.grey),
            _buildDetailRowInCard('Employer', customer.employer),
          ],
        ),
      ),
    );
  }
}

class ProductInfoCard extends StatelessWidget {
  final CustomerDetailsModel customer;

  const ProductInfoCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRowInCard('Segment', customer.segId),
            const Divider(color: Colors.grey),
            _buildDetailRowInCard('Reason', customer.checkdefectDesc),
            const Divider(color: Colors.grey),
            _buildDetailRowInCard('Product', customer.productDesc),
          ],
        ),
      ),
    );
  }
}

Widget _buildDetailRowInCard(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: CustomColor.MainColor),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    ),
  );
}
