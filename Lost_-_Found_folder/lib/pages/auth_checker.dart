import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lost_and_found_app/auth/auth_service.dart';
import 'package:lost_and_found_app/models/user_profile.dart';
import 'package:lost_and_found_app/pages/home_page.dart';
import 'package:lost_and_found_app/pages/login_page.dart';
import 'package:lost_and_found_app/utils/custom_dialogs.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authService.authStateChanges.listen((data) {
      _redirect(data.session);
    });
    // Initial check
    _redirect(Supabase.instance.client.auth.currentSession);
  }

  Future<void> _redirect(Session? session) async {
    if (!mounted) return;

    if (session == null) {
      // No session, go to login page
      if (ModalRoute.of(context)?.settings.name != '/login') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } else {
      // Session exists, fetch user profile to determine role
      final userId = session.user.id;
      UserProfile? userProfile = await _authService.fetchUserProfile(userId);

      if (userProfile != null) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage(userProfile: userProfile)),
            (route) => false,
          );
        }
      } else {
        // Handle case where profile doesn't exist (shouldn't happen with trigger)
        if (mounted) {
          CustomDialogs.showAlertDialog(
            context: context,
            title: 'Profile Error',
            message: 'User profile not found. Please try logging in again.',
            onButtonPressed: () {
              _authService.signOut(); // Force sign out
            },
          );
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    // If not loading and not redirected, it means the listener will handle it.
    // This case should ideally not be reached for long.
    return const Scaffold(
      body: Center(
        child: Text('Initializing app...'),
      ),
    );
  }
}