// book.dart dosyasına Book modelini taşıyoruz.
class Book {
  final String title;
  final String imageUrl;

  Book({required this.title, required this.imageUrl});

  // Kitapları Firestore formatına dönüştürmek için
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'imageUrl': imageUrl,
    };
  }

  // Firestore'dan Kitap nesnesi oluşturmak için
  static Book fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      imageUrl: json['imageUrl'],
    );
  }
}
