import 'package:flutter/material.dart';

class CustomBackground extends StatelessWidget {
  final Widget child;

  CustomBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    // Ekran boyutlarını alıyoruz
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // Gradient renkleri
    final gradientColors = [
      Colors.blue,
      Colors.red,
    ];

    // Farklı ekran boyutları için responsive gradient boyutlandırması (yüksek ekranlar için daha geniş geçişler)
    double gradientStart = screenHeight * 0.2;
    double gradientEnd = screenHeight * 0.8;

    return Container(
      width: screenWidth,
      height: screenHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
          stops: [gradientStart / screenHeight, gradientEnd / screenHeight],
        ),
      ),
      child: child,
    );
  }
}
