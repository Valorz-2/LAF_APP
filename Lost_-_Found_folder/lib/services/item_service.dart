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
      // This is the path *within the bucket* where the file will be stored.
      // It should NOT include the bucket name itself.
      final String pathInBucket = fileName;

      print('Attempting to upload image to bucket: ${AppConstants.itemImagesBucket}');
      print('Generated file name: $fileName');
      print('Path in bucket for upload: $pathInBucket');
      print('Image file exists locally: ${await imageFile.exists()}'); // Check if file exists

      try {
        // Upload the file to the specified bucket and path within that bucket.
        // The `upload` method returns the `pathInBucket` you provided if successful.
        await _supabase.storage
            .from(AppConstants.itemImagesBucket)
            .upload(pathInBucket, imageFile,
                fileOptions: const FileOptions(upsert: false)); // upsert: false prevents overwriting
        print('Image uploaded successfully to path: $pathInBucket');

        // Get the public URL for the uploaded file.
        // IMPORTANT FIX: getPublicUrl expects the path *relative to the bucket's root*.
        // So, we pass `pathInBucket` (which is just the filename) directly.
        // This prevents the bucket name from being duplicated in the URL.
        imageUrl = _supabase.storage.from(AppConstants.itemImagesBucket).getPublicUrl(pathInBucket);
        print('Public URL generated: $imageUrl');
        print('Debug: Path passed to getPublicUrl: $pathInBucket'); // Verify this in console

      } on StorageException catch (e) {
        print('Supabase Storage Error during upload: ${e.message}');
        print('Error status code: ${e.statusCode}');
        rethrow; // Re-throw to be caught by UI
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
          return null;
    } catch (e) {
      print('Error getting lost item by ID: $e');
      return null;
    }
  }
}