import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAvatar extends StatelessWidget {
  final String userId;
  final double size;

  const UserAvatar({
    Key? key,
    required this.userId,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircleAvatar(
            radius: size / 2,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, size: size * 0.6),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final userName = userData?['name'] as String? ?? 'User';
        final userPhotoUrl = userData?['photoUrl'] as String?;

        if (userPhotoUrl != null) {
          return CircleAvatar(
            radius: size / 2,
            backgroundImage: NetworkImage(userPhotoUrl),
          );
        }

        return CircleAvatar(
          radius: size / 2,
          backgroundColor: Colors.blue,
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
