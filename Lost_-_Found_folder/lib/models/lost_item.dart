import 'package:lost_and_found_app/utils/app_constants.dart';

class LostItem {
  final String id;
  final DateTime createdAt;
  final String title;
  final String? description;
  final String locationFound;
  final String? imageUrl;
  final String? claimInstructions;
  final String status; // e.g., 'active', 'claimed', 'returned'
  final String? postedBy; // ID of the admin who posted it

  LostItem({
    required this.id,
    required this.createdAt,
    required this.title,
    this.description,
    required this.locationFound,
    this.imageUrl,
    this.claimInstructions,
    this.status = AppConstants.itemStatusActive,
    this.postedBy,
  });

  factory LostItem.fromJson(Map<String, dynamic> json) {
    return LostItem(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      locationFound: json['location_found'] as String,
      imageUrl: json['image_url'] as String?,
      claimInstructions: json['claim_instructions'] as String?,
      status: json['status'] as String? ?? AppConstants.itemStatusActive,
      postedBy: json['posted_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'title': title,
      'description': description,
      'location_found': locationFound,
      'image_url': imageUrl,
      'claim_instructions': claimInstructions,
      'status': status,
      'posted_by': postedBy,
    };
  }

  // Method to create a copy of the LostItem with updated fields
  LostItem copyWith({
    String? id,
    DateTime? createdAt,
    String? title,
    String? description,
    String? locationFound,
    String? imageUrl,
    String? claimInstructions,
    String? status,
    String? postedBy,
  }) {
    return LostItem(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      description: description ?? this.description,
      locationFound: locationFound ?? this.locationFound,
      imageUrl: imageUrl ?? this.imageUrl,
      claimInstructions: claimInstructions ?? this.claimInstructions,
      status: status ?? this.status,
      postedBy: postedBy ?? this.postedBy,
    );
  }
}