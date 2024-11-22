import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../login_screen.dart'; // LoginScreen dosyasını dahil edin

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController =
      TextEditingController(); // Kullanıcı adı ekledim
  bool _isLoading = false; // Yüklenme durumunu kontrol eder

  // Kullanıcı bilgilerini Firestore'a kaydetme fonksiyonu
  Future<void> saveUserData(User user) async {
    try {
      // Firestore'da 'users' koleksiyonunda kullanıcıyı oluşturun
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'name': _nameController.text, // Kullanıcı adını ekliyoruz
        'createdAt':
            FieldValue.serverTimestamp(), // Kullanıcı kaydının zaman damgası
      });
    } catch (e) {
      print("Firestore'da kullanıcı verisi eklenirken hata oluştu: $e");
    }
  }

  // Kullanıcı kaydetme fonksiyonu
  Future<void> signUp() async {
    setState(() {
      _isLoading = true; // Yüklenme durumunu aktif et
    });

    try {
      // Email ve şifre ile kullanıcı oluşturma
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Firestore'a kullanıcı verilerini kaydetme
      await saveUserData(userCredential.user!);

      // Başarılı kayıt sonrası LoginScreen'e yönlendirme
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Kayıt başarılı! Şimdi giriş yapabilirsiniz.'),
        backgroundColor: Colors.green,
      ));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Hata durumunda mesaj göster
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? 'Bir hata oluştu!'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false; // Yüklenme durumunu kapat
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Kullanıcı adı alanı
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 10),
            // Email giriş alanı
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            // Şifre giriş alanı
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator() // Yüklenme durumunda gösterilecek
                : ElevatedButton(
                    onPressed: signUp,
                    child: Text('Sign Up'),
                  ),
          ],
        ),
      ),
    );
  }
}
