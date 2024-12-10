import 'package:flutter/material.dart';
import 'package:swapshelfproje/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookAddForm extends StatefulWidget {
  final VoidCallback onBookAdded;

  const BookAddForm({Key? key, required this.onBookAdded}) : super(key: key);

  @override
  _BookAddFormState createState() => _BookAddFormState();
}

class _BookAddFormState extends State<BookAddForm> {
  final _formKey = GlobalKey<FormState>();
  late String _title,
      _imageUrl,
      _ownerName,
      _description,
      _tradeDate,
      _condition,
      _category;

  Future<void> _addBookToFirestore() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Book newBook = Book(
        title: _title,
        imageUrl: _imageUrl,
        ownerName: _ownerName,
        description: _description,
        tradeDate: _tradeDate,
        condition: _condition,
        category: _category,
      );

      await FirebaseFirestore.instance
          .collection('books')
          .add(newBook.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kitap başarıyla eklendi!')),
      );

      widget.onBookAdded(); // Ana sayfadaki kitapları yenilemek için
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Yeni Kitap Ekle"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Kitap İsmi"),
                onSaved: (value) => _title = value!,
                validator: (value) =>
                    value!.isEmpty ? "Bu alan zorunludur" : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Görsel URL"),
                onSaved: (value) => _imageUrl = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Takas Yapan Kişi"),
                onSaved: (value) => _ownerName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Açıklama"),
                onSaved: (value) => _description = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Takas Tarihi"),
                onSaved: (value) => _tradeDate = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Durum"),
                onSaved: (value) => _condition = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Kategori"),
                onSaved: (value) => _category = value!,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("İptal"),
        ),
        ElevatedButton(
          onPressed: _addBookToFirestore,
          child: Text("Ekle"),
        ),
      ],
    );
  }
}
