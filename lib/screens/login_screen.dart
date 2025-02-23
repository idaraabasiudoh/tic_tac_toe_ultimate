import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/core/styled_button.dart';
import '../widgets/core/styled_text_field.dart';
import '../widgets/core/theme_switcher.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _signUp() async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (response.user != null) {
        setState(() {
          _errorMessage = 'Sign up successful! Please log in.';
        });
      } else {
        setState(() {
          _errorMessage = 'Sign up failed: ${response.error?.message}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _signIn() async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (response.user != null) {
        // Successfully signed in; AuthWrapper will handle navigation
      } else {
        setState(() {
          _errorMessage = 'Sign in failed: ${response.error?.message}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        actions: [ThemeSwitcher()],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            StyledTextField(
              controller: _emailController,
              labelText: 'Email',
            ),
            SizedBox(height: 16),
            StyledTextField(
              controller: _passwordController,
              labelText: 'Password',
              obscureText: true,
            ),
            SizedBox(height: 24),
            StyledButton(
              onPressed: _signIn,
              child: Text('Sign In'),
            ),
            SizedBox(height: 12),
            StyledButton(
              onPressed: _signUp,
              child: Text('Sign Up'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

extension on AuthResponse {
  get error => null;
}
