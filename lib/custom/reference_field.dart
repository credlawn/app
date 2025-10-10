import 'package:flutter/material.dart';
import 'custom_color.dart'; 
import 'custom_text_field.dart'; 

class ReferenceNoField extends StatefulWidget {
  final TextEditingController controller;
  final bool enable;

  const ReferenceNoField({super.key, required this.controller, this.enable = true});

  @override
  _ReferenceNoFieldState createState() => _ReferenceNoFieldState();
}

class _ReferenceNoFieldState extends State<ReferenceNoField> {
  Color _borderColor = CustomColor.MainColor; 
  bool _isValidReferenceNo = true;

  bool _isValidReferenceNoFormat(String input) {
    final referenceNoRegex = RegExp(r'^[A-Z0-9]{16}$');
    return referenceNoRegex.hasMatch(input);
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isEmpty) {
      _borderColor = CustomColor.MainColor;
      _isValidReferenceNo = true;
    } else {
      _isValidReferenceNo = _isValidReferenceNoFormat(widget.controller.text);
      _borderColor = _isValidReferenceNo ? CustomColor.MainColor : Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: widget.controller,
          label: 'Reference No',
          hint: '',
          prefixIcon: Icon(
            Icons.receipt, 
            color: CustomColor.MainColor,
          ),
          enable: widget.enable,
          keyboardType: TextInputType.text,
          maxLength: 16, 
          borderColor: _borderColor,
          onChanged: (text) {
            setState(() {
              String updatedText = text.toUpperCase();

              StringBuffer validText = StringBuffer();

              for (int i = 0; i < updatedText.length; i++) {
                if (RegExp(r'^[A-Z0-9]$').hasMatch(updatedText[i])) {
                  validText.write(updatedText[i]);
                }
              }

              String finalText = validText.toString();
              if (finalText.length > 16) {
                finalText = finalText.substring(0, 16);
              }

              widget.controller.text = finalText;
              widget.controller.selection = TextSelection.fromPosition(
                TextPosition(offset: finalText.length),
              );

              _isValidReferenceNo = _isValidReferenceNoFormat(finalText);
              _borderColor = _isValidReferenceNo || finalText.isEmpty
                  ? CustomColor.MainColor
                  : Colors.red;
            });
          },
        ),
        if (!_isValidReferenceNo && widget.controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please enter a valid Reference number',
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
