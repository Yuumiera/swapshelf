import 'package:flutter/material.dart';
import 'book.dart'; // Kitap modelini import ediyoruz
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/gradient_app_bar.dart';
import 'widgets/home_background.dart';

class ExchangeScreen extends StatelessWidget {
  final List<Book> exchangeBooks;

  ExchangeScreen({required this.exchangeBooks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Takaslarım',
      ),
      body: SafeArea(
        child: HomeBackground(
          child: FutureBuilder<List<Book>>(
            future: fetchBooksFromFirestore(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Bir hata oluştu.'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('Henüz takas yapılmamış kitap yok.'));
              } else {
                final books = snapshot.data!;
                return GridView.builder(
                  padding: EdgeInsets.all(12.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 sütunlu grid
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 0.8, // Kartlar biraz daha uzun
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12.0)),
                              child: Image.network(
                                book.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              book.title,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

Future<List<Book>> fetchBooksFromFirestore() async {
  final querySnapshot =
      await FirebaseFirestore.instance.collection('exchanges').get();
  final books = querySnapshot.docs
      .map((doc) => Book.fromJson(doc.data() as Map<String, dynamic>))
      .toList();
  return books;
}
