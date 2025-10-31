import 'package:flutter/material.dart';
import 'custom_color.dart';
import 'custom_text_field.dart';

class CustomerNameField extends StatefulWidget {
  final TextEditingController controller;
  final bool enable;
  final FocusNode? focusNode;

  const CustomerNameField({super.key, required this.controller, this.enable = true, this.focusNode});

  @override
  _CustomerNameFieldState createState() => _CustomerNameFieldState();
}

class _CustomerNameFieldState extends State<CustomerNameField> {
  Color _borderColor = CustomColor.MainColor;
  bool _isValidName = true;

  bool _isValidNameInput(String input) {
    final nameRegex = RegExp(r'^[A-Za-z\s]+$');
    return input.length >= 5 && nameRegex.hasMatch(input);
  }

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
            Icons.person,
            color: CustomColor.MainColor,
          ),
          enable: widget.enable,
          keyboardType: TextInputType.text,
          borderColor: _borderColor,
          onChanged: (text) {
            setState(() {
              String updatedText = _toTitleCase(text);

              widget.controller.text = updatedText;

              widget.controller.selection = TextSelection.fromPosition(
                TextPosition(offset: widget.controller.text.length),
              );

              _isValidName = _isValidNameInput(updatedText);
              _borderColor = _isValidName || widget.controller.text.isEmpty
                  ? CustomColor.MainColor
                  : Colors.red;
            });
          },
          focusNode: widget.focusNode,
        ),
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
