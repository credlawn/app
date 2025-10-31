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
  _syncCaseLoginsFromServer();
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

      // Get all frappe_ids from API response
      final Set<String> serverFrappeIds = {};
      if (data.isNotEmpty) {
        for (var caseLoginData in data) {
          serverFrappeIds.add(caseLoginData['frappe_id']);
        }
      }

      // Get all local case logins
      final localCaseLogins = await DatabaseService.instance.caseLoginRepository.getAllCaseLogins();

      // Process API data - add new records or update existing ones
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
    modified: caseLoginData['modified'] ?? '',
  );

          // Check if this case login already exists locally using frappe_id
          final exists = localCaseLogins.any((cl) => cl.frappeId == caseLogin.frappeId);

if (!exists) {
  await DatabaseService.instance.caseLoginRepository.insertCaseLogin(caseLogin);
} else {
  final existingCaseLogin = await DatabaseService.instance.caseLoginRepository.getCaseLoginByFrappeId(caseLogin.frappeId!);
  if (existingCaseLogin != null && existingCaseLogin.modified != caseLoginData['modified']) {
    await DatabaseService.instance.caseLoginRepository.updateCaseLoginFields(
      caseLogin.frappeId!,
      newFrappeId: caseLogin.frappeId,
      isDirty: caseLogin.isDirty,
      syncError: caseLogin.syncError,
      customerName: caseLogin.customerName,
      mobileNo: caseLogin.mobileNo,
      loginDate: caseLogin.loginDate,
      ipStatus: caseLogin.ipStatus,
      arnNo: caseLogin.arnNo,
      remarks: caseLogin.remarks,
      user: caseLogin.user,
      modified: caseLoginData['modified'] ?? '',
    );
  }
}
        }
      }

      // Delete records that exist locally but not in API response
      // Only delete records that have a frappe_id (skip records without frappe_id)
      for (final localCaseLogin in localCaseLogins) {
        if (localCaseLogin.frappeId != null && !serverFrappeIds.contains(localCaseLogin.frappeId)) {
          await DatabaseService.instance.caseLoginRepository.deleteCaseLogin(localCaseLogin.frappeId!);
        }
      }

      setState(() {
        _caseLoginsFuture = _fetchCaseLogins();
      });

    } catch (e) {
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
    customerName: caseLogin.customerName,
    mobileNo: caseLogin.mobileNo,
    loginDate: caseLogin.loginDate,
    ipStatus: caseLogin.ipStatus,
    arnNo: caseLogin.arnNo,
    remarks: caseLogin.remarks,
    user: caseLogin.user!,
    sid: currentUser.sid,
    syncId: caseLogin.syncId,
    modified: caseLogin.modified,
  );

  print('Server Response: $serverResponse');

  if (serverResponse['message'] != null && serverResponse['message']['status'] == 'success') {
    final String serverFrappeName = serverResponse['message']['frappe_id'];
    final String serverModified = serverResponse['message']['modified'];
    await DatabaseService.instance.caseLoginRepository.updateCaseLoginLocalFields(
      caseLogin.frappeId!,
      newFrappeId: serverFrappeName,
      isDirty: 0,
      syncError: null,
      modified: serverModified,
    );
    dataSynced = true;
  } else {
    final String errorMessage = serverResponse['message']?['message'] ?? 'Unknown server error';
    await DatabaseService.instance.caseLoginRepository.updateCaseLoginLocalFields(
      caseLogin.frappeId!,
      isDirty: 1,
      syncError: errorMessage,
      modified: caseLogin.modified,
    );
  }
      } catch (e) {
  await DatabaseService.instance.caseLoginRepository.updateCaseLoginLocalFields(
    caseLogin.frappeId!,
    isDirty: 1,
    syncError: e.toString(),
    modified: caseLogin.modified,
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
actions: [],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
onRefresh: () async {
  final bool synced = await _syncDirtyCaseLogins();
  await _syncCaseLoginsFromServer();
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
          Text('ID: ${caseLogin.id}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          Text('Frappe ID: ${caseLogin.frappeId}', style: GoogleFonts.poppins()),
          Text('Sync ID: ${caseLogin.syncId}', style: GoogleFonts.poppins()),
          Text('Customer Name: ${caseLogin.customerName}', style: GoogleFonts.poppins()),
          Text('Mobile No: ${caseLogin.mobileNo}', style: GoogleFonts.poppins()),
          Text('Login Date: ${caseLogin.loginDate}', style: GoogleFonts.poppins()),
          Text('IP Status: ${caseLogin.ipStatus}', style: GoogleFonts.poppins()),
          Text('ARN No: ${caseLogin.arnNo}', style: GoogleFonts.poppins()),
          Text('Remarks: ${caseLogin.remarks}', style: GoogleFonts.poppins()),
          Text('User: ${caseLogin.user}', style: GoogleFonts.poppins()),
          Text('Is Dirty: ${caseLogin.isDirty}', style: GoogleFonts.poppins()),
          Text('Sync Error: ${caseLogin.syncError}', style: GoogleFonts.poppins()),
          Text('Modified: ${caseLogin.modified}', style: GoogleFonts.poppins()),
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
