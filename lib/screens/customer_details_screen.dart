import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/network/api_customer_details_helper.dart';
import 'package:credlawn/models/customer_details_model.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final String mobileNo;

  const CustomerDetailsScreen({super.key, required this.mobileNo});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  late Future<CustomerDetailsModel> _customerDetails;

  @override
  void initState() {
    super.initState();
    _customerDetails = fetchCustomerDetails(widget.mobileNo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Customer Details', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
        backgroundColor: CustomColor.MainColor,
        elevation: 0.5,
      ),
      body: FutureBuilder<CustomerDetailsModel>(
        future: _customerDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: SpinKitCircle(color: CustomColor.MainColor));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No customer details available.'));
          } else {
            final customer = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First Card: Name, Mobile, City, Employer
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 1, // Changed elevation to 1
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade300, width: 1), // Added border
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRowInCard('Name', customer.fullName),
                          const Divider(color: Colors.grey), // Added Divider
                          _buildDetailRowInCard('Mobile', widget.mobileNo),
                          const Divider(color: Colors.grey), // Added Divider
                          _buildDetailRowInCard('City', customer.city),
                          const Divider(color: Colors.grey), // Added Divider
                          _buildDetailRowInCard('Employer', customer.employer),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Spacing between cards

                  // Second Card: Segment, Reason, Product
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 1, // Changed elevation to 1
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade300, width: 1), // Added border
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRowInCard('Segment', customer.segId),
                          const Divider(color: Colors.grey), // Added Divider
                          _buildDetailRowInCard('Reason', customer.checkdefectDesc),
                          const Divider(color: Colors.grey), // Added Divider
                          _buildDetailRowInCard('Product', customer.productDesc),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRowInCard(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Increased vertical padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // Adjusted width for label
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
}