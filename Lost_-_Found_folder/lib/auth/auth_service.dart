import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lost_and_found_app/models/user_profile.dart';
import 'package:lost_and_found_app/utils/app_constants.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign up with email and password, and create a user profile with default role
  Future<AuthResponse> signUpWithEmailPassword(String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      // If user is created, ensure a profile exists (though trigger should handle this)
      if (response.user != null) {
        // We rely on the Supabase trigger `on_auth_user_created` to create the profile.
        // This part is mostly for demonstration or if the trigger fails.
        await _supabase
            .from(AppConstants.profilesTable)
            .select()
            .eq('id', response.user!.id)
            .single()
            .limit(1);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get the current user's email
  String? getCurrentUserEmail() {
    return _supabase.auth.currentUser?.email;
  }

  // Get the current user's ID
  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  // Fetch the user's profile, including their role
  Future<UserProfile?> fetchUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      // In a real app, you might want to use a proper logger
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}