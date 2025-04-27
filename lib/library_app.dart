import 'package:flutter/material.dart';
import 'package:library_app_abp/ui/common/starting_page.dart';
import 'package:library_app_abp/ui/common/splash_screen.dart';
import 'package:library_app_abp/ui/login/login_screen.dart';
import 'package:library_app_abp/ui/register/register_screen.dart';
import 'package:library_app_abp/ui/user/user_home_screen.dart';
import 'package:library_app_abp/ui/admin/admin_home_screen.dart';

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Library',
      initialRoute: '/', // Untuk menandakan start halaman
      routes: {  // Tujuan halaman ke
        '/': (context) => const SplashScreen(),
        '/starting_page': (context) => const StartingPage(),
        '/login': (context) => const LoginScreen(),
        '/register' : (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/home_admin': (context) => const AdminPage()
      },
    );
  }
}