import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageToPersonScreen extends StatefulWidget {
  final String recipientName;

  const MessageToPersonScreen({Key? key, required this.recipientName})
      : super(key: key);

  @override
  _MessageToPersonScreenState createState() => _MessageToPersonScreenState();
}

class _MessageToPersonScreenState extends State<MessageToPersonScreen> {
  final TextEditingController _messageController = TextEditingController();
  final String currentUser = "current_user"; // Şu anki kullanıcının adı/id'si

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      FirebaseFirestore.instance.collection('messages').add({
        'sender': currentUser,
        'recipient': widget.recipientName,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
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
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('sender', whereIn: [currentUser, widget.recipientName])
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      title: Text(message['message']),
                      subtitle: Text(
                          "Gönderen: ${message['sender']} - Alıcı: ${message['recipient']}"),
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
