import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';

class ErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(errorMessage, style: GoogleFonts.poppins(fontSize: 16)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            child: Text('Retry', style: GoogleFonts.poppins()),
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomColor.MainColor,
            ),
          ),
        ],
      ),
    );
  }
}
