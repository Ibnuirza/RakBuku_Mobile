import 'package:flutter/material.dart';
import 'package:library_app_abp/library_app.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Ini diperlukan untuk memastikan Flutter diinisialisasi sebelum Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp();

  // Jalankan aplikasi Anda
  runApp(const LibraryApp());
}