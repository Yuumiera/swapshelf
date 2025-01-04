import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/user_avatar.dart';
import 'chat_screen.dart';
import 'screens/edit_profile_screen.dart';

class UserProfileView extends StatelessWidget {
  final String userId;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserProfileView({Key? key, required this.userId}) : super(key: key);

  Future<void> _sendExchangeRequest(
      BuildContext context, Map<String, dynamic> userData) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please login to request exchange')),
        );
        return;
      }

      // Kendi kendine istek göndermeyi engelle
      if (userId == currentUser.uid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You cannot request exchange with yourself')),
        );
        return;
      }

      // Mevcut bir istek var mı kontrol et
      final existingRequest = await FirebaseFirestore.instance
          .collection('exchanges')
          .where('requesterId', isEqualTo: currentUser.uid)
          .where('ownerId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequest.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('You already have a pending request with this user')),
        );
        return;
      }

      // Yeni takas isteği oluştur
      await FirebaseFirestore.instance.collection('exchanges').add({
        'requesterId': currentUser.uid,
        'requesterName': currentUser.displayName ?? 'Anonymous',
        'ownerId': userId,
        'ownerName': userData['name'] ?? 'Unknown',
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exchange request sent successfully!')),
      );
    } catch (e) {
      print('Error sending exchange request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send exchange request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = userId == _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          if (userId == _auth.currentUser?.uid)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading profile'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          if (userData == null) {
            return Center(child: Text('User not found'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      UserAvatar(userId: userId, size: 120),
                      SizedBox(height: 16),
                      Text(
                        userData['name'] ?? 'User',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        userData['email'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 16),
                      // Kullanıcı bilgileri
                      _buildInfoCard(userData),
                      SizedBox(height: 16),
                      // Kitap istatistikleri
                      _buildStatsCard(userId),
                      SizedBox(height: 16),
                      // Mesaj ve Takas butonları (kendi profilimiz değilse göster)
                      if (!isCurrentUser) ...[
                        SizedBox(height: 16),
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.message),
                                label: Text('Send Message'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8), // Butonlar arası boşluk
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _sendExchangeRequest(context, userData),
                                icon: Icon(Icons.swap_horiz),
                                label: Text('Request Exchange'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> userData) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(),
            _buildInfoRow('Age', userData['age']?.toString() ?? 'N/A'),
            _buildInfoRow('City', userData['city'] ?? 'N/A'),
            _buildInfoRow('Job', userData['job'] ?? 'N/A'),
            _buildInfoRow('Gender', userData['gender'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(String userId) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('library_books')
                  .where('userId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                final bookCount = snapshot.data?.docs.length ?? 0;
                return _buildInfoRow('Books in Library', bookCount.toString());
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('exchanges')
                  .where('ownerId', isEqualTo: userId)
                  .where('status', isEqualTo: 'completed')
                  .snapshots(),
              builder: (context, snapshot) {
                final exchangeCount = snapshot.data?.docs.length ?? 0;
                return _buildInfoRow(
                    'Completed Exchanges', exchangeCount.toString());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
