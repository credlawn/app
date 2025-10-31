import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
    this.onChanged,
    this.borderColor = Colors.blue,
    this.focusNode,
  });

final String label;
  final String? hint;
  final Icon? prefixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool enable;
  final ValueChanged<String>? onChanged;
  final Color borderColor;
  final FocusNode? focusNode;

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
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
          LengthLimitingTextInputFormatter(widget.maxLength),
        ],
        keyboardType: widget.keyboardType,
        controller: widget.controller,
        textInputAction: TextInputAction.next,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          enabled: widget.enable,
          prefixIcon: widget.prefixIcon,
          prefixIconColor: widget.borderColor,
          hintText: widget.hint,
          label: Text(
            widget.label,
            style: GoogleFonts.poppins(
              color: widget.borderColor,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: widget.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
