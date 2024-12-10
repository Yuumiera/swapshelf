import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapshelfproje/message_to_person.dart';

class ChatScreen extends StatelessWidget {
  final String currentUser = "current_user"; // Şu anki kullanıcının adı/id'si

  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sohbetler"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .where('sender', isEqualTo: currentUser)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          // Alıcı isimlerini listele (benzersiz olacak şekilde)
          final recipients = snapshot.data!.docs
              .map((doc) => doc['recipient'] as String)
              .toSet()
              .toList();

          return ListView.builder(
            itemCount: recipients.length,
            itemBuilder: (context, index) {
              final recipient = recipients[index];
              return ListTile(
                title: Text(recipient),
                onTap: () {
                  // Mesaj gönderme ekranına git
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MessageToPersonScreen(recipientName: recipient),
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
