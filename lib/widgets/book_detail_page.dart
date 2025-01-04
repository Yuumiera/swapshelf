import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../book.dart';
import 'package:swapshelfproje/message_to_person_screen.dart';
import 'dart:convert';

class BookDetailPage extends StatefulWidget {
  final Book book;

  const BookDetailPage({Key? key, required this.book}) : super(key: key);

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
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
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists && mounted) {
        setState(() {
          _currentUserName = (userDoc.data() as Map<String, dynamic>)['name'];
        });
      }
    }
  }

  Future<void> _sendExchangeRequest(BuildContext context) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please login to request exchange')),
        );
        return;
      }

      // Kendi kitabını takas etmeyi engelle
      if (widget.book.userId == currentUser.uid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You cannot exchange your own book')),
        );
        return;
      }

      // Mevcut bir istek var mı kontrol et
      final existingRequest = await FirebaseFirestore.instance
          .collection('exchanges')
          .where('requesterId', isEqualTo: currentUser.uid)
          .where('bookTitle', isEqualTo: widget.book.title)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequest.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('You already have a pending request for this book')),
        );
        return;
      }

      // Yeni takas isteği oluştur
      await FirebaseFirestore.instance.collection('exchanges').add({
        'requesterId': currentUser.uid,
        'requesterName': _currentUserName ?? 'Anonymous',
        'ownerId': widget.book.userId,
        'ownerName': widget.book.ownerName,
        'bookTitle': widget.book.title,
        'bookAuthor': widget.book.authorName,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'description': widget.book.description,
        'condition': widget.book.condition,
        'category': widget.book.category,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exchange request sent successfully!')),
      );
    } catch (e) {
      print('Error sending exchange request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send exchange request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwnBook = widget.book.userId == _auth.currentUser?.uid;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            Container(
              height: size.height * 0.5,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE53935),
                    Color(0xFF1E88E5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Kitap kapağı
                      Container(
                        width: size.width * 0.4,
                        height: size.width * 0.55,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (widget.book.imageUrl != null &&
                                widget.book.imageUrl!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: widget.book.imageUrl!
                                        .startsWith('data:image')
                                    ? Image.memory(
                                        base64Decode(widget.book.imageUrl!
                                            .split(',')[1]),
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        widget.book.imageUrl!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                              )
                            else
                              Icon(
                                Icons.book,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      // Kitap bilgileri
                      Text(
                        widget.book.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'by ${widget.book.authorName}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Detaylar
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailCard(
                    title: 'Book Details',
                    content: Column(
                      children: [
                        _buildDetailRow(
                          icon: Icons.category,
                          title: 'Category',
                          value: widget.book.category,
                        ),
                        Divider(height: 24),
                        _buildDetailRow(
                          icon: Icons.star,
                          title: 'Condition',
                          value: widget.book.condition,
                        ),
                        Divider(height: 24),
                        _buildDetailRow(
                          icon: Icons.description,
                          title: 'Description',
                          value: widget.book.description,
                          isDescription: true,
                        ),
                      ],
                    ),
                  ),
                  if (!isOwnBook) ...[
                    SizedBox(height: 20),
                    _buildDetailCard(
                      title: 'Book Owner',
                      content: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                widget.book.ownerName[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(widget.book.ownerName),
                            subtitle: Text('Book Owner'),
                          ),
                          SizedBox(height: 16),
                          _buildActionButton(
                            icon: Icons.message,
                            label: 'Send Message',
                            color: Colors.blue,
                            onPressed: () async {
                              if (widget.book.userId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MessageToPersonScreen(
                                      recipientName: widget.book.ownerName,
                                      currentUserName:
                                          _currentUserName ?? 'Anonymous',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          SizedBox(height: 12),
                          _buildActionButton(
                            icon: Icons.swap_horiz,
                            label: 'Request Exchange',
                            color: Colors.green,
                            onPressed: () => _sendExchangeRequest(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({required String title, required Widget content}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    bool isDescription = false,
  }) {
    return Row(
      crossAxisAlignment:
          isDescription ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.blue),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
