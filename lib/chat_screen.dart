import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapshelfproje/message_to_person_screen.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _getCurrentUserName();
  }

  Future<void> _getCurrentUserName() async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .get();
      setState(() {
        _currentUserName = userDoc.data()?['name'];
      });
    } catch (e) {
      print('Error getting current user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading messages'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // Benzersiz sohbetleri bul
          Map<String, Map<String, dynamic>> uniqueChats = {};

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final sender = data['sender'] as String;
            final recipient = data['recipient'] as String;

            // Sadece mevcut kullanıcının sohbetlerini filtrele
            if (sender == _currentUserName || recipient == _currentUserName) {
              // Diğer kullanıcıyı belirle
              final otherUser = sender == _currentUserName ? recipient : sender;

              // En son mesajı sakla
              if (!uniqueChats.containsKey(otherUser) ||
                  (uniqueChats[otherUser]!['timestamp'] as Timestamp)
                          .compareTo(data['timestamp'] as Timestamp) <
                      0) {
                uniqueChats[otherUser] = {
                  ...data,
                  'otherUser': otherUser,
                };
              }
            }
          }

          if (uniqueChats.isEmpty) {
            return Center(child: Text('No messages yet'));
          }

          return ListView.builder(
            itemCount: uniqueChats.length,
            itemBuilder: (context, index) {
              final chat = uniqueChats.values.toList()[index];
              final otherUser = chat['otherUser'] as String;
              final lastMessage = chat['text'] as String;
              final timestamp = chat['timestamp'] as Timestamp;
              final isCurrentUserSender = chat['sender'] == _currentUserName;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      otherUser[0].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(otherUser),
                  subtitle: Row(
                    children: [
                      if (isCurrentUserSender)
                        Icon(Icons.done, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    _formatTimestamp(timestamp),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessageToPersonScreen(
                          recipientName: otherUser,
                          currentUserName: _currentUserName ?? 'Me',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
