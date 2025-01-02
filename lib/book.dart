import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String title;
  final String ownerName;
  final String description;
  final String tradeDate;
  final String condition;
  final String category;
  final String authorName;
  final String? userId;

  Book({
    required this.title,
    required this.ownerName,
    required this.description,
    required this.tradeDate,
    required this.condition,
    required this.category,
    required this.authorName,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'ownerName': ownerName,
      'description': description,
      'tradeDate': tradeDate,
      'condition': condition,
      'category': category,
      'authorName': authorName,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  static Book fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] ?? 'Unknown Book',
      ownerName: json['ownerName'] ?? 'Unknown Owner',
      description: json['description'] ?? 'No description',
      tradeDate: json['tradeDate'] ?? 'No date',
      condition: json['condition'] ?? 'Unknown',
      category: json['category'] ?? 'Other',
      authorName: json['authorName'] ?? 'Unknown Author',
      userId: json['userId'],
    );
  }
}

// Book modeline ek olarak bir widget döndüren sınıf
class BookWidget extends StatelessWidget {
  final Book book;

  const BookWidget({Key? key, required this.book}) : super(key: key);

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
              child: Icon(
                Icons.book,
                size: 100,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Kitap İsmi: ${book.title}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
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
