import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rss_feed_reader_app/src/services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication Page'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: AuthForm(),
      ),
    );
  }
}

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  
  final AuthService _authService = AuthService();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    UserCredential? userCredential =
        await _authService.signIn(email: email, password: password);

    if (userCredential != null) {
      print('Login successful! User ID: ${userCredential.user!.uid}');
    } else {
      print('Login failed');
    }
  }

  void _handleRegistration() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    UserCredential? userCredential =
        await _authService.register(email: email, password: password);

    if (userCredential != null) {
      print('Registration successful! User ID: ${userCredential.user!.uid}');
    } else {
      print('Registration failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        const SizedBox(height: 24.0),
        ElevatedButton(
          onPressed: () {
            _handleLogin();
          },
          child: const Text('Login'),
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () {
            _handleRegistration();
          },
          child: const Text('Register'),
        ),
      ],
    );
  }
}
