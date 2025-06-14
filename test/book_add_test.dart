import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swapshelfproje/book.dart';
import 'package:swapshelfproje/widgets/book_add_button.dart';

void main() {
  group('Book Model Tests', () {
    test('Book model creates correct JSON', () {
      final book = Book(
        id: 'test-id',
        title: 'Test Book',
        authorName: 'Test Author',
        description: 'Test Description',
        condition: 'New',
        category: 'Fiction',
        ownerName: 'Test Owner',
        userId: 'test-user-id',
      );

      final json = book.toJson();
      expect(json['title'], equals('Test Book'));
      expect(json['authorName'], equals('Test Author'));
      expect(json['description'], equals('Test Description'));
      expect(json['condition'], equals('New'));
      expect(json['category'], equals('Fiction'));
      expect(json['ownerName'], equals('Test Owner'));
      expect(json['userId'], equals('test-user-id'));
    });

    test('Book model creates from JSON correctly', () {
      final json = {
        'title': 'Test Book',
        'authorName': 'Test Author',
        'description': 'Test Description',
        'condition': 'New',
        'category': 'Fiction',
        'ownerName': 'Test Owner',
        'userId': 'test-user-id',
      };

      final book = Book.fromJson(json, id: 'test-id');
      expect(book.id, equals('test-id'));
      expect(book.title, equals('Test Book'));
      expect(book.authorName, equals('Test Author'));
      expect(book.description, equals('Test Description'));
      expect(book.condition, equals('New'));
      expect(book.category, equals('Fiction'));
      expect(book.ownerName, equals('Test Owner'));
      expect(book.userId, equals('test-user-id'));
    });

    test('Book model handles missing optional fields', () {
      final json = {
        'title': 'Test Book',
        'authorName': 'Test Author',
        'userId': 'test-user-id',
      };

      final book = Book.fromJson(json, id: 'test-id');
      expect(book.id, equals('test-id'));
      expect(book.title, equals('Test Book'));
      expect(book.authorName, equals('Test Author'));
      expect(book.description, equals('No description'));
      expect(book.condition, equals('Unknown'));
      expect(book.category, equals('Other'));
      expect(book.ownerName, equals('Unknown Owner'));
      expect(book.userId, equals('test-user-id'));
    });
  });
} 