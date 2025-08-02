import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lost_and_found_app/models/claim_request.dart';
import 'package:lost_and_found_app/utils/app_constants.dart';

class ClaimService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Create a new claim request
  Future<void> createClaimRequest(ClaimRequest request) async {
    try {
      await _supabase.from(AppConstants.claimRequestsTable).insert(request.toJson());
    } catch (e) {
      print('Error creating claim request: $e');
      rethrow;
    }
  }

  // Fetch all claim requests (for admin)
  Future<List<ClaimRequest>> fetchAllClaimRequests() async {
    try {
      final List<dynamic> response = await _supabase
          .from(AppConstants.claimRequestsTable)
          .select()
          .order('created_at', ascending: false);
      return response.map((json) => ClaimRequest.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching all claim requests: $e');
      rethrow;
    }
  }

  // Fetch claim requests by a specific user
  Future<List<ClaimRequest>> fetchUserClaimRequests(String userId) async {
    try {
      final List<dynamic> response = await _supabase
          .from(AppConstants.claimRequestsTable)
          .select()
          .eq('requester_id', userId)
          .order('created_at', ascending: false);
      return response.map((json) => ClaimRequest.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching user claim requests: $e');
      rethrow;
    }
  }

  // Update a claim request's status and admin response
  Future<void> updateClaimRequestStatus(
      String requestId, String newStatus, String? adminResponse) async {
    try {
      await _supabase
          .from(AppConstants.claimRequestsTable)
          .update({'status': newStatus, 'admin_response': adminResponse})
          .eq('id', requestId);
    } catch (e) {
      print('Error updating claim request status: $e');
      rethrow;
    }
  }

  // Realtime listener for claim requests (e.g., for admin to see new claims)
  Stream<List<ClaimRequest>> getClaimRequestsStream() {
    return _supabase
        .from(AppConstants.claimRequestsTable)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((maps) => maps.map((map) => ClaimRequest.fromJson(map)).toList());
  }

  // Realtime listener for a specific user's claim requests
  Stream<List<ClaimRequest>> getUserClaimRequestsStream(String userId) {
    return _supabase
        .from(AppConstants.claimRequestsTable)
        .stream(primaryKey: ['id'])
        .eq('requester_id', userId)
        .order('created_at', ascending: false)
        .map((maps) => maps.map((map) => ClaimRequest.fromJson(map)).toList());
  }
}