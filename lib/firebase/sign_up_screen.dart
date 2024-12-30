import 'package:flutter/material.dart';
import 'sign_up_form.dart';
import '../widgets/custom_background.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: CustomBackground(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, // Genişliğe göre padding ayarlanır
          ),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight, // Ekran yüksekliği kadar alan sağlanır
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        height: screenHeight *
                            0.05), // Ekran yüksekliğine göre boşluk
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Expanded(
                      child: SignUpForm(), // Form widget'ı yer kaplama yapar
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
