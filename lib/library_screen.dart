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
  final List<String> _conditions = ['New', 'Like New', 'Good', 'Fair', 'Poor'];
  final List<String> _categories = [
    'Fiction',
    'Non-Fiction',
    'Science',
    'History',
    'Literature',
    'Technology',
    'Art',
    'Biography',
    'Other'
  ];

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

  Future<void> _addBookToFirebase(String bookName, String authorName,
      String description, String condition, String category) async {
    if (_currentUserName == null) return;

    await _firestore.collection('library_books').add({
      'title': bookName,
      'authorName': authorName,
      'description': description,
      'ownerName': _currentUserName,
      'condition': condition,
      'category': category,
      'tradeDate': DateTime.now().toString(),
      'userId': _auth.currentUser?.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _editBook(
      String bookId, Map<String, dynamic> currentData) async {
    final TextEditingController _bookNameController =
        TextEditingController(text: currentData['title']);
    final TextEditingController _authorNameController =
        TextEditingController(text: currentData['authorName']);
    final TextEditingController _descriptionController =
        TextEditingController(text: currentData['description']);

    // Mevcut değerleri kontrol et ve varsayılan değerler ata
    String _selectedCondition = currentData['condition'];
    if (!_conditions.contains(_selectedCondition)) {
      _selectedCondition =
          _conditions[0]; // Eğer mevcut durum listede yoksa ilk değeri kullan
    }

    String _selectedCategory = currentData['category'];
    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = _categories[
          0]; // Eğer mevcut kategori listede yoksa ilk değeri kullan
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Book"),
        content: SingleChildScrollView(
          child: Column(
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
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              StatefulBuilder(
                // StatefulBuilder ekleyerek dropdown değişikliklerini yönetiyoruz
                builder: (context, setState) {
                  return DropdownButtonFormField<String>(
                    value: _selectedCondition,
                    decoration: InputDecoration(
                      labelText: 'Condition',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    dropdownColor: Colors.white,
                    style: TextStyle(color: Colors.black),
                    items: _conditions.map((String condition) {
                      return DropdownMenuItem(
                        value: condition,
                        child: Text(
                          condition,
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCondition = newValue;
                        });
                      }
                    },
                  );
                },
              ),
              SizedBox(height: 10),
              StatefulBuilder(
                // StatefulBuilder ekleyerek dropdown değişikliklerini yönetiyoruz
                builder: (context, setState) {
                  return DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    dropdownColor: Colors.white,
                    style: TextStyle(color: Colors.black),
                    items: _categories.map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_bookNameController.text.isNotEmpty &&
                  _authorNameController.text.isNotEmpty &&
                  _descriptionController.text.isNotEmpty) {
                await _firestore
                    .collection('library_books')
                    .doc(bookId)
                    .update({
                  'title': _bookNameController.text,
                  'authorName': _authorNameController.text,
                  'description': _descriptionController.text,
                  'condition': _selectedCondition,
                  'category': _selectedCategory,
                });
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
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
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(bookData['authorName'] ?? 'Unknown Author'),
                              Text('Condition: ${bookData['condition']}'),
                              Text('Category: ${bookData['category']}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    _editBook(books[index].id, bookData),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteBook(books[index].id);
                                },
                              ),
                            ],
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
    // Onay dialogu göster
    bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Delete Book'),
              content: Text('Are you sure you want to delete this book?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false; // Dialog kapatılırsa false döner

    // Kullanıcı onaylarsa silme işlemini gerçekleştir
    if (confirmDelete) {
      await _firestore.collection('library_books').doc(bookId).delete();

      // Opsiyonel: Silme işlemi başarılı olduğunda bir snackbar göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book deleted successfully')),
        );
      }
    }
  }

  Future<void> _showAddBookDialog() async {
    final TextEditingController _bookNameController = TextEditingController();
    final TextEditingController _authorNameController = TextEditingController();
    final TextEditingController _descriptionController =
        TextEditingController();
    String _selectedCondition = _conditions[0];
    String _selectedCategory = _categories[0];

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Add New Book",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
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
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                decoration: InputDecoration(
                  labelText: 'Condition',
                  filled: true,
                  fillColor: Colors.white,
                ),
                dropdownColor: Colors.white,
                style: TextStyle(color: Colors.black),
                items: _conditions.map((String condition) {
                  return DropdownMenuItem(
                    value: condition,
                    child: Text(
                      condition,
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _selectedCondition = newValue;
                  }
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: Colors.white,
                ),
                dropdownColor: Colors.white,
                style: TextStyle(color: Colors.black),
                items: _categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _selectedCategory = newValue;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_bookNameController.text.isNotEmpty &&
                  _authorNameController.text.isNotEmpty &&
                  _descriptionController.text.isNotEmpty) {
                await _addBookToFirebase(
                  _bookNameController.text,
                  _authorNameController.text,
                  _descriptionController.text,
                  _selectedCondition,
                  _selectedCategory,
                );
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
