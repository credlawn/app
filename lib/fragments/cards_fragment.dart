import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/sample_screen.dart';
import '../screens/new_card_login_screen.dart';

class CardsFragment extends StatefulWidget {
  const CardsFragment({super.key});

  @override
  State<CardsFragment> createState() => _CardsFragmentState();
}

class _CardsFragmentState extends State<CardsFragment> {
  final List<Map<String, dynamic>> mockCardData = [
    {
      'icon': Icons.credit_card,
      'title': 'Card 1',
      'count': '3',
      'color': Colors.orange,
    },
    {
      'icon': Icons.credit_card_rounded,
      'title': 'Card 2',
      'count': '7',
      'color': Colors.purple,
    },
    {
      'icon': Icons.credit_card_outlined,
      'title': 'Card 3',
      'count': '2',
      'color': Colors.green,
    },
    {
      'icon': Icons.login,
      'title': 'New Login',
      'count': '',
      'color': Colors.blue,
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
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (mockCardData[index]['title'] == 'New Login') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewCardLoginScreen(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SampleScreen(),
                  ),
                );
              }
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        mockCardData[index]['title'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        textAlign: TextAlign.center,
                        mockCardData[index]['count'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: mockCardData[index]['color'],
                        ),
                      ),
                    ],
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
