import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book.dart';
import 'profile_screen.dart';
import 'widgets/gradient_app_bar.dart';
import 'widgets/gradient_bottom_navigation_bar.dart';
import 'exchange_screen.dart';
import 'widgets/book_detail_page.dart';
import 'chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'map_screen.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // Default tab: Home

  Widget _buildHomeScreen() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('library_books')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Bir hata oluştu!',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final books = snapshot.data!.docs.map((doc) {
          return Book.fromJson(doc.data() as Map<String, dynamic>, id: doc.id);
        }).toList();

        if (books.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.library_books_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'Henüz kitap eklenmedi.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailPage(book: book),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kitap Kapağı
                      Expanded(
                        flex: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: book.imageUrl != null
                                ? book.imageUrl!.startsWith('data:image')
                                    ? Image.memory(
                                        base64Decode(
                                            book.imageUrl!.split(',')[1]),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      )
                                    : Image.network(
                                        book.imageUrl!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      )
                                : Icon(
                                    Icons.book,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                          ),
                        ),
                      ),
                      // Kitap Bilgileri
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                book.authorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Spacer(),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: Color(0xFF1E88E5),
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      book.ownerName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _addToExchanges(Book book) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please login to add books to exchanges')),
        );
        return;
      }

      if (book.userId == user.uid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You cannot exchange your own book')),
        );
        return;
      }

      final existingExchange = await FirebaseFirestore.instance
          .collection('exchanges')
          .where('bookTitle', isEqualTo: book.title)
          .where('requesterId', isEqualTo: user.uid)
          .get();

      if (existingExchange.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This book is already in your exchanges')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('exchanges').add({
        'bookTitle': book.title,
        'bookAuthor': book.authorName,
        'ownerId': book.userId,
        'ownerName': book.ownerName,
        'requesterId': user.uid,
        'requesterName': user.displayName ?? 'Anonymous',
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'description': book.description,
        'condition': book.condition,
        'category': book.category,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book added to exchanges successfully!')),
      );
    } catch (e) {
      print('Error adding to exchanges: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add book to exchanges')),
      );
    }
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return MapScreen();
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

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Map';
      case 1:
        return 'Exchanges';
      case 2:
        return 'Home';
      case 3:
        return 'Messages';
      case 4:
        return 'Profile';
      default:
        return 'Home';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: _getTitle()),
      body: SafeArea(child: _getBody()),
      bottomNavigationBar: GradientBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz), label: 'Exchanges'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _showAddBookDialog() async {
    final TextEditingController _bookNameController = TextEditingController();
    final TextEditingController _authorNameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Yeni Kitap Ekle",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _bookNameController,
              decoration: InputDecoration(labelText: 'Kitap Adı'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _authorNameController,
              decoration: InputDecoration(labelText: 'Yazar Adı'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_bookNameController.text.isNotEmpty &&
                  _authorNameController.text.isNotEmpty) {
                await _addBookToFirebase(
                    _bookNameController.text, _authorNameController.text);
                Navigator.pop(context);
              }
            },
            child: Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Future<void> _addBookToFirebase(String bookName, String authorName) async {
    await _firestore.collection('library_books').add({
      'title': bookName,
      'authorName': authorName,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> _getBooks() {
    return _firestore
        .collection('library_books')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _deleteBook(String bookId) async {
    await _firestore.collection('library_books').doc(bookId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Library"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: StreamBuilder<QuerySnapshot>(
                stream: _getBooks(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Bir hata oluştu!'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final books = snapshot.data!.docs;
                  if (books.isEmpty) {
                    return Center(
                      child: Text(
                        'Henüz kitap eklenmedi.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final bookData = books[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: Icon(Icons.book,
                              color: Colors.blueAccent, size: 40),
                          title: Text(
                            bookData['title'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text(bookData['authorName'] ?? ''),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteBook(bookData.id);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            height: screenHeight * 0.08,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: screenHeight * 0.07),
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: _showAddBookDialog,
          child: Icon(Icons.add, size: 28, color: Colors.white),
        ),
      ),
    );
  }
}
