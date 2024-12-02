import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'profile_screen.dart'; // Profil ekranı için import
import 'package:swapshelfproje/widgets/gradient_app_bar.dart'; // GradientAppBar import
import 'package:swapshelfproje/widgets/gradient_bottom_navigation_bar.dart'; // GradientBottomNavigationBar import

// Örnek kitap modeli
class Book {
  final String title;
  final String imageUrl;

  Book({required this.title, required this.imageUrl});
}

// HomeBackground widget for a minimalist white background
class HomeBackground extends StatelessWidget {
  final Widget child;

  HomeBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Container(
      width: screenWidth,
      height: screenHeight,
      decoration: BoxDecoration(
        color: Colors.white, // White background
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(30.0)), // Rounded top corners
        child: child,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // Set default tab index to 2 (Home)

  // Sample book data fetching function
  Future<List<Book>> fetchBooks() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate loading time
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
      appBar: GradientAppBar(
        // Using the custom gradient app bar
        title: 'Ana Sayfa', // Title of the app bar
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              // Filter functionality can be added here
            },
          ),
        ],
      ),
      body: SafeArea(
        child: HomeBackground(
          child: _currentIndex == 2 // Show books when Home tab is selected
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
                            thickness: 8.0, // Scroll bar thickness
                            radius: Radius.circular(8.0), // Rounded corners
                            thumbVisibility: true, // Always visible scroll bar
                            child: GridView.builder(
                              padding: EdgeInsets.all(12.0),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12.0,
                                mainAxisSpacing: 12.0,
                                childAspectRatio: 0.8, // Taller book cards
                              ),
                              itemCount: books.length,
                              itemBuilder: (context, index) {
                                final book = books[index];
                                return Card(
                                  elevation: 6, // More elegant shadow
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
                  child:
                      Text('Seçilen ekran boş.')), // Placeholder for other tabs
        ),
      ),
      bottomNavigationBar: GradientBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Navigate to Profile screen if selected
          if (_currentIndex == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          }
          // Navigate to Map screen if selected
          else if (_currentIndex == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapScreen()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map, size: 30), // Larger map icon
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
