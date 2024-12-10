import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapshelfproje/chat_screen.dart';
import 'book.dart';
import 'profile_screen.dart';
import 'widgets/gradient_app_bar.dart';
import 'widgets/gradient_bottom_navigation_bar.dart';
import 'exchange_screen.dart';
import 'package:swapshelfproje/widgets/book_detail_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // Varsayılan sekme: Ana Sayfa
  List<Book> selectedBooks = [];
  List<Book> allBooks = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _loadTakasBooks();
  }

  // Firestore'dan tüm kitapları yükleme
  Future<void> _loadBooks() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('books').get();
    setState(() {
      allBooks = querySnapshot.docs
          .map((doc) => Book.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
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
    await FirebaseFirestore.instance
        .collection('takaslarim')
        .doc()
        .set(book.toJson());
    _loadTakasBooks();
  }

  // Ana Sayfa İçeriği
  Widget _buildHomeScreen() {
    return GridView.builder(
      padding: EdgeInsets.all(12.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 0.8,
      ),
      itemCount: allBooks.length,
      itemBuilder: (context, index) {
        final book = allBooks[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailPage(book: book),
              ),
            );
          },
          child: Card(
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _addBookToFirestore(book);
                    },
                    child: Text('Takas Yap'),
                  ),
                ),
              ],
            ),
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
            subtitle: Text('Takas Yapan: ${book.ownerName}'),
          ),
        );
      },
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return Center(child: Text('Harita Sayfası'));
      case 1:
        return ExchangeScreen();
      case 2:
        return _buildHomeScreen();
      case 3:
        return ChatScreen();
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
