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
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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

  Future<void> _pickImage(ImageSource source, Function(String) onTextRecognized) async {
    print('[_pickImage] Picking image from $source');
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      print('[_pickImage] Image picked: ${pickedFile.path}');
      _performOcr(pickedFile.path, onTextRecognized);
    } else {
      print('[_pickImage] No image picked.');
    }
  }

void _performOcr(String imagePath, Function(String) onTextRecognized) async {
  print('[_performOcr] Starting OCR for image: $imagePath');

  final textRecognizer = TextRecognizer();
  final recognizedText = await textRecognizer.processImage(InputImage.fromFilePath(imagePath));
  await textRecognizer.close();

  String foundRefNumber = '';
  
  bool _isValidArn(String text) {
    if (text.length != 16) return false;
    
    // D25J format (D25J + 8 digits + 4 alphanumeric)
    if (text.startsWith('D25J')) {
      String middle = text.substring(4, 12);
      String last = text.substring(12);
      bool middleIsDigits = RegExp(r'^[0-9]+$').hasMatch(middle);
      bool lastIsAlphaNum = RegExp(r'^[A-Z0-9]+$').hasMatch(last);
      return middleIsDigits && lastIsAlphaNum;
    }
    
    // 25XXX format (25 + 3 alphanumeric + 11 alphanumeric)
    if (text.startsWith('25')) {
      return RegExp(r'^25[A-Z0-9]{14}$').hasMatch(text);
    }
    
    return false;
  }

  String _cleanArn(String text) {
    text = text.toUpperCase();
    
    // Single character replacements
    text = text.replaceAll(']', 'J');
    text = text.replaceAll('[', 'I');
    text = text.replaceAll('|', 'I');
    text = text.replaceAll('(', 'C');
    text = text.replaceAll(')', '');
    
    // Remove all non-alphanumeric characters
    text = text.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    
    if (text.length != 16) return text;
    
    // For D25J format, ensure middle 8 characters are digits
    if (text.startsWith('D25J')) {
      String middle = text.substring(4, 12);
      String last = text.substring(12);
      
      // Convert common OCR errors in digits part
      String fixedMiddle = middle
          .replaceAll('O', '0')
          .replaceAll('S', '5')
          .replaceAll('I', '1')
          .replaceAll('Z', '2')
          .replaceAll('B', '8');
      
      // Only apply if it makes it more numeric
      int originalDigits = middle.replaceAll(RegExp(r'[^0-9]'), '').length;
      int fixedDigits = fixedMiddle.replaceAll(RegExp(r'[^0-9]'), '').length;
      
      if (fixedDigits > originalDigits) {
        text = 'D25J' + fixedMiddle + last;
      }
    }
    
    return text;
  }

  final RegExp arnRegExp = RegExp(r'[A-Z0-9\]\[]{16}');

  int refIndex = recognizedText.blocks.indexWhere((block) {
    final t = block.text.toLowerCase();
    return t.contains('arn') || t.contains('reference number');
  });

  void searchFrom(int startIndex) {
    for (int i = startIndex; i < recognizedText.blocks.length; i++) {
      final rawText = recognizedText.blocks[i].text;
      final cleaned = _cleanArn(rawText);
      
      print('[_performOcr] Block $i: $rawText');
      print('[_performOcr] Cleaned: $cleaned');
      
      if (cleaned.length == 16 && _isValidArn(cleaned)) {
        foundRefNumber = cleaned;
        print('[_performOcr] Found valid ARN: $foundRefNumber');
        break;
      }
      
      // Also check for pattern in original text
      final match = arnRegExp.firstMatch(rawText);
      if (match != null) {
        final candidate = _cleanArn(match.group(0)!);
        if (candidate.length == 16 && _isValidArn(candidate)) {
          foundRefNumber = candidate;
          print('[_performOcr] Found ARN via regex: $foundRefNumber');
          break;
        }
      }
    }
  }

  if (refIndex != -1) {
    print('[_performOcr] Found keyword near block $refIndex — searching next...');
    searchFrom(refIndex + 1);
  }

  if (foundRefNumber.isEmpty) {
    print('[_performOcr] Fallback: searching all blocks...');
    searchFrom(0);
  }

  if (foundRefNumber.isNotEmpty) {
    print('[_performOcr] Final ARN: $foundRefNumber');
    onTextRecognized(foundRefNumber);
  } else {
    print('[_performOcr] No valid ARN found.');
    
    // Last resort: combine all text and search
    final allText = recognizedText.blocks.map((b) => b.text).join(' ');
    final matches = arnRegExp.allMatches(allText);
    
    for (final match in matches) {
      final candidate = _cleanArn(match.group(0)!);
      if (candidate.length == 16 && _isValidArn(candidate)) {
        foundRefNumber = candidate;
        print('[_performOcr] Found in combined text: $foundRefNumber');
        onTextRecognized(foundRefNumber);
        return;
      }
    }
  }
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
      barrierDismissible: false,
      builder: (BuildContext dialog_context) {
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
                          suffixIcon: IconButton(
                            icon: Icon(Icons.camera_alt),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Wrap(
                                    children: <Widget>[
                                      ListTile(
                                        leading: Icon(Icons.camera_alt),
                                        title: Text('Camera'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _pickImage(ImageSource.camera, (text) {
                                            setState(() {
                                              _referenceNoController.text = text;
                                            });
                                          });
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.photo_library),
                                        title: Text('Gallery'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _pickImage(ImageSource.gallery, (text) {
                                            setState(() {
                                              _referenceNoController.text = text;
                                            });
                                          });
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
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
                  Navigator.of(dialog_context).pop();
                },
              ),
              ElevatedButton(
                child: Text('Submit', style: GoogleFonts.poppins(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: CustomColor.MainColor),
                onPressed: () async {
                  if (selectedStatus == null) {
                    CustomColor.showErrorSnackBar(dialog_context, 'Please select a status.');
                    return;
                  }
                  if (selectedStatus == 'IP Approved' && _referenceNoController.text.isEmpty) {
                    CustomColor.showErrorSnackBar(dialog_context, 'Please enter a reference number.');
                    return;
                  }

                  final user = await SessionManager.getSessionData();
                  if (user == null) {
                    CustomColor.showErrorSnackBar(dialog_context, 'User session not found. Please log in again.');
                    return;
                  }

                  bool success = await saveCustomerFeedback(
                    mobileNo: widget.mobileNo,
                    remarks: _remarksController.text,
                    status: selectedStatus,
                    referenceNo: _referenceNoController.text,
                    userId: user.userId,
                  );
                  if (success) {
                    AppStateManager.clearPendingFeedbackMobile();
                    CustomColor.showSuccessSnackBar(context, 'Feedback submitted successfully!');
                    _remarksController.clear();
                    _referenceNoController.clear();
                    Navigator.of(dialog_context).pop();

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