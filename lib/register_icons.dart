import 'package:flutter/material.dart';

class RegisterIcons extends StatelessWidget {
  final double logoSize;

  RegisterIcons({required this.logoSize});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height *
          0.05, // Ekran yüksekliğine göre üstten boşluk
      left: MediaQuery.of(context).size.width *
          0.05, // Ekran genişliğine göre soldan boşluk
      child: ClipOval(
        child: Image.asset(
          'assets/img/book_logo.png', // Kitap logosunun yolu
          width: logoSize, // Logo boyutunu dinamik hale getirdik
          height: logoSize, // Logo boyutunu dinamik hale getirdik
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
