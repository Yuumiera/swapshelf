import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String authorName;
  final String description;
  final String condition;
  final String category;
  final String ownerName;
  final String userId;
  final String? imageUrl;

  Book({
    required this.id,
    required this.title,
    required this.authorName,
    required this.description,
    required this.condition,
    required this.category,
    required this.ownerName,
    required this.userId,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'authorName': authorName,
      'description': description,
      'condition': condition,
      'category': category,
      'ownerName': ownerName,
      'userId': userId,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory Book.fromJson(Map<String, dynamic> json, {String? id}) {
    return Book(
      id: id ?? 'unknown',
      title: json['title'] ?? 'Unknown Book',
      authorName: json['authorName'] ?? 'Unknown Author',
      description: json['description'] ?? 'No description',
      condition: json['condition'] ?? 'Unknown',
      category: json['category'] ?? 'Other',
      ownerName: json['ownerName'] ?? 'Unknown Owner',
      userId: json['userId'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }
}
