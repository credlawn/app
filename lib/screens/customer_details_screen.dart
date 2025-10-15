import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/network/api_customer_details_helper.dart';
import 'package:credlawn/models/customer_details_model.dart';
import 'package:credlawn/network/api_login_link_helper.dart'; // Import api_login_link_helper
import 'package:credlawn/models/login_link_model.dart'; // Import LoginLinkModel
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:credlawn/network/api_error_logger_helper.dart'; // Import api_error_logger_helper
import 'package:credlawn/helpers/app_state_manager.dart';
import 'package:credlawn/network/api_feedback_helper.dart'; // Import api_feedback_helper
import 'package:credlawn/models/user.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/screens/pre_approved_lead_screen.dart';
import 'package:credlawn/screens/login_screen.dart';

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
    _customerDetails = fetchCustomerDetails(widget.mobileNo);
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _referenceNoController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _showFeedbackDialog(BuildContext context) async {
    String? selectedStatus;
    final List<String> statusOptions = [
      'IP Approved',
      'IP Decline',
      'Customer Denied',
      'Docs Not Available',
      'Already Carded',
      'Recently Applied',
      'CNR'
    ];

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Provide Feedback', style: GoogleFonts.poppins()),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Mobile Number: ${widget.mobileNo}', style: GoogleFonts.poppins()),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Status',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedStatus,
                      hint: Text('Select Status'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedStatus = newValue;
                          _remarksController.clear();
                          _referenceNoController.clear();
                        });
                      },
                      items: statusOptions.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    if (selectedStatus == 'IP Approved')
                      TextField(
                        controller: _referenceNoController,
                        decoration: InputDecoration(
                          labelText: 'Reference No',
                          border: OutlineInputBorder(),
                        ),
                      )
                    else if (selectedStatus != null)
                      TextField(
                        controller: _remarksController,
                        decoration: InputDecoration(
                          labelText: 'Remarks',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.red)),
                onPressed: () {
                  _remarksController.clear();
                  _referenceNoController.clear();
                  Navigator.of(dialogContext).pop(); // Dismiss dialog
                },
              ),
              ElevatedButton(
                child: Text('Submit', style: GoogleFonts.poppins(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: CustomColor.MainColor),
                onPressed: () async {
                  // Validation
                  if (selectedStatus == null) {
                    CustomColor.showErrorSnackBar(dialogContext, 'Please select a status.');
                    return;
                  }
                  if (selectedStatus == 'IP Approved' && _referenceNoController.text.isEmpty) {
                    CustomColor.showErrorSnackBar(dialogContext, 'Please enter a reference number.');
                    return;
                  }

                  // Get the current user to pass the ID
                  final user = await SessionManager.getSessionData();
                  if (user == null) {
                    CustomColor.showErrorSnackBar(dialogContext, 'User session not found. Please log in again.');
                    return;
                  }

                  // Call API to save feedback
                  bool success = await saveCustomerFeedback(
                    mobileNo: widget.mobileNo,
                    remarks: _remarksController.text,
                    status: selectedStatus,
                    referenceNo: _referenceNoController.text,
                    userId: user.userId, // Pass the user ID
                  );
                  if (success) {
                    AppStateManager.clearPendingFeedbackMobile();
                    CustomColor.showSuccessSnackBar(context, 'Feedback submitted successfully!');
                    _remarksController.clear();
                    _referenceNoController.clear();
                    Navigator.of(dialogContext).pop(); // Dismiss dialog

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
                  } else {
                    CustomColor.showErrorSnackBar(context, 'Failed to submit feedback.');
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.isAutoOpenedAfterCall) {
          _showFeedbackDialog(context);
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
            if (widget.isAutoOpenedAfterCall)
              IconButton(
                icon: const Icon(Icons.feedback, color: Colors.white),
                onPressed: () => _showFeedbackDialog(context),
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
              if (errorMessage.contains("No customer found with this mobile number.")) {
                return Center(
                  child: Text(
                    'No Customer found with this Mobile No',
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
                    // First Card: Name, Mobile, City, Employer
                    Card(
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
                            _buildDetailRowInCard('Mobile', widget.mobileNo),
                            const Divider(color: Colors.grey),
                            _buildDetailRowInCard('City', customer.city),
                            const Divider(color: Colors.grey),
                            _buildDetailRowInCard('Employer', customer.employer),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Second Card: Segment, Reason, Product
                    Card(
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
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Login Links:',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: CustomColor.MainColor),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<List<LoginLinkModel>>(
                      future: fetchLoginLinks(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          String errorMessage = snapshot.error.toString();
                          logAppError(errorMessage: errorMessage, errorContext: "Customer Details Screen - Login Links FutureBuilder");
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No login links available.'));
                        } else {
                          final links = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: links.map((link) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Link for ',
                                          style: GoogleFonts.poppins(fontSize: 12),
                                        ),
                                        Text(
                                          link.linkType,
                                          style: GoogleFonts.poppins(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          await _launchUrl(link.link);
                                        } catch (e) {
                                          logAppError(errorMessage: e.toString(), errorContext: "Customer Details Screen - Launch URL");
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('$e')),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: CustomColor.MainColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      ),
                                      child: Text(
                                        'Apply',
                                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
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
}