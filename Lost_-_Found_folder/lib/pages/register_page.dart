import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lost_and_found_app/auth/auth_service.dart';
import 'package:lost_and_found_app/utils/custom_dialogs.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Regex to ensure the email matches the format CB.SC.XXXXXXXXXX@xx.amrita.edu
    final RegExp amritaEmailRegex = RegExp(
      r'^CB\.SC\.\w{10}@[a-zA-Z]{2}\.amrita\.edu$',
      caseSensitive: false,
    );

    // Validate the email format before proceeding
    if (!amritaEmailRegex.hasMatch(email)) {
      if (mounted) {
        CustomDialogs.showAlertDialog(
          context: context,
          title: 'Invalid Email Format',
          message: 'Please use your official campus email, e.g., CB.SC.XXXXXXXXXX@cb.amrita.edu',
        );
      }
      return; // Stop the function if validation fails
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResponse response = await _authService.signUpWithEmailPassword(
        email,
        password,
      );
      if (response.user != null) {
        if (mounted) {
          CustomDialogs.showAlertDialog(
            context: context,
            title: 'Registration Successful',
            message: 'Account created for ${response.user!.email}. Please login.',
            onButtonPressed: () {
              Navigator.of(context).pop(); // Dismiss alert
              Navigator.of(context).pop(); // Go back to login page
            },
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        CustomDialogs.showAlertDialog(
          context: context,
          title: 'Registration Failed',
          message: e.message,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomDialogs.showAlertDialog(
          context: context,
          title: 'Error',
          message: 'An unexpected error occurred: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Create Your Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Amrita Campus Email',
                  hintText: 'e.g., CB.SC.XXXXXXXXXX@cb.amrita.edu',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _signUp,
                      child: const Text('Sign Up'),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Go back to login page
                },
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}