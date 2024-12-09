import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book.dart'; // Kitap modelini import ediyoruz
import 'exchange_screen.dart'; // Takas ekranını import ediyoruz
import 'widgets/gradient_app_bar.dart'; // GradientAppBar import
import 'widgets/gradient_bottom_navigation_bar.dart'; // GradientBottomNavigationBar import
import 'widgets/home_background.dart'; // HomeBackground import

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // Başlangıçta Ana Sayfa sekmesi seçili
  List<Book> selectedBooks = [];

  @override
  void initState() {
    super.initState();
    _loadSavedBooks(); // Uygulama başlatıldığında kaydedilen kitapları yükle
  }

  // Kitapları Firebase'e kaydetme
  Future<void> addBookToFirestore(Book book) async {
    final docRef = FirebaseFirestore.instance
        .collection('exchanges')
        .doc(); // Yeni bir doküman oluşturur
    await docRef.set(book.toJson()); // Kitap verisini Firestore'a kaydeder
  }

  // Kaydedilen kitapları Firebase'den yükleme
  Future<void> _loadSavedBooks() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('exchanges').get();
    setState(() {
      selectedBooks = querySnapshot.docs
          .map((doc) => Book.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<Book>> fetchBooks() async {
    await Future.delayed(Duration(seconds: 2));
    return [
      Book(title: "Kitap 1", imageUrl: "https://via.placeholder.com/150"),
      Book(title: "Kitap 2", imageUrl: "https://via.placeholder.com/150"),
      Book(title: "Kitap 3", imageUrl: "https://via.placeholder.com/150"),
      Book(title: "Kitap 4", imageUrl: "https://via.placeholder.com/150"),
      Book(title: "Kitap 5", imageUrl: "https://via.placeholder.com/150"),
      Book(title: "Kitap 6", imageUrl: "https://via.placeholder.com/150"),
    ];
  }

  void _addBookToExchange(Book book) {
    setState(() {
      selectedBooks.add(book);
    });
    addBookToFirestore(book); // Kitapları Firebase'e kaydediyoruz
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Ana Sayfa',
      ),
      body: SafeArea(
        child: HomeBackground(
          child: _currentIndex == 2
              ? FutureBuilder<List<Book>>(
                  future: fetchBooks(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Bir hata oluştu.'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text('Şu anda listelenecek kitap yok.'));
                    } else {
                      final books = snapshot.data!;
                      return GridView.builder(
                        padding: EdgeInsets.all(12.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _addBookToExchange(
                                          book); // Takas yapma işlemi
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
                  },
                )
              : FutureBuilder<List<Book>>(
                  future: fetchBooksFromFirestore(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Bir hata oluştu.'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text('Henüz takas yapılmamış kitap yok.'));
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
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
      bottomNavigationBar: GradientBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map, size: 30),
            label: 'Harita',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz, size: 30),
            label: 'Takaslarım',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message, size: 30),
            label: 'Mesajlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
