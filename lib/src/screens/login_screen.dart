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
  AuthFormState createState() => AuthFormState();
}

class AuthFormState extends State<AuthForm> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      await _authService.signIn(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          _showErrorDialog(
            title: 'Invalid credentials',
            message: 'Invalid credentials provided for that user.',
          );
          break;
        case 'email-not-verified':
          _showErrorDialog(
            title: 'Email not verified',
            message: 'Please verify your email address.',
          );
          await _authService.signOut();
          break;
        default:
          _showErrorDialog(
            title: 'An error occurred',
            message: e.message ?? 'An error occurred',
          );
      }
    } catch (e) {
      print('Login error: $e');
    }
  }

  void _handleRegistration() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      await _authService.register(email: email, password: password);
      _showErrorDialog(
        title: 'Registration successful',
        message: 'Please verify your email address.',
      );
      await _authService.signOut();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _showErrorDialog(
            title: 'Email already in use',
            message: e.message ?? 'Email already in use',
          );
          break;
        default:
          _showErrorDialog(
            title: 'An error occurred',
            message: e.message ?? 'An error occurred',
          );
      }
    } catch (e) {
      print('Registration error: $e');
    }
  }

  void _showErrorDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
