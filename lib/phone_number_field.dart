import 'package:flutter/material.dart';

class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function onEditingComplete;

  PhoneNumberField({
    required this.controller,
    required this.focusNode,
    required this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        prefixIcon: Icon(Icons.phone),
      ),
      keyboardType: TextInputType.phone,
      onEditingComplete: () => onEditingComplete(),
    );
  }
}
