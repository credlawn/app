import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/helpers/database_service.dart';
import 'package:credlawn/models/case_login_model.dart';
import 'package:credlawn/helpers/session_manager.dart';
import 'package:credlawn/models/user.dart';
import 'package:credlawn/network/api_case_login_helper.dart';

class MyLoginScreen extends StatefulWidget {
  const MyLoginScreen({super.key});

  @override
  State<MyLoginScreen> createState() => _MyLoginScreenState();
}

class _MyLoginScreenState extends State<MyLoginScreen> {
  late Future<List<CaseLoginModel>> _caseLoginsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _syncDirtyCaseLogins();
    _caseLoginsFuture = _fetchCaseLogins();
  }

  Future<List<CaseLoginModel>> _fetchCaseLogins() async {
    return await DatabaseService.instance.caseLoginRepository.getAllCaseLogins();
  }

  Future<void> _syncCaseLoginsFromServer() async {
    try {
      final User? currentUser = await SessionManager.getSessionData();
      if (currentUser == null) {
        CustomColor.showErrorSnackBar(context, 'User session not found. Please log in again.');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final Map<String, dynamic> serverResponse = await getUserCaseLoginsFromServer(currentUser.userId, currentUser.sid);

      if (serverResponse['message'] == null) {
        CustomColor.showErrorSnackBar(context, 'Invalid server response format');
        return;
      }

      final message = serverResponse['message'];
      if (message is! Map<String, dynamic> || message['status'] != 'success' || message['data'] == null) {
        CustomColor.showErrorSnackBar(context, 'Failed to sync data from server: ${message['message'] ?? 'Unknown error'}');
        return;
      }

      final data = message['data'];
      if (data.isNotEmpty) {
        for (var caseLoginData in data) {
          final caseLogin = CaseLoginModel(
            frappeId: caseLoginData['frappe_id'],
            syncId: caseLoginData['sync_id'],
            customerName: caseLoginData['customer_name'],
            mobileNo: caseLoginData['mobile_no'],
            loginDate: caseLoginData['login_date'],
            ipStatus: caseLoginData['ip_status'],
            arnNo: caseLoginData['arn_no'] ?? '',
            remarks: caseLoginData['remarks'] ?? '',
            user: caseLoginData['user'],
            isDirty: 0,
            syncError: null,
          );

          final existing = await DatabaseService.instance.caseLoginRepository.getAllCaseLogins();
          final exists = existing.any((cl) => cl.syncId == caseLogin.syncId);

          if (!exists) {
            await DatabaseService.instance.caseLoginRepository.insertCaseLogin(caseLogin);
          }
        }

        setState(() {
          _caseLoginsFuture = _fetchCaseLogins();
        });

        CustomColor.showSuccessSnackBar(context, 'Data synced from server successfully');
      } else {
        CustomColor.showInfoSnackBar(context, 'No case logins available on server');
      }
    } catch (e) {
      CustomColor.showErrorSnackBar(context, 'Error syncing data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _syncDirtyCaseLogins() async {
    bool dataSynced = false;
    final User? currentUser = await SessionManager.getSessionData();
    if (currentUser == null) {
      return false;
    }

    final List<CaseLoginModel> dirtyCaseLogins =
        await DatabaseService.instance.caseLoginRepository.getAllCaseLogins();

    for (final caseLogin in dirtyCaseLogins.where((cl) => cl.isDirty == 1)) {
      try {
        final Map<String, dynamic> serverResponse = await submitCaseLoginToServer(
          caseLogin.customerName,
          caseLogin.mobileNo,
          caseLogin.loginDate,
          caseLogin.ipStatus,
          caseLogin.arnNo,
          caseLogin.remarks,
          caseLogin.user!,
          currentUser.sid,
          caseLogin.syncId,
        );

        if (serverResponse['message'] != null && serverResponse['message']['status'] == 'success') {
          final String serverFrappeName = serverResponse['message']['frappe_id'];
          await DatabaseService.instance.caseLoginRepository.updateCaseLoginLocalFields(
            caseLogin.frappeId!,
            newFrappeId: serverFrappeName,
            isDirty: 0,
            syncError: null,
          );
          dataSynced = true;
        } else {
          final String errorMessage = serverResponse['message']?['message'] ?? 'Unknown server error';
          await DatabaseService.instance.caseLoginRepository.updateCaseLoginLocalFields(
            caseLogin.frappeId!,
            isDirty: 1,
            syncError: errorMessage,
          );
        }
      } catch (e) {
        await DatabaseService.instance.caseLoginRepository.updateCaseLoginLocalFields(
          caseLogin.frappeId!,
          isDirty: 1,
          syncError: e.toString(),
        );
      }
    }
    return dataSynced;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: CustomColor.MainColor,
        title: Text('My Login', style: GoogleFonts.poppins(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            onPressed: () async {
              await _syncCaseLoginsFromServer();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              final bool synced = await _syncDirtyCaseLogins();
              setState(() {
                _caseLoginsFuture = _fetchCaseLogins();
              });
              if (mounted) {
                if (synced) {
                  CustomColor.showSuccessSnackBar(context, 'Data Updated Successfully');
                } else {
                  CustomColor.showInfoSnackBar(context, 'Everything up to date.');
                }
              }
            },
            child: FutureBuilder<List<CaseLoginModel>>(
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
                              if (caseLogin.arnNo?.isNotEmpty == true)
                                Text('ARN: ${caseLogin.arnNo}', style: GoogleFonts.poppins()),
                              if (caseLogin.remarks?.isNotEmpty == true)
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
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
