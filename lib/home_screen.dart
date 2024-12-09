import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book.dart'; // Kitap modelini import ediyoruz
import 'profile_screen.dart'; // Profil ekranı import
import 'widgets/gradient_app_bar.dart'; // GradientAppBar import
import 'widgets/gradient_bottom_navigation_bar.dart'; // GradientBottomNavigationBar import
import 'package:swapshelfproje/widgets/custom_background.dart';
import 'exchange_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // Ana Sayfa varsayılan sekme
  List<Book> selectedBooks = []; // Takaslanan kitaplar

  @override
  void initState() {
    super.initState();
    _loadTakasBooks(); // Takas kitaplarını Firebase'den yükle
  }

  // Firestore'dan takas edilmiş kitapları yükleme
  Future<void> _loadTakasBooks() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('takaslarim').get();
    setState(() {
      selectedBooks = querySnapshot.docs
          .map((doc) => Book.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Firestore'a kitap ekleme
  Future<void> _addBookToFirestore(Book book) async {
    final docRef = FirebaseFirestore.instance.collection('takaslarim').doc();
    await docRef.set(book.toJson());
    _loadTakasBooks(); // Firebase güncellendikten sonra yeniden yükle
  }

  // Ana Sayfa İçeriği
  Widget _buildHomeScreen() {
    final books = [
      Book(title: "Kitap 1", imageUrl: "https://via.placeholder.com/150"),
      Book(title: "Kitap 2", imageUrl: "https://via.placeholder.com/150"),
      Book(title: "Kitap 3", imageUrl: "https://via.placeholder.com/150"),
      Book(title: "Kitap 4", imageUrl: "https://via.placeholder.com/150"),
      Book(title: "Kitap 5", imageUrl: "https://via.placeholder.com/150"),
      Book(title: "Kitap 6", imageUrl: "https://via.placeholder.com/150"),
    ];

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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    _addBookToFirestore(book);
                  },
                  child: Text('Takas Yap'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Takaslarım Sekmesi İçeriği
  Widget _buildTakaslarimScreen() {
    if (selectedBooks.isEmpty) {
      return Center(child: Text('Henüz takas edilmiş kitap yok.'));
    }
    return ListView.builder(
      padding: EdgeInsets.all(12.0),
      itemCount: selectedBooks.length,
      itemBuilder: (context, index) {
        final book = selectedBooks[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListTile(
            leading: Image.network(book.imageUrl),
            title: Text(book.title),
            subtitle: Text('Takas Edildi'),
          ),
        );
      },
    );
  }

  // Sayfalara Göre İçerik Getir
  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return Center(child: Text('Harita Sayfası'));
      case 1:
        return ExchangeScreen(exchangeBooks: selectedBooks);
      case 2:
        return _buildHomeScreen();
      case 3:
        return Center(child: Text('Mesajlar Sayfası'));
      case 4:
        return ProfileScreen();
      default:
        return _buildHomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: 'Ana Sayfa'),
      body: SafeArea(child: _getBody()),
      bottomNavigationBar: GradientBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Harita'),
          BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz), label: 'Takaslarım'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mesajlar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
