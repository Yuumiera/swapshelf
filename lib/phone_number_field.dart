import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneNumberField extends StatelessWidget {
  final FocusNode focusNode;
  final VoidCallback onEditingComplete;

  PhoneNumberField({required this.focusNode, required this.onEditingComplete});

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _PhoneNumberFormatter(),
      ],
      style: TextStyle(color: Colors.white), // Beyaz yazı rengi
      decoration: InputDecoration(
        labelText: 'Phone Number',
        labelStyle: TextStyle(color: Colors.white),
        prefixIcon: Icon(Icons.phone, color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: Colors.white, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: Colors.white, width: 2.0),
        ),
      ),
      onEditingComplete: onEditingComplete,
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;

    // Eğer giriş tamamen boşsa direkt döndür
    if (text.isEmpty) {
      return newValue;
    }

    // Sadece 11 hanelik girişe izin ver (fazlasını engelle)
    String digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length > 11) {
      digitsOnly = digitsOnly.substring(0, 11);
    }

    // Telefon numarasını formatla
    String formatted = '';
    if (digitsOnly.length > 0) {
      formatted = '0';
    }
    if (digitsOnly.length > 1) {
      formatted += '(${digitsOnly.substring(1, digitsOnly.length.clamp(1, 4))}';
    }
    if (digitsOnly.length > 4) {
      formatted +=
          ') ${digitsOnly.substring(4, digitsOnly.length.clamp(4, 7))}';
    }
    if (digitsOnly.length > 7) {
      formatted += '-${digitsOnly.substring(7)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
