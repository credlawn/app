import 'package:flutter/material.dart';
import '../models/card_login_list_model.dart';
import '../models/user.dart';
import '../network/api_card_list_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:credlawn/custom/custom_color.dart';

class MonthLoginListScreen extends StatefulWidget {
  final User user;

  const MonthLoginListScreen({super.key, required this.user});

  @override
  _MonthLoginListScreenState createState() => _MonthLoginListScreenState();
}

class _MonthLoginListScreenState extends State<MonthLoginListScreen> {
  late Future<List<CardLoginListModel>> _monthLoginList;

  @override
  void initState() {
    super.initState();
    _monthLoginList = fetchMonthLoginData(widget.user.userId, widget.user.sid);
  }

  Future<void> _refreshMonthLoginList() async {
    setState(() {
      _monthLoginList = fetchMonthLoginData(widget.user.userId, widget.user.sid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Current Month Login', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
        backgroundColor: CustomColor.MainColor,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshMonthLoginList,
              child: FutureBuilder<List<CardLoginListModel>>(
                future: _monthLoginList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SpinKitWaveSpinner(
                          color: Colors.greenAccent.shade700,
                          waveColor: Colors.greenAccent.shade700),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('${snapshot.error}', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.red)));
                  } else {
                    final monthLoginList = snapshot.data!;
                    return ListView.builder(
                      itemCount: monthLoginList.length,
                      itemBuilder: (context, index) {
                        final card = monthLoginList[index];
                        Color ipStatusColor = card.ipStatus == "IP Approved" ? Colors.greenAccent.shade700 : (card.ipStatus == "IP Rejected" ? Colors.red : (card.ipStatus == "Incomplete Journey" ? Colors.red : Colors.black));
                        Color kycStatusColor = card.kycStatus == "VKYC Success" ? Colors.lightGreen.shade500 : (card.kycStatus == "VKYC Pending" ? Colors.orange.shade700 : (card.kycStatus == "BKYC" ? Colors.deepPurpleAccent.shade700 : Colors.black));
                        Color rejectionReasonColor = card.rejectionReason == "Recently Applied" ? Colors.lightGreen.shade400 : (card.rejectionReason == "No Offer" ? Colors.orange.shade700 : Colors.black);
                        Color incompleteReasonColor= card.incompleteReason == "Docs Not Available" ? Colors.lightGreen.shade500 : (card.rejectionReason == "Customer Denied" ? Colors.orange.shade700 : Colors.black);
                        
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                spreadRadius: 0.5,
                                blurRadius: 0.5,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[100],
                              child: Icon(Icons.person, color: CustomColor.MainColor),
                            ),
                            title: Text(
                              card.customerName,
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: CustomColor.MainColor),
                            ),
                            subtitle: Text(
                              card.punchingDate,
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400),
                            ),

                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  card.ipStatus,
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: ipStatusColor),
                                ),
                                SizedBox(height: 5),
                                if (card.ipStatus == "IP Approved") 
                                  Text(
                                    card.kycStatus,
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: kycStatusColor),
                                  )
                                else if (card.ipStatus == "IP Rejected")
                                  Text(
                                    card.rejectionReason,
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: rejectionReasonColor),
                                  )
                                else if (card.ipStatus == "Incomplete Journey")
                                  Text(
                                    card.incompleteReason,
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: incompleteReasonColor),
                                  ),
                              ],
                            ),
                            onTap: () {
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}