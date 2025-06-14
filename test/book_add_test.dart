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

    // New mock tests
    test('Book model handles empty strings', () {
      final book = Book(
        id: 'test-id',
        title: '',
        authorName: '',
        description: '',
        condition: '',
        category: '',
        ownerName: '',
        userId: 'test-user-id',
      );

      expect(book.title, isEmpty);
      expect(book.authorName, isEmpty);
      expect(book.description, isEmpty);
      expect(book.condition, isEmpty);
      expect(book.category, isEmpty);
      expect(book.ownerName, isEmpty);
    });

    test('Book model handles special characters', () {
      final specialChars = 'Test Book!@#\$%^&*()';
      final book = Book(
        id: 'test-id',
        title: specialChars,
        authorName: specialChars,
        description: specialChars,
        condition: specialChars,
        category: specialChars,
        ownerName: specialChars,
        userId: 'test-user-id',
      );

      expect(book.title, equals(specialChars));
      expect(book.authorName, equals(specialChars));
      expect(book.description, equals(specialChars));
      expect(book.condition, equals(specialChars));
      expect(book.category, equals(specialChars));
      expect(book.ownerName, equals(specialChars));
    });

    test('Book model handles long text', () {
      final longText = 'a' * 1000;
      final book = Book(
        id: 'test-id',
        title: longText,
        authorName: longText,
        description: longText,
        condition: longText,
        category: longText,
        ownerName: longText,
        userId: 'test-user-id',
      );

      expect(book.title, equals(longText));
      expect(book.authorName, equals(longText));
      expect(book.description, equals(longText));
      expect(book.condition, equals(longText));
      expect(book.category, equals(longText));
      expect(book.ownerName, equals(longText));
    });

    test('Book model handles null values in JSON', () {
      final json = {
        'title': null,
        'authorName': null,
        'description': null,
        'condition': null,
        'category': null,
        'ownerName': null,
        'userId': 'test-user-id',
      };

      final book = Book.fromJson(json, id: 'test-id');
      expect(book.title, equals('Unknown Book'));
      expect(book.authorName, equals('Unknown Author'));
      expect(book.description, equals('No description'));
      expect(book.condition, equals('Unknown'));
      expect(book.category, equals('Other'));
      expect(book.ownerName, equals('Unknown Owner'));
    });
  });
} 