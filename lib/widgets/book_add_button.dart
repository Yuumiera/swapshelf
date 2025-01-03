import 'package:flutter/material.dart';
import 'package:swapshelfproje/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookAddForm extends StatefulWidget {
  final VoidCallback onBookAdded;

  const BookAddForm({Key? key, required this.onBookAdded}) : super(key: key);

  @override
  _BookAddFormState createState() => _BookAddFormState();
}

class _BookAddFormState extends State<BookAddForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserName;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentUserName();
  }

  Future<void> _getCurrentUserName() async {
    try {
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
    } catch (e) {
      print('Error getting user name: $e');
    }
  }

  Future<void> _addBookToFirestore() async {
    if (_formKey.currentState!.validate()) {
      if (_currentUserName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Kullanıcı bilgisi alınamadı. Lütfen tekrar deneyin.')),
        );
        return;
      }

      try {
        final book = Book(
          title: _titleController.text.trim(),
          authorName: _authorController.text.trim(),
          ownerName: _currentUserName!,
          description: _descriptionController.text.trim(),
          tradeDate: DateTime.now().toString(),
          condition: _conditionController.text.trim().isNotEmpty
              ? _conditionController.text.trim()
              : 'New',
          category: _categoryController.text.trim().isNotEmpty
              ? _categoryController.text.trim()
              : 'General',
          userId: _auth.currentUser?.uid,
        );

        await _firestore.collection('library_books').add(book.toJson());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kitap başarıyla eklendi!')),
        );

        widget.onBookAdded();
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata oluştu: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _conditionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add New Book"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Book Name"),
                validator: (value) =>
                    value?.trim().isEmpty == true ? "Bu alan zorunludur" : null,
              ),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(labelText: "Author"),
                validator: (value) =>
                    value?.trim().isEmpty == true ? "Bu alan zorunludur" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              TextFormField(
                controller: _conditionController,
                decoration:
                    InputDecoration(labelText: "Condition (New/Good/Fair)"),
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: "Category"),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _addBookToFirestore,
          child: Text("Add"),
        ),
      ],
    );
  }
}
