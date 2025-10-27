import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomColor {
  static Color MainColor = Color(0xff0066cc);
  static Color SecondaryColor = Color(0xff0066cc);
  static Color DrawerItems = Color(0xff33cccc);

  // Show Professional Error SnackBar
  static void showErrorSnackBar(BuildContext context, String message, {
    Duration duration = const Duration(seconds: 4),
    bool showCloseIcon = true,
    String title = "Error",
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      message,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.red.shade700,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        showCloseIcon: showCloseIcon,
        closeIconColor: Colors.white,
        elevation: 6,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }

  // Show Professional Success SnackBar
  static void showSuccessSnackBar(BuildContext context, String message, {
    Duration duration = const Duration(seconds: 3),
    bool showCloseIcon = true,
    String title = "Success",
    IconData icon = Icons.check_circle,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      message,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.green.shade600,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        showCloseIcon: showCloseIcon,
        closeIconColor: Colors.white,
        elevation: 6,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }

  // Show Smart SnackBar with auto-detection
  static void showSmartSnackBar(BuildContext context, String message, {
    bool isError = false,
    String? customTitle,
    Duration? customDuration,
    IconData? customIcon,
  }) {
    if (isError) {
      showErrorSnackBar(
        context,
        message,
        title: customTitle ?? "Error",
        duration: customDuration ?? Duration(seconds: 4),
      );
    } else {
      showSuccessSnackBar(
        context,
        message,
        title: customTitle ?? "Success",
        duration: customDuration ?? Duration(seconds: 3),
        icon: customIcon ?? Icons.check_circle,
      );
    }
  }

  // Full-Screen Loading Widget
  static Widget showFullScreenLoading({required bool isLoading}) {
    return isLoading
        ? Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              Center(
                child: SpinKitWaveSpinner(
                  waveColor: CustomColor.MainColor,
                  size: 50.0,
                  color: CustomColor.MainColor,
                ),
              ),
            ],
          )
        : SizedBox.shrink();
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