import 'package:flutter/material.dart';


class Helper {
  static showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(
          message,
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  static showLoaderDialog(BuildContext context, {String? message}) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(), // Loading indicator
          if (message != null) ...[ // Only show message if provided
            Container(
              margin: const EdgeInsets.only(left: 15.0),
              child: Text(message),
            ),
          ]
        ],
      ),
    );
    showDialog(
      barrierDismissible: false, // Prevent dialog from being dismissed
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
