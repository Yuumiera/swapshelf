import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:device_info_plus/device_info_plus.dart';

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentUserName;
  File? selectedImage;
  String? imageBase64;

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
    _getCurrentUserName(); // TODO: Bu metodu tanımlamak gerekiyor
  }

  Future<void> _getCurrentUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _currentUserName = userDoc.data()?['name'];
      });
    }
  }

  Future<bool> _checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      // Android 13 ve üzeri için API seviyesini kontrol et
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final androidVersion = int.parse(androidInfo.version.release);

      if (androidVersion >= 13) {
        // Android 13+ için özel izinler
        final photos = await Permission.photos.request();
        final videos = await Permission.videos.request();

        if (photos.isDenied || videos.isDenied) {
          _showPermissionDialog();
          return false;
        }
      } else {
        // Android 13 öncesi için izinler
        final storage = await Permission.storage.request();
        final camera = await Permission.camera.request();

        if (storage.isDenied || camera.isDenied) {
          _showPermissionDialog();
          return false;
        }
      }
      return true;
    }
    return true;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('İzin Gerekli'),
        content: Text(
            'Resim ekleyebilmek için gerekli izinleri vermeniz gerekmektedir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: Text('Ayarları Aç'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(StateSetter setState) async {
    try {
      final hasPermission = await _checkAndRequestPermissions();
      if (!hasPermission) return;

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          selectedImage = File(image.path);
          imageBase64 = base64Image;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resim seçilirken bir hata oluştu')),
      );
    }
  }

  // Kitap ekleme dialog'u
  Future<void> _showAddBookDialog() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController authorController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedCondition = _conditions[0];
    String selectedCategory = _categories[0];
    selectedImage = null;
    imageBase64 = null;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add New Book'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Resim seçme butonu
                ElevatedButton.icon(
                  onPressed: () => _pickImage(setState),
                  icon: Icon(Icons.photo_library),
                  label: Text('Select Image'),
                ),
                if (selectedImage != null) ...[
                  SizedBox(height: 10),
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.file(
                      selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Book Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: authorController,
                  decoration: InputDecoration(
                    labelText: 'Author',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) =>
                      DropdownButtonFormField<String>(
                    value: selectedCondition,
                    decoration: InputDecoration(
                      labelText: 'Condition',
                      border: OutlineInputBorder(),
                    ),
                    items: _conditions.map((String condition) {
                      return DropdownMenuItem(
                        value: condition,
                        child: Text(condition),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() => selectedCondition = value);
                      }
                    },
                  ),
                ),
                SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) =>
                      DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() => selectedCategory = value);
                      }
                    },
                  ),
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
                if (titleController.text.isNotEmpty &&
                    authorController.text.isNotEmpty) {
                  try {
                    await _firestore.collection('library_books').add({
                      'title': titleController.text.trim(),
                      'authorName': authorController.text.trim(),
                      'description': descriptionController.text.trim(),
                      'condition': selectedCondition,
                      'category': selectedCategory,
                      'ownerName': _currentUserName,
                      'userId': _auth.currentUser?.uid,
                      'imageUrl': imageBase64,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Book added successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding book: $e')),
                    );
                  }
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  // Kitap düzenleme dialog'u
  Future<void> _showEditBookDialog(
    BuildContext context,
    String bookId,
    Map<String, dynamic> bookData,
  ) async {
    final titleController = TextEditingController(text: bookData['title']);
    final authorController =
        TextEditingController(text: bookData['authorName']);
    final descriptionController =
        TextEditingController(text: bookData['description']);
    String selectedCondition = bookData['condition'] ?? _conditions[0];
    String selectedCategory = bookData['category'] ?? _categories[0];
    selectedImage = null;
    imageBase64 = bookData['imageUrl'];

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Book'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(setState),
                  icon: Icon(Icons.photo_library),
                  label: Text('Select Image'),
                ),
                if (selectedImage != null) ...[
                  SizedBox(height: 10),
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.file(
                      selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ] else if (imageBase64 != null) ...[
                  SizedBox(height: 10),
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: imageBase64!.startsWith('data:image')
                        ? Image.memory(
                            base64Decode(imageBase64!.split(',')[1]),
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            imageBase64!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ],
                SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Book Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: authorController,
                  decoration: InputDecoration(
                    labelText: 'Author',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCondition,
                  decoration: InputDecoration(
                    labelText: 'Condition',
                    border: OutlineInputBorder(),
                  ),
                  items: _conditions.map((String condition) {
                    return DropdownMenuItem(
                      value: condition,
                      child: Text(condition),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() => selectedCondition = value);
                    }
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() => selectedCategory = value);
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
                if (titleController.text.isNotEmpty &&
                    authorController.text.isNotEmpty) {
                  try {
                    await _firestore
                        .collection('library_books')
                        .doc(bookId)
                        .update({
                      'title': titleController.text.trim(),
                      'authorName': authorController.text.trim(),
                      'description': descriptionController.text.trim(),
                      'condition': selectedCondition,
                      'category': selectedCategory,
                      'imageUrl': selectedImage != null
                          ? imageBase64
                          : bookData['imageUrl'],
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Book updated successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating book: $e')),
                    );
                  }
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('My Library')),
        body: Center(child: Text('Please login to view your library')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Library',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Sadece giriş yapmış kullanıcının kitaplarını getir
        stream: _firestore
            .collection('library_books')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data?.docs ?? [];

          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No books in your library yet'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showAddBookDialog,
                    child: Text('Add Your First Book'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final bookData = books[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Container(
                    width: 70,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey[200],
                    ),
                    child: bookData['imageUrl'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: bookData['imageUrl'].startsWith('data:image')
                                ? Image.memory(
                                    base64Decode(
                                        bookData['imageUrl'].split(',')[1]),
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    bookData['imageUrl'],
                                    fit: BoxFit.cover,
                                  ),
                          )
                        : Icon(Icons.book, color: Colors.blueAccent, size: 40),
                  ),
                  title: Text(
                    bookData['title'] ?? 'Unknown Book',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Author: ${bookData['authorName'] ?? 'Unknown Author'}'),
                      Text('Condition: ${bookData['condition'] ?? 'Unknown'}'),
                      Text('Category: ${bookData['category'] ?? 'Unknown'}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditBookDialog(
                          context,
                          books[index].id,
                          bookData,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _showDeleteConfirmation(context, books[index].id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBookDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Silme onayı dialog'u
  Future<void> _showDeleteConfirmation(BuildContext context, String bookId) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Book'),
        content: Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _firestore
                    .collection('library_books')
                    .doc(bookId)
                    .delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Book deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting book: $e')),
                );
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
