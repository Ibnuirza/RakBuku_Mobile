import 'package:cloud_firestore/cloud_firestore.dart';

// Model untuk Book
class BookModel {
  final String? id;
  final String title;
  final String author;
  final int stock;
  final String? description;
  final Timestamp? createdAt;

  BookModel({
    this.id,
    required this.title,
    required this.author,
    required this.stock,
    this.description,
    this.createdAt,
  });

  factory BookModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return BookModel(
      id: documentId,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      stock: map['stock'] ?? 0,
      description: map['description'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'stock': stock,
      'description': description,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

// Service untuk Book
class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add new book
  Future<void> addBook(String title, String author, int stock, {String? description}) async {
    try {
      await _firestore.collection('books').add({
        'title': title,
        'author': author,
        'stock': stock,
        'description': description,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding book: $e');
      rethrow;
    }
  }

  // Update book
  Future<void> updateBook(String bookId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('books').doc(bookId).update(data);
    } catch (e) {
      print('Error updating book: $e');
      rethrow;
    }
  }

  // Delete book
  Future<void> deleteBook(String bookId) async {
    try {
      await _firestore.collection('books').doc(bookId).delete();
    } catch (e) {
      print('Error deleting book: $e');
      rethrow;
    }
  }

  // Get all books
  Stream<List<BookModel>> getAllBooks() {
    return _firestore
        .collection('books')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => BookModel.fromMap(
      doc.data(),
      documentId: doc.id,
    ))
        .toList());
  }

  // Get book by ID
  Future<BookModel?> getBookById(String bookId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('books').doc(bookId).get();

      if (doc.exists) {
        return BookModel.fromMap(
            doc.data() as Map<String, dynamic>,
            documentId: doc.id
        );
      }
      return null;
    } catch (e) {
      print('Error getting book: $e');
      return null;
    }
  }

  // Search books by title or author
  Stream<List<BookModel>> searchBooks(String query) {
    // Create a lowercase version of the query for case-insensitive search
    String lowercaseQuery = query.toLowerCase();

    return _firestore
        .collection('books')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookModel.fromMap(
        doc.data(),
        documentId: doc.id,
      ))
          .where((book) {
        return book.title.toLowerCase().contains(lowercaseQuery) ||
            book.author.toLowerCase().contains(lowercaseQuery);
      })
          .toList();
    });
  }

  // Update book stock
  Future<void> updateBookStock(String bookId, int change) async {
    try {
      await _firestore.collection('books').doc(bookId).update({
        'stock': FieldValue.increment(change),
      });
    } catch (e) {
      print('Error updating book stock: $e');
      rethrow;
    }
  }
}