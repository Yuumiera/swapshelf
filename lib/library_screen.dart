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

  Future<void> _checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.status.isDenied ||
          await Permission.photos.status.isDenied ||
          await Permission.camera.status.isDenied) {
        await [
          Permission.storage,
          Permission.photos,
          Permission.camera,
          Permission.mediaLibrary,
        ].request();
      }

      // Android 13+ için özel izinler
      if (int.parse(await DeviceInfoPlugin()
              .androidInfo
              .then((value) => value.version.release)) >=
          13) {
        await Permission.photos.request();
        await Permission.videos.request();
        await Permission.audio.request();
      }
    }
  }

  Future<void> _pickImage(ImageSource source, StateSetter setState) async {
    try {
      await _checkAndRequestPermissions(); // İzinleri kontrol et

      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
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

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add New Book'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedImage != null)
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: FileImage(selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      // Önce izinleri kontrol et
                      Map<Permission, PermissionStatus> statuses = await [
                        Permission.storage,
                        Permission.photos,
                        Permission.camera,
                      ].request();

                      bool allGranted = true;
                      statuses.forEach((permission, status) {
                        if (!status.isGranted) allGranted = false;
                      });

                      if (allGranted) {
                        final picker = ImagePicker();
                        // Fotoğraf seçme dialogu göster
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Select Image Source'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    GestureDetector(
                                      child: Text('Gallery'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickImage(
                                            ImageSource.gallery, setState);
                                      },
                                    ),
                                    Padding(padding: EdgeInsets.all(8.0)),
                                    GestureDetector(
                                      child: Text('Camera'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickImage(
                                            ImageSource.camera, setState);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Please grant all required permissions'),
                            action: SnackBarAction(
                              label: 'Settings',
                              onPressed: () => openAppSettings(),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      print('Error picking image: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to pick image: $e')),
                      );
                    }
                  },
                  icon: Icon(Icons.photo_library),
                  label: Text('Select Image'),
                ),
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
                if (titleController.text.isNotEmpty) {
                  String? imageUrl;
                  if (selectedImage != null) {
                    // Resmi base64'e çevir
                    final bytes = await selectedImage!.readAsBytes();
                    imageUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                  }

                  await _firestore.collection('library_books').add({
                    'title': titleController.text.trim(),
                    'authorName': authorController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'condition': selectedCondition,
                    'category': selectedCategory,
                    'ownerName': _currentUserName,
                    'userId': _auth.currentUser?.uid,
                    'imageUrl': imageUrl,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Book added successfully!')),
                  );
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
  Future<void> _showEditBookDialog(BuildContext context, String bookId,
      Map<String, dynamic> bookData) async {
    final titleController = TextEditingController(text: bookData['title']);
    final authorController =
        TextEditingController(text: bookData['authorName']);
    final descriptionController =
        TextEditingController(text: bookData['description']);
    String selectedCondition = bookData['condition'] ?? _conditions[0];
    String selectedCategory = bookData['category'] ?? _categories[0];

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Book'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                builder: (context, setState) => DropdownButtonFormField<String>(
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
                builder: (context, setState) => DropdownButtonFormField<String>(
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
                  authorController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty) {
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
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all required fields')),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
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
        title: Text('My Library'),
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
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _showDeleteConfirmation(context, books[index].id),
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
