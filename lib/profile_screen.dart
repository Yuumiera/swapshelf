import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_screen.dart';
import 'wishes_screen.dart';
import 'package:swapshelfproje/widgets/custom_background.dart';
import 'library_screen.dart';
import 'firebase/auth_service.dart';
import 'past_exchanges_screen.dart';
import 'widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isUpdatingAge = false;

  Stream<DocumentSnapshot> _getUserStream() {
    String uid = widget.userId ?? _auth.currentUser?.uid ?? '';
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  Future<void> _updateAge(Map<String, dynamic> data, String uid) async {
    if (_isUpdatingAge) return;

    try {
      _isUpdatingAge = true;
      if (data['dateOfBirth'] != null) {
        final birthDateTimestamp = data['dateOfBirth'] as Timestamp;
        final birthDate = birthDateTimestamp.toDate();
        final currentAge = AuthService.calculateAge(birthDate);

        if (data['age'] != currentAge &&
            (widget.userId == null ||
                widget.userId == _auth.currentUser?.uid)) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .update({'age': currentAge});
        }
      }
    } finally {
      _isUpdatingAge = false;
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      print('Error during logout: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnProfile =
        widget.userId == null || widget.userId == _auth.currentUser?.uid;

    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: _getUserStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error loading profile'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(child: Text('No profile data found'));
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>;

              Future.microtask(() => _updateAge(userData, snapshot.data!.id));

              return Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          UserAvatar(
                            userId: widget.userId ?? _auth.currentUser!.uid,
                            size: 120,
                          ),
                          SizedBox(height: 16),
                          Text(
                            userData['name'] ?? 'User',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            userData['email'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                _buildInfoRow('Age',
                                    userData['age']?.toString() ?? 'N/A'),
                                SizedBox(height: 8),
                                _buildInfoRow('Job', userData['job'] ?? 'N/A'),
                                SizedBox(height: 8),
                                _buildInfoRow(
                                    'City', userData['city'] ?? 'N/A'),
                                SizedBox(height: 8),
                                _buildInfoRow(
                                    'Gender', userData['gender'] ?? 'N/A'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(thickness: 1),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PastExchangesScreen()),
                              );
                            },
                            child: Text('Past Exchanges'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        if (isOwnProfile) ...[
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
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
