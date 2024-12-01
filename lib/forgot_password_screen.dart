import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapshelfproje/widgets/custom_background.dart'; // CustomBackground'ı import ettik

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendPasswordResetEmail(BuildContext context) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      print("Please enter an email address.");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      // If successful, show a success Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset email has been sent.")),
      );
    } catch (e) {
      // If an error occurs, show an error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error in sending reset email: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0, // Removed the shadow from the AppBar
      ),
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter your email to reset your password',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.0),
              // Email TextField with custom design
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Mail',
                  labelStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.email, color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide(color: Colors.white, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                  ),
                  filled: true,
                  fillColor: Colors.transparent, // Transparent background
                ),
              ),
              SizedBox(height: 16.0),
              // Transparent button with background as the app background
              GestureDetector(
                onTap: () => sendPasswordResetEmail(context),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.transparent, // Transparent background
                    borderRadius: BorderRadius.circular(32.0),
                    border: Border.all(
                        color: Colors.white, width: 1.0), // White border
                  ),
                  child: Center(
                    child: Text(
                      'Send Reset Link',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
