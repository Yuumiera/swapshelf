import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    String? job,
    String? gender,
    String? city, // Yeni şehir alanı eklendi
  }) async {
    // Kullanıcı oluşturuluyor
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Kullanıcı bilgileri Firestore'a kaydediliyor
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'email': email,
      'name': name,
      'phone': phone,
      'job': job,
      'gender': gender,
      'city': city, // Şehir bilgisi kaydediliyor
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
