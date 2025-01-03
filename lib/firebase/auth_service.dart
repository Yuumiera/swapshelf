import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Yaş hesaplama fonksiyonu
  static int calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;

    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  static Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Kullanıcı girişi
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore'dan kullanıcı verilerini al
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Doğum tarihini Timestamp'ten DateTime'a çevir
        if (userData['dateOfBirth'] != null) {
          Timestamp birthDateTimestamp = userData['dateOfBirth'];
          DateTime birthDate = birthDateTimestamp.toDate();

          // Yaşı hesapla ve Firestore'da güncelle
          int currentAge = calculateAge(birthDate);
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({'age': currentAge});
        }
      }

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return 'Invalid email or password.';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email format.';
      } else {
        return e.message ?? 'An error occurred!';
      }
    }
  }

  static Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required int age,
    String? job,
    String? gender,
    String? city,
    required DateTime dateOfBirth, // dateOfBirth parametresini ekleyin
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'age': age,
        'job': job,
        'gender': gender,
        'city': city,
        'dateOfBirth': Timestamp.fromDate(
            dateOfBirth), // Doğum tarihini Timestamp olarak kaydet
      });

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return 'Invalid email or password.';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email format.';
      } else {
        return e.message ?? 'An error occurred!';
      }
    }
  }
}
