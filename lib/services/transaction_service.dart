import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:library_app_abp/services/book_service.dart';

// Model untuk Transaction
class TransactionModel {
  final String? id;
  final String userId;
  final String bookId;
  final Timestamp transactionDate;
  final Timestamp? returnDate;
  final String status; // 'borrowed' or 'returned'
  final String? bookTitle; // Optional field for UI display
  final String? userName; // Optional field for UI display

  TransactionModel({
    this.id,
    required this.userId,
    required this.bookId,
    required this.transactionDate,
    this.returnDate,
    required this.status,
    this.bookTitle,
    this.userName,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return TransactionModel(
      id: documentId,
      userId: map['user_id'] ?? '',
      bookId: map['book_id'] ?? '',
      transactionDate: map['transaction_date'] ?? Timestamp.now(),
      returnDate: map['return_date'],
      status: map['status'] ?? 'borrowed',
      bookTitle: map['book_title'],
      userName: map['user_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'book_id': bookId,
      'transaction_date': transactionDate,
      'return_date': returnDate,
      'status': status,
    };
  }
}

// Service untuk Transaction
class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final BookService _bookService = BookService();

  // Borrow a book
  Future<void> borrowBook(String bookId) async {
    try {
      // Get current user
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Check if book is available
      final book = await _bookService.getBookById(bookId);
      if (book == null) {
        throw Exception('Book not found');
      }

      if (book.stock <= 0) {
        throw Exception('Book is not available for borrowing');
      }

      // Start a batch write to ensure both operations succeed or fail together
      WriteBatch batch = _firestore.batch();

      // Create transaction document
      DocumentReference transactionRef = _firestore.collection('transactions').doc();
      batch.set(transactionRef, {
        'user_id': user.uid,
        'book_id': bookId,
        'transaction_date': FieldValue.serverTimestamp(),
        'return_date': null,
        'status': 'borrowed',
      });

      // Update book stock
      DocumentReference bookRef = _firestore.collection('books').doc(bookId);
      batch.update(bookRef, {
        'stock': FieldValue.increment(-1),
      });

      // Commit the batch
      await batch.commit();
    } catch (e) {
      print('Error borrowing book: $e');
      rethrow;
    }
  }

  // Return a book
  Future<void> returnBook(String transactionId) async {
    try {
      // Get the transaction
      DocumentSnapshot transactionDoc = await _firestore
          .collection('transactions')
          .doc(transactionId)
          .get();

      if (!transactionDoc.exists) {
        throw Exception('Transaction not found');
      }

      Map<String, dynamic> transactionData = transactionDoc.data() as Map<String, dynamic>;

      // Check if already returned
      if (transactionData['status'] == 'returned') {
        throw Exception('Book already returned');
      }

      String bookId = transactionData['book_id'];

      // Start a batch write
      WriteBatch batch = _firestore.batch();

      // Update transaction
      DocumentReference transactionRef = _firestore.collection('transactions').doc(transactionId);
      batch.update(transactionRef, {
        'return_date': FieldValue.serverTimestamp(),
        'status': 'returned',
      });

      // Update book stock
      DocumentReference bookRef = _firestore.collection('books').doc(bookId);
      batch.update(bookRef, {
        'stock': FieldValue.increment(1),
      });

      // Commit the batch
      await batch.commit();
    } catch (e) {
      print('Error returning book: $e');
      rethrow;
    }
  }

  // Get all transactions for current user
  Stream<List<TransactionModel>> getUserTransactions() {
    User? user = _auth.currentUser;
    if (user == null) {
      // Return empty list if no user logged in
      return Stream.value([]);
    }

    return _firestore
        .collection('transactions')
        .where('user_id', isEqualTo: user.uid)
        .snapshots()
        .asyncMap((snapshot) async {
      List<TransactionModel> transactions = [];

      for (var doc in snapshot.docs) {
        TransactionModel transaction = TransactionModel.fromMap(
          doc.data(),
          documentId: doc.id,
        );

        // Get book title for display
        try {
          final book = await _bookService.getBookById(transaction.bookId);
          if (book != null) {
            transactions.add(TransactionModel(
              id: transaction.id,
              userId: transaction.userId,
              bookId: transaction.bookId,
              transactionDate: transaction.transactionDate,
              returnDate: transaction.returnDate,
              status: transaction.status,
              bookTitle: book.title,
            ));
          } else {
            transactions.add(transaction);
          }
        } catch (e) {
          transactions.add(transaction);
        }
      }

      return transactions;
    });
  }

  // Get all transactions (for admin)
  Stream<List<TransactionModel>> getAllTransactions() {
    return _firestore
        .collection('transactions')
        .orderBy('transaction_date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TransactionModel.fromMap(
      doc.data(),
      documentId: doc.id,
    ))
        .toList());
  }

  // Get borrowed books that haven't been returned
  Stream<List<TransactionModel>> getBorrowedBooks() {
    return _firestore
        .collection('transactions')
        .where('status', isEqualTo: 'borrowed')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TransactionModel.fromMap(
      doc.data(),
      documentId: doc.id,
    ))
        .toList());
  }
}