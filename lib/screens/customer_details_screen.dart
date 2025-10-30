import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/network/api_customer_details_helper.dart';
import 'package:credlawn/models/customer_details_model.dart';
import 'package:credlawn/network/api_login_link_helper.dart';
import 'package:credlawn/models/login_link_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:credlawn/network/api_error_logger_helper.dart';
import 'package:credlawn/helpers/app_state_manager.dart';
import 'package:credlawn/network/api_feedback_helper.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/screens/pre_approved_lead_screen.dart';
import 'package:credlawn/screens/login_screen.dart';
import 'package:credlawn/helpers/ocr_helper.dart';
import 'package:intl/intl.dart';
import 'package:credlawn/screens/components/feedback_dialog.dart';

import 'package:credlawn/screens/components/customer_info_cards.dart';
import 'package:credlawn/screens/components/login_links_section.dart';
import 'package:credlawn/helpers/database_service.dart';
import 'package:credlawn/models/leads_model.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final String mobileNo;
  final bool isAutoOpenedAfterCall;

  const CustomerDetailsScreen({super.key, required this.mobileNo, this.isAutoOpenedAfterCall = false});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  late Future<CustomerDetailsModel> _customerDetails;
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _referenceNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _customerDetails = _fetchCustomerDetailsFromLocalDB(widget.mobileNo);
  }

  Future<CustomerDetailsModel> _fetchCustomerDetailsFromLocalDB(String mobileNo) async {
    final LeadsModel? lead = await DatabaseService.instance.leadsRepository.getLeadByMobileNo(mobileNo);

    if (lead != null) {
      return CustomerDetailsModel(
        fullName: lead.customerName,
        segId: lead.segment,
        city: lead.city,
        productDesc: lead.product,
        checkdefectDesc: lead.declineReason,
        employer: lead.employer,
      );
    } else {
      throw Exception('No customer found with this mobile number in local DB.');
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _referenceNoController.dispose();
    super.dispose();
  }

  Future<void> _showFeedback() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return FeedbackDialog(mobileNo: widget.mobileNo);
      },
    );

    if (result == true) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(true);
      } else {
        final user = await SessionManager.getSessionData();
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PreApprovedLeadsScreen(user: user),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.isAutoOpenedAfterCall) {
          _showFeedback();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Customer Details', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
          backgroundColor: CustomColor.MainColor,
          elevation: 0.5,
          actions: [
            IconButton(
              icon: const Icon(Icons.feedback, color: Colors.white),
              onPressed: () => _showFeedback(),
            ),
          ],
        ),
        body: FutureBuilder<CustomerDetailsModel>(
          future: _customerDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: SpinKitCircle(color: CustomColor.MainColor));
            } else if (snapshot.hasError) {
              String errorMessage = snapshot.error.toString();
              logAppError(errorMessage: errorMessage, errorContext: "Customer Details Screen - Customer Details FutureBuilder");
              if (errorMessage.contains("No customer found with this mobile number in local DB.")) {
                return Center(
                  child: Text(
                    'No Customer found with this Mobile No in local database',
                    style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
                  ),
                );
              }
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
                    CustomerInfoCard(customer: customer, mobileNo: widget.mobileNo),
                    const SizedBox(height: 16),
                    ProductInfoCard(customer: customer),
                    const SizedBox(height: 24),
                    Text(
                      'Login Links:',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: CustomColor.MainColor),
                    ),
                    const SizedBox(height: 8),
                    const LoginLinksSection(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}