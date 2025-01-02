import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'message_to_person.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserName;
  String? _errorMessage;

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
            _errorMessage = null;
          });
        } else {
          setState(() {
            _errorMessage = 'Kullanıcı bilgileri bulunamadı';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Oturum açık değil';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Kullanıcı bilgileri alınırken hata: $e';
      });
      print('Error getting user name: $e');
    }
  }

  Stream<QuerySnapshot> _getConversationsStream() {
    if (_currentUserName == null) {
      print('Current user name is null, returning empty stream');
      return Stream.empty();
    }

    print('Getting conversations for user: $_currentUserName');
    return _firestore
        .collection('messages')
        .where(Filter.or(
          Filter('sender', isEqualTo: _currentUserName),
          Filter('recipient', isEqualTo: _currentUserName),
        ))
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sohbetler'),
      ),
      body: _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Hata: $_errorMessage'),
                  ElevatedButton(
                    onPressed: _getCurrentUserName,
                    child: Text('Tekrar Dene'),
                  ),
                ],
              ),
            )
          : _currentUserName == null
              ? Center(child: CircularProgressIndicator())
              : StreamBuilder<QuerySnapshot>(
                  stream: _getConversationsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print('Stream error: ${snapshot.error}');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Bir hata oluştu: ${snapshot.error}'),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {});
                              },
                              child: Text('Tekrar Dene'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data?.docs ?? [];

                    if (messages.isEmpty) {
                      return Center(
                        child: Text('Henüz hiç sohbetiniz yok.'),
                      );
                    }

                    final Map<String, Map<String, dynamic>> uniqueUsers = {};

                    for (var message in messages) {
                      try {
                        final data = message.data() as Map<String, dynamic>;
                        final otherUser = data['sender'] == _currentUserName
                            ? data['recipient'] as String
                            : data['sender'] as String;
                        final timestamp = data['timestamp'] as Timestamp?;

                        if (!uniqueUsers.containsKey(otherUser) ||
                            (timestamp != null &&
                                (uniqueUsers[otherUser]!['timestamp'] == null ||
                                    timestamp.toDate().isAfter(
                                        (uniqueUsers[otherUser]!['timestamp']
                                                as Timestamp)
                                            .toDate())))) {
                          uniqueUsers[otherUser] = data;
                        }
                      } catch (e) {
                        print('Error processing message: $e');
                        continue;
                      }
                    }

                    return ListView.builder(
                      itemCount: uniqueUsers.length,
                      itemBuilder: (context, index) {
                        final userData = uniqueUsers.values.toList()[index];
                        final otherUser = userData['sender'] == _currentUserName
                            ? userData['recipient'] as String
                            : userData['sender'] as String;
                        final lastMessage =
                            userData['message'] as String? ?? 'Mesaj yok';

                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(otherUser[0].toUpperCase()),
                          ),
                          title: Text(otherUser),
                          subtitle: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MessageToPersonScreen(
                                  recipientName: otherUser,
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
}
