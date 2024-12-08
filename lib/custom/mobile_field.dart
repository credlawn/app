import 'package:flutter/material.dart';
import 'package:credlawn/custom/custom_color.dart'; 
import 'custom_text_field.dart'; 

class MobileField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String? hint;
  final bool enable;

  const MobileField({
    required this.controller,
    required this.label,
    this.focusNode,
    this.hint,
    this.enable = true,
    super.key,
  });

  @override
  _MobileFieldState createState() => _MobileFieldState();
}

class _MobileFieldState extends State<MobileField> {

  bool _isMobileNoValid = true;
  Color _mobileNoBorderColor = CustomColor.MainColor; // Default color

  bool _isValidMobileNumber(String mobileNo) {
    // Check if the mobile number is exactly 10 digits
    return mobileNo.length == 10 && RegExp(r'^[0-9]{10}$').hasMatch(mobileNo);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: widget.controller,
          label: widget.label,
          hint: widget.hint ?? '',
          prefixIcon: Icon(
            Icons.phone,
            color: CustomColor.MainColor,
          ),
          enable: widget.enable,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          onChanged: (text) {
            setState(() {
              if (text.length > 10) {
                widget.controller.text = text.substring(0, 10);
                widget.controller.selection = TextSelection.fromPosition(TextPosition(offset: 10));
              }

              // Check validity of the entered mobile number
              _isMobileNoValid = _isValidMobileNumber(text);
              _mobileNoBorderColor = _isMobileNoValid || text.isEmpty ? CustomColor.MainColor : Colors.red;
            });
          },
          borderColor: _mobileNoBorderColor, // Apply border color based on validation
        ),
        if (!_isMobileNoValid && widget.controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please enter 10 digit mobile number',
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
