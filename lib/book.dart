import 'package:flutter/material.dart';

class Book {
  final String title; // Kitap ismi
  final String imageUrl; // Kitap görsel URL'si
  final String ownerName; // Takas yapan kişinin ismi
  final String description; // Kitap açıklaması
  final String tradeDate; // Takas tarihi
  final String condition; // Kitap durumu (yeni/eski)
  final String category; // Kitap kategorisi

  Book({
    required this.title,
    required this.imageUrl,
    required this.ownerName,
    required this.description,
    required this.tradeDate,
    required this.condition,
    required this.category,
  });

  // Kitapları Firestore formatına dönüştürmek için
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'ownerName': ownerName,
      'description': description,
      'tradeDate': tradeDate,
      'condition': condition,
      'category': category,
    };
  }

  // Firestore'dan Kitap nesnesi oluşturmak için
  static Book fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] ?? 'Bilinmeyen Kitap',
      imageUrl: json['imageUrl'] ?? '',
      ownerName: json['ownerName'] ?? 'Bilinmeyen',
      description: json['description'] ?? 'Açıklama mevcut değil',
      tradeDate: json['tradeDate'] ?? 'Tarih belirtilmemiş',
      condition: json['condition'] ?? 'Bilinmiyor',
      category: json['category'] ?? 'Diğer',
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
              child: Image.network(
                book.imageUrl,
                height: 200,
                fit: BoxFit.cover,
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
