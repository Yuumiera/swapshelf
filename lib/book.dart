import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String title;
  final String ownerName;
  final String description;
  final String tradeDate;
  final String condition;
  final String category;
  final String authorName;
  final String? userId;

  Book({
    required this.title,
    required this.ownerName,
    required this.description,
    required this.tradeDate,
    required this.condition,
    required this.category,
    required this.authorName,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'ownerName': ownerName,
      'description': description,
      'tradeDate': tradeDate,
      'condition': condition,
      'category': category,
      'authorName': authorName,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(), // Firebase timestamp için
    };
  }

  static Book fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] ?? 'Unknown Book',
      ownerName: json['ownerName'] ?? 'Unknown Owner',
      description: json['description'] ?? 'No description',
      tradeDate: json['tradeDate'] ?? 'No date',
      condition: json['condition'] ?? 'Unknown',
      category: json['category'] ?? 'Other',
      authorName: json['authorName'] ?? 'Unknown Author',
      userId: json['userId'],
    );
  }
}
