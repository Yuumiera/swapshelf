import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _getCurrentUserName();
  }

  Future<void> _getCurrentUserName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _currentUserName = (userDoc.data() as Map<String, dynamic>)['name'];
        });
      }
    }
  }

  Future<void> _addBookToFirebase(String bookName, String authorName) async {
    if (_currentUserName == null) return;

    await _firestore.collection('library_books').add({
      'title': bookName,
      'authorName': authorName,
      'ownerName': _currentUserName,
      'description': '',
      'condition': 'New',
      'category': 'General',
      'tradeDate': DateTime.now().toString(),
      'userId': _auth.currentUser?.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> _getBooks() {
    return _firestore
        .collection('library_books')
        .orderBy('timestamp', descending: true)
        .snapshots();
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
                    return Center(child: Text('An error occurred!'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final books = snapshot.data!.docs;
                  if (books.isEmpty) {
                    return Center(
                      child: Text(
                        'No books added yet.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final bookData =
                          books[index].data() as Map<String, dynamic>;
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: Icon(Icons.book,
                              color: Colors.blueAccent, size: 40),
                          title: Text(
                            bookData['title'] ?? 'Untitled Book',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle:
                              Text(bookData['authorName'] ?? 'Unknown Author'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteBook(books[index].id);
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

  Future<void> _deleteBook(String bookId) async {
    await _firestore.collection('library_books').doc(bookId).delete();
  }

  Future<void> _showAddBookDialog() async {
    final TextEditingController _bookNameController = TextEditingController();
    final TextEditingController _authorNameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Add New Book",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _bookNameController,
              decoration: InputDecoration(labelText: 'Book Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _authorNameController,
              decoration: InputDecoration(labelText: 'Author Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
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
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}
