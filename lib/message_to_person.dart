import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageToPersonScreen extends StatefulWidget {
  final String recipientName;

  const MessageToPersonScreen({Key? key, required this.recipientName})
      : super(key: key);

  @override
  _MessageToPersonScreenState createState() => _MessageToPersonScreenState();
}

class _MessageToPersonScreenState extends State<MessageToPersonScreen> {
  final TextEditingController _messageController = TextEditingController();
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
          setState(() {
            _currentUserName = (userDoc.data() as Map<String, dynamic>)['name'];
          });
        }
      }
    } catch (e) {
      print('Error getting user name: $e');
    }
  }

  String _getConversationId() {
    if (_currentUserName == null) return '';

    // İki kullanıcı arasındaki sohbeti benzersiz bir şekilde tanımlamak için
    List<String> ids = [_currentUserName!, widget.recipientName]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Stream<QuerySnapshot>? _getMessageStream() {
    if (_currentUserName == null || widget.recipientName.isEmpty) {
      return null;
    }

    return FirebaseFirestore.instance
        .collection('messages')
        .where('conversation', isEqualTo: _getConversationId())
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  void _sendMessage() {
    if (_currentUserName == null) return;

    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      FirebaseFirestore.instance.collection('messages').add({
        'sender': _currentUserName,
        'senderId': _auth.currentUser?.uid,
        'recipient': widget.recipientName,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'conversation': _getConversationId(),
      });
      _messageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen bir mesaj yazın!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.recipientName} ile Sohbet"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getMessageStream(),
              builder: (context, snapshot) {
                if (_currentUserName == null) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                if (messages.isEmpty) {
                  return Center(
                    child: Text('Henüz mesaj yok. Sohbete başlayın!'),
                  );
                }

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final isMe = message['sender'] == _currentUserName;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[100] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['sender'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(message['message']),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Mesajınızı yazın...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: Text("Gönder"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
