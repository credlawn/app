import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/helpers/database_service.dart';
import 'package:credlawn/models/case_login_model.dart';

class MyLoginScreen extends StatefulWidget {
  const MyLoginScreen({super.key});

  @override
  State<MyLoginScreen> createState() => _MyLoginScreenState();
}

class _MyLoginScreenState extends State<MyLoginScreen> {
  late Future<List<CaseLoginModel>> _caseLoginsFuture;

  @override
  void initState() {
    super.initState();
    _caseLoginsFuture = _fetchCaseLogins();
  }

  Future<List<CaseLoginModel>> _fetchCaseLogins() async {
    return await DatabaseService.instance.caseLoginRepository.getAllCaseLogins();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: CustomColor.MainColor,
        title: Text('My Login', style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: FutureBuilder<List<CaseLoginModel>>(
        future: _caseLoginsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: CustomColor.MainColor));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No case logins available.'));
          } else {
            final caseLogins = snapshot.data!;
            return ListView.builder(
              itemCount: caseLogins.length,
              itemBuilder: (context, index) {
                final caseLogin = caseLogins[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer: ${caseLogin.customerName}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        Text('Mobile: ${caseLogin.mobileNo}', style: GoogleFonts.poppins()),
                        Text('Status: ${caseLogin.ipStatus}', style: GoogleFonts.poppins()),
                        if (caseLogin.arnNo.isNotEmpty)
                          Text('ARN: ${caseLogin.arnNo}', style: GoogleFonts.poppins()),
                        if (caseLogin.remarks.isNotEmpty)
                          Text('Remarks: ${caseLogin.remarks}', style: GoogleFonts.poppins()),
                        Text('Login Date: ${caseLogin.loginDate}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                        Text('User: ${caseLogin.user}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}