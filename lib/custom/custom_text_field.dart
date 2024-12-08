import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required import for LengthLimitingTextInputFormatter
import 'package:google_fonts/google_fonts.dart';
import 'custom_color.dart'; // Assuming this is for styling

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    required this.label,
    this.prefixIcon,
    this.hint,
    super.key,
    this.controller,
    this.keyboardType,
    this.maxLength,
    this.enable = true,
    this.onChanged, // Add onChanged parameter
    this.borderColor = Colors.blue, // Use a default color (Colors.blue)
  });

  final String label;
  final String? hint;
  final Icon? prefixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool enable;
  final ValueChanged<String>? onChanged; // Define the onChanged callback
  final Color borderColor; // Define borderColor as a parameter

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode(); // Focus node to manage the focus state

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {}); // Rebuild when focus changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(100),
            blurRadius: 1.5,
            spreadRadius: 1.5,
            offset: Offset(0.3, 0.3),
          ),
        ],
      ),
      child: TextField(
        focusNode: _focusNode,
        inputFormatters: [
          LengthLimitingTextInputFormatter(widget.maxLength), // Limit input length
        ],
        keyboardType: widget.keyboardType,
        controller: widget.controller,
        textInputAction: TextInputAction.next,
        onChanged: widget.onChanged, // Use the onChanged callback passed in
        decoration: InputDecoration(
          enabled: widget.enable,
          prefixIcon: widget.prefixIcon,
          prefixIconColor: widget.borderColor, // Custom color for prefix icon
          hintText: widget.hint,
          label: Text(
            widget.label,
            style: GoogleFonts.poppins(
              color: widget.borderColor, // Custom color for label text
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: widget.borderColor), // Use the dynamic borderColor here
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue), // Blue border when focused
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Clean up the focus node when the widget is disposed
    super.dispose();
  }
}