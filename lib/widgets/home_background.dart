import 'package:flutter/material.dart';

class HomeBackground extends StatelessWidget {
  final Widget child;

  HomeBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Container(
      width: screenWidth,
      height: screenHeight,
      decoration: BoxDecoration(
        color: Colors.white, // Solid white background
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(
                30.0)), // Rounded top corners for smoother edges
        child: child,
      ),
    );
  }
}
