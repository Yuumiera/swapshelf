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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isFirstLoad = true;

  Stream<QuerySnapshot> _getMessageStream() {
    return _firestore
        .collection('messages')
        .where('sender', isEqualTo: widget.currentUserName)
        .where('recipient', isEqualTo: widget.recipientName)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      try {
        await _firestore.collection('messages').add({
          'sender': widget.currentUserName,
          'recipient': widget.recipientName,
          'text': message,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _messageController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mesaj gönderilemedi: $e")),
        );
      }
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
                if (snapshot.hasError) {
                  print('Stream error: ${snapshot.error}');
                  return Center(
                      child: Text('Bir hata oluştu: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                if (messages.isEmpty) {
                  return Center(
                      child: Text('Henüz mesaj yok. Sohbete başlayın!'));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    try {
                      final message =
                          messages[index].data() as Map<String, dynamic>;
                      final isMe = message['sender'] == widget.currentUserName;

                      return MessageBubble(
                        message: message['text'] ?? '',
                        isMe: isMe,
                        sender: message['sender'] ?? '',
                        timestamp: message['timestamp'] as Timestamp?,
                      );
                    } catch (e) {
                      print('Error rendering message at index $index: $e');
                      return SizedBox.shrink();
                    }
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
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String sender;
  final Timestamp? timestamp;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.sender,
    this.timestamp,
  }) : super(key: key);

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: isMe ? Colors.blue[100] : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                sender,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(message),
              Text(
                _formatTimestamp(timestamp),
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
