import 'package:flutter/material.dart';
import 'package:swapshelfproje/book.dart';

class BookDetailPage extends StatelessWidget {
  final Book book;

  const BookDetailPage({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                book.imageUrl,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),
            Text("Kitap İsmi: ${book.title}"),
            Text("Takas Yapan: ${book.ownerName}"),
            Text("Açıklama: ${book.description}"),
            Text("Takas Tarihi: ${book.tradeDate}"),
            Text("Durum: ${book.condition}"),
            Text("Kategori: ${book.category}"),
          ],
        ),
      ),
    );
  }
}
