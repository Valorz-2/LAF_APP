class AppConstants {
  // Supabase .env keys
  static const String supabaseUrlKey = 'SUPABASE_URL';
  static const String supabaseAnonKey = 'SUPABASE_ANON_KEY';

  // Supabase Table Names
  static const String profilesTable = 'profiles';
  static const String lostItemsTable = 'lost_items';
  static const String claimRequestsTable = 'claim_requests';

  // Supabase Storage Bucket Names
  static const String itemImagesBucket = 'item-images'; // Changed from item_images to item-images

  // User Roles
  static const String userRole = 'user';
  static const String adminRole = 'admin';

  // Lost Item Statuses
  static const String itemStatusActive = 'active';
  static const String itemStatusClaimed = 'claimed';
  static const String itemStatusReturned = 'returned';

  // Claim Request Statuses
  static const String claimStatusPending = 'pending';
  static const String claimStatusAccepted = 'accepted';
  static const String claimStatusDeclined = 'declined';
}