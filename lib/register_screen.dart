import 'package:flutter/material.dart';
import 'register_buttons.dart';
import 'register_icons.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // Logo boyutunu ekran genişliğine göre dinamik hale getirelim
    double logoSize = screenWidth * 0.12; // Ekranın %12'si kadar logo boyutu

    return Scaffold(
      body: Stack(
        children: [
          // Arka Plan
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue, Colors.red], // Arka plan renkleri
              ),
            ),
          ),
          // Kitap Logosunu Sol Üst Köşeye Eklemek
          RegisterIcons(logoSize: logoSize),
          // Form Alanları ve Butonlar
          RegisterButtons(screenWidth: screenWidth, screenHeight: screenHeight),
        ],
      ),
    );
  }
}
