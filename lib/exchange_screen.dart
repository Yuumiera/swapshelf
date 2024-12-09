import 'package:flutter/material.dart';
import 'book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/gradient_app_bar.dart';

class ExchangeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Takaslarım',
      ),
      body: FutureBuilder<List<Book>>(
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
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 0.8,
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
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(12.0)),
                          child: Image.network(
                            book.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          book.title,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
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
    );
  }
}

Future<List<Book>> fetchBooksFromFirestore() async {
  final querySnapshot =
      await FirebaseFirestore.instance.collection('takaslarim').get();
  return querySnapshot.docs
      .map((doc) => Book.fromJson(doc.data() as Map<String, dynamic>))
      .toList();
}
