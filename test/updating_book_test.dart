import 'package:flutter_test/flutter_test.dart';
import 'package:swapshelfproje/book.dart';

void main() {
  group('Updating a Book', () {
    test('Book fields are updated correctly', () {
      final originalBook = Book(
        id: '1',
        title: 'Original Title',
        authorName: 'Original Author',
        description: 'Original Description',
        condition: 'Used',
        category: 'Non-Fiction',
        ownerName: 'Original Owner',
        userId: 'user123',
      );

      final updatedBook = Book(
        id: originalBook.id,
        title: 'Updated Title',
        authorName: 'Updated Author',
        description: 'Updated Description',
        condition: 'New',
        category: 'Fiction',
        ownerName: 'Updated Owner',
        userId: 'user456',
      );

      expect(updatedBook.id, equals(originalBook.id));
      expect(updatedBook.title, equals('Updated Title'));
      expect(updatedBook.authorName, equals('Updated Author'));
      expect(updatedBook.description, equals('Updated Description'));
      expect(updatedBook.condition, equals('New'));
      expect(updatedBook.category, equals('Fiction'));
      expect(updatedBook.ownerName, equals('Updated Owner'));
      expect(updatedBook.userId, equals('user456'));
    });
  });
} 