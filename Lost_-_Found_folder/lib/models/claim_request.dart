import 'package:lost_and_found_app/utils/app_constants.dart';

class ClaimRequest {
  final String id;
  final DateTime createdAt;
  final String itemId;
  final String requesterId;
  final String requesterMessage;
  final String status; // 'pending', 'accepted', 'declined'
  final String? adminResponse;

  ClaimRequest({
    required this.id,
    required this.createdAt,
    required this.itemId,
    required this.requesterId,
    required this.requesterMessage,
    this.status = AppConstants.claimStatusPending,
    this.adminResponse,
  });

  factory ClaimRequest.fromJson(Map<String, dynamic> json) {
    return ClaimRequest(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      itemId: json['item_id'] as String,
      requesterId: json['requester_id'] as String,
      requesterMessage: json['requester_message'] as String,
      status: json['status'] as String? ?? AppConstants.claimStatusPending,
      adminResponse: json['admin_response'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'item_id': itemId,
      'requester_id': requesterId,
      'requester_message': requesterMessage,
      'status': status,
      'admin_response': adminResponse,
    };
  }

  // Method to create a copy of the ClaimRequest with updated fields
  ClaimRequest copyWith({
    String? id,
    DateTime? createdAt,
    String? itemId,
    String? requesterId,
    String? requesterMessage,
    String? status,
    String? adminResponse,
  }) {
    return ClaimRequest(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      itemId: itemId ?? this.itemId,
      requesterId: requesterId ?? this.requesterId,
      requesterMessage: requesterMessage ?? this.requesterMessage,
      status: status ?? this.status,
      adminResponse: adminResponse ?? this.adminResponse,
    );
  }
}