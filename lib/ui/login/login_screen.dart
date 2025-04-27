import 'package:flutter/material.dart';
import 'package:library_app_abp/ui/register/register_screen.dart';
import 'package:library_app_abp/ui/user/user_home_screen.dart';
import 'package:library_app_abp/ui/admin/admin_home_screen.dart';
import 'package:library_app_abp/services/auth_service.dart';
import 'package:library_app_abp/services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  String? _errorMessage;
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Validate inputs
      if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() {
          _errorMessage = "Username and password cannot be empty";
          _isLoading = false;
        });
        return;
      }

      // Perform login with AuthService
      final userCredential = await _authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      // Fetch user role
      final role = await _userService.getUserRole(userCredential.user!.uid);

      // Navigate based on role
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        // Display user-friendly error message
        if (e.toString().contains('user-not-found')) {
          _errorMessage = 'No user found with this email';
        } else if (e.toString().contains('wrong-password')) {
          _errorMessage = 'Wrong password provided';
        } else if (e.toString().contains('invalid-email')) {
          _errorMessage = 'The email address is not valid';
        } else {
          _errorMessage = 'Login error: ${e.toString()}';
        }
      });
      print('Error during login: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                SizedBox(height: 35),
                Image.asset(
                  'assets/rak_buku.jpg',
                  width: 300,
                  height: 200,
                ),
                const SizedBox(height: 16),

                // Title
                const Text(
                  'LOG IN',
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'Serif',
                  ),
                ),

                const SizedBox(height: 32),

                // Username Input (Email)
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _usernameController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                      hintFadeDuration: Duration(milliseconds: 250),
                      border: UnderlineInputBorder(),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Icon(Icons.email),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Password Input
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      hintFadeDuration: Duration(milliseconds: 250),
                      border: UnderlineInputBorder(),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Icon(Icons.lock),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Error Message
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                const SizedBox(height: 16),

                // Remember Me
                Center(
                  child: SizedBox(
                    width: 330,
                    child: Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _rememberMe = newValue ?? false;
                            });
                          },
                        ),
                        const Text('Remember Me'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Login Button
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[900],
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.brown[300],
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('LOGIN'),
                  ),
                ),
                const SizedBox(height: 16),

                // Register Button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: const Text(
                    "Don't have an account yet? Register here",
                    style: TextStyle(color: Colors.brown),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
