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

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'ip approved':
        return Colors.green;
      case 'already carded':
        return Colors.orange;
      case 'ip decline':
      case 'customer denied':
        return Colors.red;
      case 'docs not available':
      case 'recently applied':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: CustomColor.MainColor,
        title: Text('My Login', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700])),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No case logins available.', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Text('Pull down to refresh', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500])),
                      ],
                    ),
                  );
                } else {
                  final caseLogins = snapshot.data!;

                  // Sort by login date descending
                  caseLogins.sort((a, b) {
                    final dateA = a.loginDate ?? '';
                    final dateB = b.loginDate ?? '';
                    return dateB.compareTo(dateA);
                  });

                  // Group by date
                  final Map<String, List<CaseLoginModel>> groupedLogins = {};
                  for (final login in caseLogins) {
                    final date = login.loginDate?.split(' ')?.first ?? 'Unknown Date';
                    if (!groupedLogins.containsKey(date)) {
                      groupedLogins[date] = [];
                    }
                    groupedLogins[date]!.add(login);
                  }

                  // Sort dates descending
                  final sortedDates = groupedLogins.keys.toList()..sort((a, b) => b.compareTo(a));

                  return ListView.builder(
                    itemCount: sortedDates.length,
                    itemBuilder: (context, dateIndex) {
                      final date = sortedDates[dateIndex];
                      final dayLogins = groupedLogins[date]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: CustomColor.MainColor.withOpacity(0.1),
                              border: Border(
                                bottom: BorderSide(color: CustomColor.MainColor.withOpacity(0.2), width: 1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 20, color: CustomColor.MainColor),
                                const SizedBox(width: 8),
                                Text(
                                  date,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: CustomColor.MainColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Login Cards for this date
                          ...dayLogins.map((caseLogin) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                              ),
                              child: ExpansionTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                trailing: Icon(
                                  Icons.expand_more,
                                  color: CustomColor.MainColor,
                                ),
                                title: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: CustomColor.MainColor.withOpacity(0.1),
                                      child: Text(
                                        (caseLogin.customerName ?? 'N')[0].toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: CustomColor.MainColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            caseLogin.customerName ?? 'N/A',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                                              const SizedBox(width: 4),
                                              Text(
                                                caseLogin.mobileNo ?? 'N/A',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(caseLogin.ipStatus),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        caseLogin.ipStatus ?? 'N/A',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                children: [
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                    child: Column(
                                      children: [
                                        const Divider(height: 24),
                                        if (caseLogin.arnNo?.isNotEmpty ?? false) ...[
                                          _buildDetailRow(
                                            icon: Icons.badge,
                                            iconColor: Colors.purple[600]!,
                                            title: 'ARN Number',
                                            value: caseLogin.arnNo!,
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                        if (caseLogin.remarks?.isNotEmpty ?? false) ...[
                                          _buildDetailRow(
                                            icon: Icons.notes,
                                            iconColor: Colors.teal[600]!,
                                            title: 'Remarks',
                                            value: caseLogin.remarks!,
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Login Date: ${caseLogin.loginDate?.split(' ')?.first ?? 'N/A'}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
