import 'package:cloud_firestore/cloud_firestore.dart';

// Model untuk User
class UserModel {
  final String? id;
  final String namaLengkap;
  final String phoneNumber;
  final String username;
  final String role;
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.namaLengkap,
    required this.phoneNumber,
    required this.username,
    required this.role,
    this.createdAt,
  });

  // Factory constructor untuk membuat instance UserModel dari Map (dari Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return UserModel(
      id: documentId,
      namaLengkap: map['nama_lengkap'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      username: map['username'] ?? '',
      role: map['role'] ?? 'user',  // Default role 'user'
      createdAt: (map['created_at'] as Timestamp?)?.toDate(), // Convert Timestamp to DateTime
    );
  }

  // Method untuk mengubah UserModel menjadi Map yang bisa disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'nama_lengkap': namaLengkap,
      'phone_number': phoneNumber,
      'username': username,
      'role': role,
      'created_at': createdAt,
    };
  }
}
