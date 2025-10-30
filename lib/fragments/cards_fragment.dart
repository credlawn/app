import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user.dart';

class CardsFragment extends StatefulWidget {
  final User user;
  const CardsFragment({super.key, required this.user});

  @override
  State<CardsFragment> createState() => _CardsFragmentState();
}

class _CardsFragmentState extends State<CardsFragment> {
  final List<Map<String, dynamic>> mockCardData = [
    {
      'icon': Icons.credit_card_rounded,
      'title': 'Total VKYC Pending',
      'color': Colors.purple,
    },
    {
      'icon': Icons.credit_card_outlined,
      'title': 'Vkyc Expire Today',
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AlignedGridView.count(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        itemCount: mockCardData.length,
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Navigate based on the title of the card
              // No action for removed screens
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(80),
                    blurRadius: 1.5,
                    spreadRadius: 1.5,
                  )
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    mockCardData[index]['icon'],
                    size: 30.0,
                    color: mockCardData[index]['color'],
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    mockCardData[index]['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
