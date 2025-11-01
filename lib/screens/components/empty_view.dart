import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyView extends StatelessWidget {
  final String message;
  final VoidCallback onRefresh;

  const EmptyView({
    super.key,
    required this.message,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, color: Colors.grey, size: 60),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.poppins(fontSize: 16)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRefresh,
            child: Text('Refresh', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}
