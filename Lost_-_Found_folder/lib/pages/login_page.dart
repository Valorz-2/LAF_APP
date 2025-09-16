import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lost_and_found_app/auth/auth_service.dart';
import 'package:lost_and_found_app/utils/custom_dialogs.dart';
import 'package:lost_and_found_app/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
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
      final AuthResponse response = await _authService.signInWithEmailPassword(
        email,
        password,
      );
      if (response.user != null) {
        // The AuthChecker will handle navigation automatically.
      }
    } on AuthException catch (e) {
      if (mounted) {
        CustomDialogs.showAlertDialog(
          context: context,
          title: 'Login Failed',
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
    final Size size = MediaQuery.of(context).size;
    const Color primaryMaroon = Color(0xFF880022);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Top curved section
            Container(
              height: size.height * 0.35,
              width: size.width,
              decoration: const BoxDecoration(
                color: primaryMaroon,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://placehold.co/100x100/FFFFFF/880022?text=LOGO',
                    height: 100,
                    width: 100,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.school,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'AMRITA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    'VISHWA VIDYAPEETHAM',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Login form section
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Sign in',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Your Amrita Campus Email',
                      hintText: 'e.g., CB.SC.XXXXXXXXXX@cb.amrita.edu',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Enter your password',
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/forgot_password');
                      },
                      child: const Text(
                        "Can't Access your account? Forgot my password",
                        style: TextStyle(color: Colors.blueGrey, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _signIn,
                            child: const Text('Sign in'),
                          ),
                        ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}