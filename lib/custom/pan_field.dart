import 'package:flutter/material.dart';
import 'custom_color.dart'; 
import 'custom_text_field.dart'; 

class PanCardField extends StatefulWidget {
  final TextEditingController controller;
  final bool enable;

  const PanCardField({Key? key, required this.controller, this.enable = true}) : super(key: key);

  @override
  _PanCardFieldState createState() => _PanCardFieldState();
}

class _PanCardFieldState extends State<PanCardField> {
  Color _borderColor = CustomColor.MainColor;  // Default color
  bool _isValidPan = true; // Default to valid when empty or initially valid

  bool _isValidPanNumber(String input) {
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    return panRegex.hasMatch(input);
  }

  @override
  void initState() {
    super.initState();
    // Default state when the field is empty
    if (widget.controller.text.isEmpty) {
      _borderColor = CustomColor.MainColor;
      _isValidPan = true;
    } else {
      _isValidPan = _isValidPanNumber(widget.controller.text);
      _borderColor = _isValidPan ? CustomColor.MainColor : Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: widget.controller,
          label: 'PAN No',
          hint: '',
          prefixIcon: Icon(
            Icons.credit_card,
            color: CustomColor.MainColor,
          ),
          enable: widget.enable,
          keyboardType: TextInputType.text,
          maxLength: 10,
          borderColor: _borderColor,
          onChanged: (text) {
            setState(() {
              String updatedText = text.toUpperCase();
              if (updatedText.length > 10) {
                updatedText = updatedText.substring(0, 10);
              }

              StringBuffer validText = StringBuffer();

              // Validate the input to match PAN format
              for (int i = 0; i < updatedText.length; i++) {
                if (i < 5) {
                  if (RegExp(r'^[A-Z]$').hasMatch(updatedText[i])) {
                    validText.write(updatedText[i]);
                  }
                } else if (i >= 5 && i < 9) {
                  if (RegExp(r'^[0-9]$').hasMatch(updatedText[i])) {
                    validText.write(updatedText[i]);
                  }
                } else {
                  if (RegExp(r'^[A-Z]$').hasMatch(updatedText[i])) {
                    validText.write(updatedText[i]);
                  }
                }
              }

              widget.controller.text = validText.toString();
              widget.controller.selection = TextSelection.fromPosition(
                TextPosition(offset: widget.controller.text.length),
              );

              // Check if the PAN number is valid
              _isValidPan = _isValidPanNumber(widget.controller.text);
              _borderColor = _isValidPan || widget.controller.text.isEmpty
                  ? CustomColor.MainColor
                  : Colors.red;
            });
          },
        ),
        // Display error message if invalid
        if (!_isValidPan && widget.controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please enter a valid PAN number',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}
