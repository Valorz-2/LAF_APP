import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lost_and_found_app/utils/custom_dialogs.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      CustomDialogs.showAlertDialog(
        context: context,
        title: 'Email Required',
        message: 'Please enter your email address.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    CustomDialogs.showLoadingDialog(context, message: 'Sending reset link...');

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
        redirectTo: 'io.supabase.flutterquickstart://login-callback/', // Important for deep linking
      );
      if (mounted) {
        CustomDialogs.hideLoadingDialog(context);
        CustomDialogs.showAlertDialog(
          context: context,
          title: 'Password Reset Link Sent',
          message: 'A password reset link has been sent to ${_emailController.text.trim()}. Please check your inbox.',
          onButtonPressed: () {
            Navigator.of(context).pop(); // Dismiss alert
            Navigator.of(context).pop(); // Go back to login page
          },
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        CustomDialogs.hideLoadingDialog(context);
        CustomDialogs.showAlertDialog(
          context: context,
          title: 'Error',
          message: e.message,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomDialogs.hideLoadingDialog(context);
        CustomDialogs.showAlertDialog(
          context: context,
          title: 'Error',
          message: 'An unexpected error occurred: $e',
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Reset Your Password',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Text(
              'Enter your email address below and we\'ll send you a link to reset your password.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your registered email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _resetPassword,
                    child: const Text('Send Reset Link'),
                  ),
          ],
        ),
      ),
    );
  }
}