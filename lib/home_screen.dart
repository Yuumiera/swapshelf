import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'map_screen.dart';
import 'profile_screen.dart'; // Profil ekranı için import

// Örnek kitap modeli
class Book {
  final String title;
  final String imageUrl;

  Book({required this.title, required this.imageUrl});
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Seçili olan tab index
  TextEditingController _searchController = TextEditingController();

  // Örnek kitap verileri
  Future<List<Book>> fetchBooks() async {
    await Future.delayed(Duration(seconds: 2)); // Simülasyon için bekleme
    return [
      Book(title: "Kitap 1", imageUrl: "https://via.placeholder.com/150"),
      Book(title: "Kitap 2", imageUrl: "https://via.placeholder.com/150"),
      Book(title: "Kitap 3", imageUrl: "https://via.placeholder.com/150"),
      Book(title: "Kitap 4", imageUrl: "https://via.placeholder.com/150"),
      Book(title: "Kitap 5", imageUrl: "https://via.placeholder.com/150"),
      Book(title: "Kitap 6", imageUrl: "https://via.placeholder.com/150"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Mavi tonları
        centerTitle: true,
        title: Row(
          children: [
            // Modern arama çubuğu
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(30.0),
                  color: Colors.white,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                      hintText: 'Kitap ara...',
                      hintStyle: TextStyle(color: Colors.black54),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.blue,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onChanged: (query) {
                      // Arama fonksiyonu burada eklenebilir
                    },
                  ),
                ),
              ),
            ),
            // Filtre ikonu
            IconButton(
              icon: Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {
                // Filtreleme fonksiyonu burada eklenebilir
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue, // Mavi üst kısım
                Colors.red, // Kırmızı alt kısım
              ], // Mavi üstten kırmızıya geçiş
            ),
          ),
          child: _currentIndex ==
                  2 // Ana sayfa butonuna tıklanınca kitapları göster
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
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount =
                              constraints.maxWidth > 600 ? 3 : 2;
                          return Scrollbar(
                            thickness:
                                8.0, // Kaydırma çubuğunun kalınlığını ayarla
                            radius: Radius.circular(8.0), // Yuvarlak köşeler
                            thumbVisibility:
                                true, // Scroll çubuğu her zaman görünür
                            child: GridView.builder(
                              padding: EdgeInsets.all(12.0),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12.0,
                                mainAxisSpacing: 12.0,
                                childAspectRatio:
                                    0.8, // Daha dikey kitap kartları
                              ),
                              itemCount: books.length,
                              itemBuilder: (context, index) {
                                final book = books[index];
                                return Card(
                                  elevation: 6, // Daha şık bir gölge
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                            ),
                          );
                        },
                      );
                    }
                  },
                )
              : Center(
                  child: Text(
                      'Seçilen ekran boş.')), // Diğer ekranlarda içerik gösterme
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Seçili olan index
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map, size: 30), // Daha büyük harita ikonu
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
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Profil butonuna tıklanırsa Profil ekranına git
          if (_currentIndex == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          }
          // Harita butonuna tıklanırsa yeni bir ekran açılacak
          else if (_currentIndex == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MapScreen()), // Harita ekranına geçiş
            );
          }
        },
        selectedItemColor: Colors.blue, // Mavi seçili öğe
        unselectedItemColor: Colors.white, // Beyaz seçili olmayan öğeler
        backgroundColor: Colors.red, // Kırmızı arka plan
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
