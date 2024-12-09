import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore için

class AddBookScreen extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Kitap Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Kitap Adı',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: authorController,
              decoration: InputDecoration(
                labelText: 'Yazar',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: imageUrlController,
              decoration: InputDecoration(
                labelText: 'Görsel URL',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    authorController.text.isNotEmpty &&
                    imageUrlController.text.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance.collection('wishes').add({
                      'title': titleController.text.trim(),
                      'author': authorController.text.trim(),
                      'imageUrl': imageUrlController.text.trim(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Kitap başarıyla eklendi!')),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hata: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lütfen tüm alanları doldurun!')),
                  );
                }
              },
              child: Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
