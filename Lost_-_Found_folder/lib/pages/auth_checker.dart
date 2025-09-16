import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lost_and_found_app/auth/auth_service.dart';
import 'package:lost_and_found_app/models/user_profile.dart';
import 'package:lost_and_found_app/pages/home_page.dart';
import 'package:lost_and_found_app/pages/login_page.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<AuthState>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // While waiting for the first auth event, show a loading indicator.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;

        if (session != null) {
          // User is signed in. Now, we need to fetch their profile.
          // We use a FutureBuilder for this asynchronous operation.
          return FutureBuilder<UserProfile?>(
            future: authService.fetchUserProfile(session.user.id),
            builder: (context, profileSnapshot) {
              // While fetching the profile, show a loading indicator.
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final userProfile = profileSnapshot.data;

              if (userProfile != null) {
                // If profile is fetched successfully, show the HomePage.
                return HomePage(userProfile: userProfile);
              } else {
                // This is an error state (e.g., user exists in auth but not in profiles table).
                // It's safest to sign them out and show the login page.
                authService.signOut();
                return const LoginPage();
              }
            },
          );
        } else {
          // User is not signed in, show the LoginPage.
          return const LoginPage();
        }
      },
    );
  }
}