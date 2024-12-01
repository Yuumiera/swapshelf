import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class PhoneResetButton extends StatefulWidget {
  @override
  _PhoneResetButtonState createState() => _PhoneResetButtonState();
}

class _PhoneResetButtonState extends State<PhoneResetButton> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String _verificationId = '';

  // Method to send phone verification code
  Future<void> sendPhoneVerification(BuildContext context) async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      print("Please enter a phone number.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Phone number verified successfully.")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Phone number verification failed: $e")),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification code sent to $phoneNumber")),
          );
          _showVerificationDialog(
              context); // Show dialog to input verification code
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error in sending verification code: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to verify the code entered by the user
  Future<void> verifyCode(BuildContext context) async {
    final code = _verificationCodeController.text.trim();
    if (code.isEmpty) {
      print("Please enter the verification code.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: code,
      );
      await _auth.signInWithCredential(credential);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Phone number verified successfully.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification failed: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show dialog to enter verification code
  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter the verification code"),
          content: TextField(
            controller: _verificationCodeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Verification Code',
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                verifyCode(context); // Verify the entered code
                Navigator.pop(context);
              },
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Verify Code'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Enter your phone number"),
              content: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    sendPhoneVerification(context);
                    Navigator.pop(context);
                  },
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Send Verification Code'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(32.0),
          border: Border.all(color: Colors.white, width: 1.0),
        ),
        child: Center(
          child: Text(
            'Reset via Phone',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
