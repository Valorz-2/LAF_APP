import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:lost_and_found_app/models/lost_item.dart';
import 'package:lost_and_found_app/utils/app_constants.dart';

class ItemService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  // Fetch all active lost items
  Future<List<LostItem>> fetchLostItems() async {
    try {
      final List<dynamic> response = await _supabase
          .from(AppConstants.lostItemsTable)
          .select()
          .order('created_at', ascending: false); // Order by newest first

      return response.map((json) => LostItem.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching lost items: $e');
      rethrow;
    }
  }

  // Add a new lost item with image upload
  Future<void> addLostItem(LostItem item, File? imageFile) async {
    String? imageUrl;
    if (imageFile != null) {
      // Generate a unique filename (UUID.extension)
      final String fileName = '${_uuid.v4()}.${imageFile.path.split('.').last}';
      final String pathInBucket = fileName;

      print('Attempting to upload image to bucket: ${AppConstants.itemImagesBucket}');
      print('Path in bucket for upload: $pathInBucket');

      try {
        // Upload the file
        await _supabase.storage
            .from(AppConstants.itemImagesBucket)
            .upload(pathInBucket, imageFile,
                fileOptions: const FileOptions(upsert: false));
        print('Image uploaded successfully to path: $pathInBucket');

        // Get the public URL for the uploaded file.
        imageUrl = _supabase.storage.from(AppConstants.itemImagesBucket).getPublicUrl(pathInBucket);
        print('Public URL generated: $imageUrl');

      } on StorageException catch (e) {
        print('Supabase Storage Error during upload: ${e.message}');
        rethrow;
      } catch (e) {
        print('Generic Error uploading image: $e');
        rethrow;
      }
    } else {
      print('No image file provided for upload.');
    }

    try {
      // Insert item data into the database, including the generated image URL
      await _supabase.from(AppConstants.lostItemsTable).insert(item.copyWith(imageUrl: imageUrl).toJson());
      print('Lost item data inserted into database successfully.');
    } catch (e) {
      print('Error inserting lost item into database: $e');
      rethrow;
    }
  }

  // Update a lost item's status
  Future<void> updateLostItemStatus(String itemId, String newStatus) async {
    try {
      await _supabase
          .from(AppConstants.lostItemsTable)
          .update({'status': newStatus})
          .eq('id', itemId);
    } catch (e) {
      print('Error updating lost item status: $e');
      rethrow;
    }
  }

  // Get a single lost item by ID
  Future<LostItem?> getLostItemById(String itemId) async {
    try {
      final response = await _supabase
          .from(AppConstants.lostItemsTable)
          .select()
          .eq('id', itemId)
          .single();
      return LostItem.fromJson(response);
    } catch (e) {
      print('Error getting lost item by ID: $e');
      return null;
    }
  }
}