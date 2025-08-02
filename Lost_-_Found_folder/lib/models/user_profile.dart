import 'package:lost_and_found_app/utils/app_constants.dart';

class UserProfile {
  final String id;
  final String email;
  final String role; // 'admin' or 'user'

  UserProfile({
    required this.id,
    required this.email,
    this.role = AppConstants.userRole, // Default role is 'user'
  });

  // Factory constructor to create a UserProfile from a JSON map
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? AppConstants.userRole,
    );
  }

  // Convert UserProfile object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
    };
  }
}
