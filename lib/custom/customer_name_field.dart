import 'package:flutter/material.dart';
import 'custom_color.dart'; 
import 'custom_text_field.dart'; 

class CustomerNameField extends StatefulWidget {
  final TextEditingController controller;
  final bool enable;

  const CustomerNameField({Key? key, required this.controller, this.enable = true}) : super(key: key);

  @override
  _CustomerNameFieldState createState() => _CustomerNameFieldState();
}

class _CustomerNameFieldState extends State<CustomerNameField> {
  Color _borderColor = CustomColor.MainColor;  // Default border color
  bool _isValidName = true;  // Default to valid when empty or initially valid

  // Validate if the name has at least 5 characters and contains only alphabetic characters and spaces
  bool _isValidNameInput(String input) {
    final nameRegex = RegExp(r'^[A-Za-z\s]+$');  // Only alphabetic characters and spaces allowed
    return input.length >= 5 && nameRegex.hasMatch(input);
  }

  // Convert text to title case (first letter uppercase, the rest lowercase)
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((str) {
      return str[0].toUpperCase() + str.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isEmpty) {
      _borderColor = CustomColor.MainColor;
      _isValidName = true;
    } else {
      _isValidName = _isValidNameInput(widget.controller.text);
      _borderColor = _isValidName ? CustomColor.MainColor : Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: widget.controller,
          label: 'Customer Name',
          hint: '',
          prefixIcon: Icon(
            Icons.person, // Icon for customer name
            color: CustomColor.MainColor,
          ),
          enable: widget.enable,
          keyboardType: TextInputType.text,
          borderColor: _borderColor,
          onChanged: (text) {
            setState(() {
              // Convert the text to title case (only alphabetic characters)
              String updatedText = _toTitleCase(text);

              // Update the text in the controller
              widget.controller.text = updatedText;

              // Reposition the cursor to the end of the text
              widget.controller.selection = TextSelection.fromPosition(
                TextPosition(offset: widget.controller.text.length),
              );

              // Validate the name (at least 5 characters, alphabetic only)
              _isValidName = _isValidNameInput(updatedText);
              _borderColor = _isValidName || widget.controller.text.isEmpty
                  ? CustomColor.MainColor
                  : Colors.red;
            });
          },
        ),
        // Display error message if the name is invalid
        if (!_isValidName && widget.controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please enter customer full name',
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
