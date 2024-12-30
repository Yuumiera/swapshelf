import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_screen.dart';
import 'wishes_screen.dart'; // My Wishes Screen
import 'package:swapshelfproje/widgets/custom_background.dart';
import 'library_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Kullanıcı verilerini Firestore'dan alır
  Future<void> _fetchUserData() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          var data = userDoc.data();
          if (data != null && data is Map<String, dynamic>) {
            setState(() {
              _userData = data;
            });
          } else {
            print('User data is not in expected format');
          }
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Çıkış yapma işlemi
  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      print('Logout successful');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      print('Error during logout: ${e.toString()}');
    }
  }

  // Yaş hesaplama fonksiyonu
  int _calculateAge(Timestamp? birthDate) {
    if (birthDate == null) return 0;
    DateTime dob = birthDate.toDate();
    DateTime today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_userData != null) ...[
                    Center(
                      child: Column(
                        children: [
                          SizedBox(height: 16),
                          Text(
                            _userData?['name'] ?? 'Full Name',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Age: ${_calculateAge(_userData?['dob'])}',
                            style: TextStyle(
                                fontSize: 16,
                                color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Job: ${_userData?['job'] ?? 'Unknown'}',
                            style: TextStyle(
                                fontSize: 16,
                                color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'City: ${_userData?['city'] ?? 'Unknown'}',
                            style: TextStyle(
                                fontSize: 16,
                                color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Gender: ${_userData?['gender'] ?? 'Unknown'}',
                            style: TextStyle(
                                fontSize: 16,
                                color: const Color.fromARGB(255, 2, 2, 2)),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Email: ${_userData?['email'] ?? 'example@example.com'}',
                            style: TextStyle(
                                fontSize: 16,
                                color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                    // Adding a Spacer to push the buttons further down
                    Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WishesScreen()),
                              );
                            },
                            child: Text('My Wishes'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LibraryScreen()),
                              );
                            },
                            child: Text('My Library'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to Past Swaps
                            },
                            child: Text('Past Swaps'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _signOut(context),
                            icon: Icon(Icons.logout),
                            label: Text('Logout'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
