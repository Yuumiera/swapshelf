import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapshelfproje/message_to_person.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _getCurrentUserName();
  }

  Future<void> _getCurrentUserName() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && mounted) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _currentUserName = userData['name'] ?? 'Unknown User';
          });
        }
      }
    } catch (e) {
      print('Error getting user name: $e');
    }
  }

  Stream<QuerySnapshot>? _getChatsStream() {
    if (_currentUserName == null) return null;

    return FirebaseFirestore.instance
        .collection('messages')
        .where('participants', arrayContains: _currentUserName)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sohbetler"),
      ),
      body: _currentUserName == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: _getChatsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                // Benzersiz sohbetleri bul
                Map<String, Map<String, dynamic>> uniqueChats = {};

                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final otherPerson = data['sender'] == _currentUserName
                      ? data['recipient']
                      : data['sender'];

                  // Her kişi için en son mesajı sakla
                  if (!uniqueChats.containsKey(otherPerson) ||
                      (data['timestamp'] != null &&
                          (uniqueChats[otherPerson]!['timestamp'] == null ||
                              (data['timestamp'] as Timestamp).compareTo(
                                      uniqueChats[otherPerson]!['timestamp']) >
                                  0))) {
                    uniqueChats[otherPerson] = data;
                  }
                }

                if (uniqueChats.isEmpty) {
                  return Center(
                    child: Text('Henüz mesajınız yok'),
                  );
                }

                return ListView.builder(
                  itemCount: uniqueChats.length,
                  itemBuilder: (context, index) {
                    final otherPerson = uniqueChats.keys.elementAt(index);
                    final lastMessage = uniqueChats[otherPerson]!;

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(otherPerson[0].toUpperCase()),
                      ),
                      title: Text(otherPerson),
                      subtitle: Text(
                        lastMessage['message'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessageToPersonScreen(
                                recipientName: otherPerson),
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
}
