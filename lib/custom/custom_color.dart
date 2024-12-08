import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomColor {
  static Color MainColor = Color(0xff0066cc);
  static Color SecondaryColor = Color(0xff0066cc);
  static Color DrawerItems = Color(0xff33cccc);

  // Show Error SnackBar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Show Success SnackBar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.greenAccent.shade700,
      ),
    );
  }

  // Full-Screen Loading Widget
  static Widget showFullScreenLoading({required bool isLoading}) {
    return isLoading
        ? Stack(
            children: [
              // Optional: Dim the background
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
                ),
              ),
              // Center the loading spinner
              Center(
                child: SpinKitWaveSpinner(
                  waveColor: CustomColor.MainColor,
                  size: 50.0,
                  color: CustomColor.MainColor,
                ),
              ),
            ],
          )
        : SizedBox.shrink(); // When not loading, return an empty box
  }

  // Custom Button Widget
  static Widget customButton({
    required BuildContext context,
    required String text,
    required Function() onPressed,
  }) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: MainColor),
        child: Text(
          text,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
