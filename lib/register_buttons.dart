import 'package:flutter/material.dart';
import 'login_screen.dart'; // LoginScreen'i dahil ediyoruz
import 'phone_number_field.dart'; // PhoneNumberField'ı ekliyoruz

class RegisterButtons extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  RegisterButtons({required this.screenWidth, required this.screenHeight});

  @override
  _RegisterButtonsState createState() => _RegisterButtonsState();
}

class _RegisterButtonsState extends State<RegisterButtons> {
  TextEditingController birthDateController =
      TextEditingController(); // Date of Birth controller
  TextEditingController emailController =
      TextEditingController(); // Email controller
  TextEditingController passwordController =
      TextEditingController(); // Password controller
  TextEditingController firstNameController =
      TextEditingController(); // First Name controller
  TextEditingController lastNameController =
      TextEditingController(); // Last Name controller

  FocusNode _firstNameFocusNode = FocusNode();
  FocusNode _lastNameFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _phoneFocusNode = FocusNode();
  FocusNode _birthDateFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.screenHeight * 0.2, // Formun üstten başlama mesafesi
      left: widget.screenWidth * 0.1,
      right: widget.screenWidth * 0.1,
      child: Column(
        children: [
          // İsim Giriş Alanı
          TextField(
            controller: firstNameController,
            focusNode: _firstNameFocusNode,
            textInputAction: TextInputAction.next,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'First Name',
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.person, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(color: Colors.white, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(color: Colors.white, width: 2.0),
              ),
            ),
            onEditingComplete: () =>
                FocusScope.of(context).requestFocus(_lastNameFocusNode),
          ),
          SizedBox(height: widget.screenHeight * 0.02),

          // Soyisim Giriş Alanı
          TextField(
            controller: lastNameController,
            focusNode: _lastNameFocusNode,
            textInputAction: TextInputAction.next,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Last Name',
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.person, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(color: Colors.white, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(color: Colors.white, width: 2.0),
              ),
            ),
            onEditingComplete: () =>
                FocusScope.of(context).requestFocus(_emailFocusNode),
          ),
          SizedBox(height: widget.screenHeight * 0.02),

          // Email Giriş Alanı
          TextField(
            controller: emailController,
            focusNode: _emailFocusNode,
            textInputAction: TextInputAction.next,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
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
            ),
            onEditingComplete: () =>
                FocusScope.of(context).requestFocus(_passwordFocusNode),
          ),
          SizedBox(height: widget.screenHeight * 0.02),

          // Şifre Giriş Alanı
          TextField(
            controller: passwordController,
            focusNode: _passwordFocusNode,
            obscureText: true,
            textInputAction: TextInputAction.next,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.lock, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(color: Colors.white, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(color: Colors.white, width: 2.0),
              ),
            ),
            onEditingComplete: () =>
                FocusScope.of(context).requestFocus(_phoneFocusNode),
          ),
          SizedBox(height: widget.screenHeight * 0.02),

          // Telefon Giriş Alanı
          PhoneNumberField(
            focusNode: _phoneFocusNode,
            onEditingComplete: () =>
                FocusScope.of(context).requestFocus(_birthDateFocusNode),
          ),
          SizedBox(height: widget.screenHeight * 0.02),

          // Doğum Tarihi Giriş Alanı
          TextField(
            controller: birthDateController,
            focusNode: _birthDateFocusNode,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Date of Birth',
              labelStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(Icons.calendar_today, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(color: Colors.white, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(color: Colors.white, width: 2.0),
              ),
            ),
            onTap: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (selectedDate != null) {
                String formattedDate =
                    "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";
                birthDateController.text = formattedDate;
              }
            },
          ),
          SizedBox(height: widget.screenHeight * 0.03),

          // Submit (Gönder) Butonu
          Container(
            width: widget.screenWidth * 0.8,
            height: widget.screenHeight * 0.06,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(32.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // Register butonuna basıldığında LoginScreen'e yönlendirme
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginScreen()), // LoginScreen'e yönlendiriyoruz
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              child: Text(
                'Register',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: widget.screenHeight * 0.03),

          // Already Registered? Butonu
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                // Giriş ekranına yönlendirme
                Navigator.pop(context); // Veya başka bir ekran yönlendirmesi
              },
              child: Text(
                'Already Registered? Login',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
