import 'package:flutter/material.dart';
import 'register_screen.dart'; // RegisterScreen'in olduğu dosyanın yolu
import 'home_screen.dart'; // HomeScreen'i dahil ediyoruz

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;

  // FocusNode'lar
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    double buttonWidth = screenWidth * 0.8;
    double googleButtonWidth = buttonWidth;

    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Klavye açıldığında ekranın yeniden boyutlanmasını sağlar
      body: GestureDetector(
        onTap: () {
          // Kullanıcı ekranda bir yere tıklarsa klavyeyi kapat
          FocusScope.of(context).unfocus();
        },
        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue, Colors.red],
            ),
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior
                .onDrag, // Klavye kaydırıldığında kapanması sağlanır
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: screenHeight * 0.1),
                  ClipOval(
                    child: Image.asset(
                      'lib/img/SwapShelf.png',
                      width: screenWidth * 0.3,
                      height: screenWidth * 0.3,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Swapshelf',
                    style: TextStyle(
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  // Email Giriş Alanı
                  TextField(
                    focusNode: _emailFocusNode, // FocusNode ekleniyor
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
                    onTap: () {
                      // Email alanına tıklanınca klavye açılır
                      FocusScope.of(context).requestFocus(_emailFocusNode);
                    },
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  // Şifre Giriş Alanı
                  TextField(
                    focusNode: _passwordFocusNode, // FocusNode ekleniyor
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(Icons.lock, color: Colors.white),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                      ),
                    ),
                    onTap: () {
                      // Password alanına tıklanınca klavye açılır
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  Container(
                    width: buttonWidth,
                    height: screenHeight * 0.06,
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
                        // Login butonuna basıldığında HomeScreen'e yönlendir
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.white,
                          thickness: 1,
                          endIndent: 16,
                        ),
                      ),
                      Text(
                        'or',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.white,
                          thickness: 1,
                          indent: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  GestureDetector(
                    onTap: () {},
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32.0),
                      child: Container(
                        width: googleButtonWidth,
                        height: screenHeight * 0.06,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'lib/img/google_logo.png',
                              fit: BoxFit.contain,
                              height: screenHeight * 0.03,
                            ),
                            SizedBox(width: 8.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Create New Account',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: BorderSide(color: Colors.white, width: 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
