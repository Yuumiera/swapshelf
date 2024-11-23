import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Harita'),
        backgroundColor: Colors.blue, // Mavi başlık
      ),
      body: Center(
        child: Text(
          'Harita ekranı buraya gelecek',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
