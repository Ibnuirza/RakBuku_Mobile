import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/user_model.dart'; // Pastikan models/user_model.dart sudah ada

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save new user data to Firestore after registration
  Future<void> saveUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  /// Fetch user profile by userId
  Future<UserModel?> fetchUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, documentId: doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Get role of current user
  Future<String> getUserRole(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();
      print('Fetched User Data: $data');
      if (data is Map<String, dynamic>) {
        return data['role'] ?? 'user';
      } else {
        print('Unexpected user data type: ${data.runtimeType}');
        return 'user';
      }
    } catch (e) {
      print('Error getting user role: $e');
      return 'user';
    }
  }
}
