import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageToPersonScreen extends StatefulWidget {
  final String recipientName;
  final String currentUserName;

  const MessageToPersonScreen({
    Key? key,
    required this.recipientName,
    required this.currentUserName,
  }) : super(key: key);

  @override
  _MessageToPersonScreenState createState() => _MessageToPersonScreenState();
}

class _MessageToPersonScreenState extends State<MessageToPersonScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE53935),
                Color(0xFF1E88E5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.recipientName[0].toUpperCase(),
                style: TextStyle(color: Colors.blue[900]),
              ),
            ),
            SizedBox(width: 10),
            Text(
              widget.recipientName,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('messages')
                    .where(Filter.or(
                      Filter.and(
                        Filter('sender', isEqualTo: widget.currentUserName),
                        Filter('recipient', isEqualTo: widget.recipientName),
                      ),
                      Filter.and(
                        Filter('sender', isEqualTo: widget.recipientName),
                        Filter('recipient', isEqualTo: widget.currentUserName),
                      ),
                    ))
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!.docs;
                  List<MessageBubble> messageBubbles = [];

                  for (var message in messages) {
                    try {
                      final messageData =
                          message.data() as Map<String, dynamic>;

                      // Tüm gerekli alanlar için null kontrolü
                      if (messageData['text'] == null ||
                          messageData['sender'] == null ||
                          messageData['timestamp'] == null) {
                        continue;
                      }

                      final messageText = messageData['text'] as String;
                      final messageSender = messageData['sender'] as String;
                      final messageTimestamp =
                          messageData['timestamp'] as Timestamp;

                      final messageBubble = MessageBubble(
                        sender: messageSender,
                        text: messageText,
                        timestamp: messageTimestamp.toDate(),
                        isMe: messageSender == widget.currentUserName,
                      );

                      messageBubbles.add(messageBubble);
                    } catch (e) {
                      print('Error processing message: $e');
                      continue;
                    }
                  }

                  return ListView(
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    children: messageBubbles,
                  );
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE53935),
                  Color(0xFF1E88E5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.blue, size: 24),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      try {
        _firestore.collection('messages').add({
          'text': _messageController.text.trim(),
          'sender': widget.currentUserName,
          'recipient': widget.recipientName,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _messageController.clear();
      } catch (e) {
        print('Error sending message: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message')),
        );
      }
    }
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final DateTime timestamp;
  final bool isMe;

  const MessageBubble({
    Key? key,
    required this.sender,
    required this.text,
    required this.timestamp,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Material(
            elevation: 2,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: isMe ? Radius.circular(12) : Radius.zero,
              bottomRight: isMe ? Radius.zero : Radius.circular(12),
            ),
            color: isMe ? Color(0xFF1E88E5) : Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    _formatTimestamp(timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : Colors.grey,
                    ),
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
