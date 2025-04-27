import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Halaman pengguna untuk mencari buku yang tersedia dengan Firebase

class SearchBooksScreen extends StatefulWidget {
  @override
  _SearchBooksScreenState createState() => _SearchBooksScreenState();
}

class _SearchBooksScreenState extends State<SearchBooksScreen> {
  TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _books = [];
  List<DocumentSnapshot> _filteredBooks = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  // Fungsi untuk memuat semua buku dari Firestore
  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      QuerySnapshot snapshot = await _firestore.collection('books').get();
      setState(() {
        _books = snapshot.docs;
        _filteredBooks = _books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load books: ${e.toString()}';
        _isLoading = false;
      });
      print('Error loading books: $e');
    }
  }

  // Fungsi untuk mencari buku berdasarkan query
  void _searchBooks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBooks = _books;
      } else {
        _filteredBooks = _books.where((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String title = data['title']?.toString().toLowerCase() ?? '';
          String author = data['author']?.toString().toLowerCase() ?? '';
          return title.contains(query.toLowerCase()) ||
              author.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Books", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4A0D00),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: Text(
                  "Explore the collection",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[900],
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _searchController,
                onChanged: _searchBooks,
                decoration: InputDecoration(
                  hintText: "Search by title or author",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.red[100],
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red[900]),
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _filteredBooks.isEmpty
                    ? Center(child: Text(
                    _searchController.text.isEmpty
                        ? "No books available in the library"
                        : "No books found matching '${_searchController.text}'"))
                    : RefreshIndicator(
                  onRefresh: _loadBooks,
                  child: ListView.builder(
                    itemCount: _filteredBooks.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data =
                      _filteredBooks[index].data() as Map<String, dynamic>;
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(
                            data['title'] ?? 'Untitled Book',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Author: ${data['author'] ?? 'Unknown'}\n'
                                'Available: ${data['stock'] ?? 0} copies',
                          ),
                          isThreeLine: true,
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.brown[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.book,
                              color: Colors.brown[800],
                            ),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // TODO: Navigate to book detail page
                            _showBookDetailDialog(context, data, _filteredBooks[index].id);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown[800],
        child: Icon(Icons.refresh),
        onPressed: _loadBooks,
      ),
    );
  }

  // Dialog untuk menampilkan detail buku dan opsi peminjaman
  void _showBookDetailDialog(BuildContext context, Map<String, dynamic> bookData, String bookId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bookData['title'] ?? 'Book Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Author: ${bookData['author'] ?? 'Unknown'}'),
            SizedBox(height: 8),
            Text('Available Copies: ${bookData['stock'] ?? 0}'),
            if (bookData['description'] != null) ...[
              SizedBox(height: 12),
              Text('Description:'),
              SizedBox(height: 4),
              Text(
                bookData['description'],
                style: TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          if ((bookData['stock'] ?? 0) > 0)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[800],
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // TODO: Implement borrow functionality
                Navigator.pop(context);
                _borrowBook(bookId);
              },
              child: Text('Borrow'),
            ),
        ],
      ),
    );
  }

  // Fungsi untuk meminjam buku
  Future<void> _borrowBook(String bookId) async {
    // TODO: Implement the borrow functionality with Firebase
    try {
      // Get current user
      // final user = FirebaseAuth.instance.currentUser;
      // if (user == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('You need to be logged in to borrow books')),
      //   );
      //   return;
      // }

      // Create a transaction in Firestore
      // await _firestore.collection('transactions').add({
      //   'user_id': user.uid,
      //   'book_id': bookId,
      //   'transaction_date': FieldValue.serverTimestamp(),
      //   'return_date': null,
      //   'status': 'borrowed',
      // });

      // Update book stock
      // await _firestore.collection('books').doc(bookId).update({
      //   'stock': FieldValue.increment(-1)
      // });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Borrow functionality will be implemented here')),
      );

      // Refresh the book list
      _loadBooks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to borrow book: ${e.toString()}')),
      );
    }
  }
}