import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapshelfproje/message_to_person_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUserName();
  }

  Future<void> _getCurrentUserName() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && mounted) {
          setState(() {
            _currentUserName = (userDoc.data() as Map<String, dynamic>)['name'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error getting user name: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Stream<QuerySnapshot>? _getChatsStream() {
    if (_currentUserName == null) return null;

    return _firestore
        .collection('messages')
        .where('sender', isEqualTo: _currentUserName)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Sohbetler")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Sohbetler")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getChatsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Stream error: ${snapshot.error}');
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(child: Text('Henüz mesajınız yok'));
          }

          Map<String, Map<String, dynamic>> uniqueChats = {};

          for (var doc in docs) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              if (data['sender'] == null || data['recipient'] == null) continue;

              final otherPerson = data['sender'] == _currentUserName
                  ? data['recipient']
                  : data['sender'];

              if (!uniqueChats.containsKey(otherPerson) ||
                  (data['timestamp'] != null &&
                      (uniqueChats[otherPerson]!['timestamp'] == null ||
                          (data['timestamp'] as Timestamp).compareTo(
                                  uniqueChats[otherPerson]!['timestamp']) >
                              0))) {
                uniqueChats[otherPerson] = data;
              }
            } catch (e) {
              print('Error processing chat: $e');
              continue;
            }
          }

          return ListView.builder(
            itemCount: uniqueChats.length,
            itemBuilder: (context, index) {
              final otherPerson = uniqueChats.keys.elementAt(index);
              final lastMessage = uniqueChats[otherPerson]!;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(otherPerson[0].toUpperCase()),
                ),
                title: Text(otherPerson),
                subtitle: Text(
                  lastMessage['text'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  _formatTimestamp(lastMessage['timestamp'] as Timestamp?),
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
                        recipientName: otherPerson,
                        currentUserName: _currentUserName!,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      // Bugün ise saat göster
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // Dün ise
      return 'Dün';
    } else if (difference.inDays < 7) {
      // Son 7 gün içinde ise gün adını göster
      final weekDays = [
        'Pazartesi',
        'Salı',
        'Çarşamba',
        'Perşembe',
        'Cuma',
        'Cumartesi',
        'Pazar'
      ];
      return weekDays[date.weekday - 1];
    } else {
      // Daha eski ise tarihi göster
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final DateTime timestamp;

  const MessageBubble({
    Key? key,
    required this.sender,
    required this.text,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(10),
            color: Colors.blue[100],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatTimestamp(timestamp),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')} ${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}
