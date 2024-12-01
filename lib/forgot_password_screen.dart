import 'package:flutter/material.dart';
import 'package:swapshelfproje/widgets/custom_background.dart';
import '../login_screen.dart';
import 'phone_reset.dart';
import 'email_reset.dart';

class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Choose a method to reset your password',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.0),

              // Phone reset button
              PhoneResetButton(),
              SizedBox(height: 20.0),

              // Email reset button
              EmailResetButton(),
            ],
          ),
        ),
      ),
    );
  }
}
