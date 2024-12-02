import 'package:flutter/material.dart';

// Gradient Bottom Navigation Bar Widget
class GradientBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;

  GradientBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red, Colors.blue], // Red to Blue Gradient
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: items,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors
            .transparent, // Make background transparent for gradient to show
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle:
            TextStyle(fontWeight: FontWeight.bold), // Selected item label style
        unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal), // Unselected item label style
        iconSize: 30, // Icon size
        elevation: 0, // Remove the shadow
        showUnselectedLabels: true,
        showSelectedLabels: true,
      ),
    );
  }
}
