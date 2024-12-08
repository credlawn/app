import 'package:flutter/material.dart';
import '../models/card_login_list_model.dart';
import '../models/user.dart';
import '../network/api_card_list_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:credlawn/custom/custom_color.dart';

class CardLoginListScreen extends StatefulWidget {
  final User user;

  CardLoginListScreen({super.key, required this.user});

  @override
  _CardLoginListScreenState createState() => _CardLoginListScreenState();
}

class _CardLoginListScreenState extends State<CardLoginListScreen> {
  late Future<List<CardLoginListModel>> _cardLoginList;

  @override
  void initState() {
    super.initState();
    _cardLoginList = fetchCardLoginData(widget.user.userId, widget.user.sid);
  }

  Future<void> _refreshCardLoginList() async {
    setState(() {
      _cardLoginList = fetchCardLoginData(widget.user.userId, widget.user.sid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Card Login List', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
        backgroundColor: CustomColor.MainColor,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshCardLoginList,
              child: FutureBuilder<List<CardLoginListModel>>(
                future: _cardLoginList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SpinKitWaveSpinner(
                          color: Colors.greenAccent.shade700,
                          waveColor: Colors.greenAccent.shade700),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data available'));
                  } else {
                    final cardLoginList = snapshot.data!;
                    return ListView.builder(
                      itemCount: cardLoginList.length,
                      itemBuilder: (context, index) {
                        final card = cardLoginList[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
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
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            leading: CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(
                              card.customerName,
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
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
                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  card.kycStatus,
                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.amber),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  card.incompleteReason,
                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.amber),
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
