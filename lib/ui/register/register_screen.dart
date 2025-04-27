import 'package:flutter/material.dart';
import 'package:library_app_abp/ui/login/login_screen.dart';
import 'package:library_app_abp/services/auth_service.dart';
import 'package:library_app_abp/services/user_service.dart';
import '../../Models/user_model.dart';

// File ini adalah halaman untuk orang yang baru mau menggunakan aplikasi
// dan ingin mendaftar.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _adminCodeController = TextEditingController();

  String _selectedRole = "User"; // Default role
  bool _isAdmin = false; // Untuk menyembunyikan/memunculkan input kode admin
  bool _isLoading = false;
  String? _errorMessage;

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  // Admin code untuk validasi admin
  final String _validAdminCode = "admin123"; // Ganti dengan kode admin yang lebih aman

  void _register() async {
    // Reset error message
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      // Validasi input
      if (_nameController.text.isEmpty ||
          _phoneController.text.isEmpty ||
          _usernameController.text.isEmpty ||
          _passwordController.text.isEmpty) {
        setState(() {
          _errorMessage = "All fields are required";
          _isLoading = false;
        });
        return;
      }

      // Validasi password
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = "Passwords do not match";
          _isLoading = false;
        });
        return;
      }

      // Validasi admin code jika role admin dipilih
      if (_isAdmin && _adminCodeController.text != _validAdminCode) {
        setState(() {
          _errorMessage = "Invalid admin code";
          _isLoading = false;
        });
        return;
      }

      // Register user dengan AuthService dan UserService
      final userCredential = await _authService.register(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      // Save user data to Firestore
      final newUser = UserModel(
        id: userCredential.user!.uid,
        namaLengkap: _nameController.text,
        phoneNumber: _phoneController.text,
        username: _usernameController.text,
        role: _isAdmin ? 'admin' : 'user',
        createdAt: DateTime.now(),
      );

      await _userService.saveUserData(newUser);

      // Tampilkan pesan sukses dan navigasi ke login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful! Please login')),
      );

      // Navigasi ke halaman login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      setState(() {
        // Menampilkan pesan error yang lebih user-friendly
        if (e.toString().contains('weak-password')) {
          _errorMessage = 'The password provided is too weak';
        } else if (e.toString().contains('email-already-in-use')) {
          _errorMessage = 'The account already exists for that email';
        } else if (e.toString().contains('invalid-email')) {
          _errorMessage = 'The email address is not valid';
        } else {
          _errorMessage = 'Registration error: ${e.toString()}';
        }
      });
      print('Error during registration: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Text(
                "REGISTER",
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'Serif',
                ),
              ),
              SizedBox(height: 32),

              // Nama Lengkap
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                    hintText: "Full Name",
                    border: UnderlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                    prefixIcon: Icon(Icons.person)
                ),
              ),
              SizedBox(height: 16),

              // Nomor Telepon
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    hintText: "Phone Number",
                    border: UnderlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                    prefixIcon: Icon(Icons.phone)
                ),
              ),
              SizedBox(height: 16),

              // Username (Email for Firebase Auth)
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    hintText: "Email",
                    border: UnderlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                    prefixIcon: Icon(Icons.email)
                ),
              ),
              SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    hintText: "Password",
                    border: UnderlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                    prefixIcon: Icon(Icons.lock)
                ),
              ),
              SizedBox(height: 16),

              // Confirm Password
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                    hintText: "Confirm Password",
                    border: UnderlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                    prefixIcon: Icon(Icons.lock_outline_rounded)
                ),
              ),
              SizedBox(height: 16),

              // Role Selection (User / Admin)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text("User"),
                      value: "User",
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                          _isAdmin = false; // Hide Admin Code Input
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text("Admin"),
                      value: "Admin",
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                          _isAdmin = true; // Show Admin Code Input
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Admin Code (Hidden by Default)
              Visibility(
                visible: _isAdmin,
                child: TextField(
                  controller: _adminCodeController,
                  decoration: InputDecoration(
                      hintText: "Enter admin code",
                      border: UnderlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                      prefixIcon: Icon(Icons.admin_panel_settings)
                  ),
                ),
              ),
              if (_isAdmin) SizedBox(height: 16),

              // Error Message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Register Button
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A0D00),
                    padding: EdgeInsets.all(16),
                  ),
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    "REGISTER",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: 16),
              // Login link
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text(
                  "Already have an account? Login here",
                  style: TextStyle(color: Colors.brown),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
