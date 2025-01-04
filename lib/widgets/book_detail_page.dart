import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../book.dart';
import '../screens/message_to_person.dart';
import 'dart:convert';

class BookDetailPage extends StatelessWidget {
  final Book book;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  BookDetailPage({required this.book});

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
      if (book.userId == currentUser.uid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You cannot exchange your own book')),
        );
        return;
      }

      // Mevcut bir istek var mı kontrol et
      final existingRequest = await FirebaseFirestore.instance
          .collection('exchanges')
          .where('requesterId', isEqualTo: currentUser.uid)
          .where('bookTitle', isEqualTo: book.title)
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
        'requesterName': currentUser.displayName ?? 'Anonymous',
        'ownerId': book.userId,
        'ownerName': book.ownerName,
        'bookTitle': book.title,
        'bookAuthor': book.authorName,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'description': book.description,
        'condition': book.condition,
        'category': book.category,
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
    final bool isOwnBook = book.userId == _auth.currentUser?.uid;
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
                            if (book.imageUrl != null &&
                                book.imageUrl!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: book.imageUrl!.startsWith('data:image')
                                    ? Image.memory(
                                        base64Decode(
                                            book.imageUrl!.split(',')[1]),
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        book.imageUrl!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Center(
                                            child: Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                          );
                                        },
                                      ),
                              )
                            else
                              Icon(
                                Icons.book,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                            if (isOwnBook)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFE53935),
                                        Color(0xFF1E88E5),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Your Book',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      // Kitap bilgileri
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            // Kitap ismi
                            Text(
                              book.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 12),
                            // Yazar ismi
                            Text(
                              'by ${book.authorName}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Detay kartları
            Transform.translate(
              offset: Offset(0, -30),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kitap detayları kartı
                      _buildDetailCard(
                        title: 'Book Details',
                        content: Column(
                          children: [
                            _buildDetailRow(
                              icon: Icons.category,
                              title: 'Category',
                              value: book.category,
                            ),
                            Divider(height: 24),
                            _buildDetailRow(
                              icon: Icons.star,
                              title: 'Condition',
                              value: book.condition,
                            ),
                            Divider(height: 24),
                            _buildDetailRow(
                              icon: Icons.description,
                              title: 'Description',
                              value: book.description,
                              isDescription: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      // Kitap sahibi kartı ve butonlar
                      if (!isOwnBook) ...[
                        _buildDetailCard(
                          title: 'Book Owner',
                          content: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.blue,
                                      size: 28,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.ownerName,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Book Owner',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              _buildActionButton(
                                icon: Icons.message_rounded,
                                label: 'Send Message',
                                color: Colors.blue,
                                onPressed: () {
                                  if (book.userId != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MessageToPerson(
                                          recipientId: book.userId!,
                                          recipientName: book.ownerName,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Cannot send message at this time'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              ),
                              SizedBox(height: 12),
                              _buildActionButton(
                                icon: Icons.swap_horiz_rounded,
                                label: 'Request Exchange',
                                color: Colors.green,
                                onPressed: () => _sendExchangeRequest(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
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
        Icon(icon, size: 20, color: Colors.blue),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
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
