/// Supabase configuration constants for Community Feature
class SupabaseConstants {
  // ⚠️ IMPORTANT: Replace these with your actual Supabase project credentials
  // Get them from: https://supabase.com/dashboard/project/_/settings/api
  static const String projectUrl = 'https://auwyjnhlllbsitvjzqrq.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF1d3lqbmhsbGxic2l0dmp6cXJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzOTU4NTEsImV4cCI6MjA3Nzk3MTg1MX0.O696XubPicPFSDhVSWZrxPsEz71UTfZ6Lx-t9j8ZdFA';

  // Never commit real keys to version control!

  // Table names
  static const String usersTable = 'users';
  static const String postsTable = 'posts';
  static const String commentsTable = 'comments';
  static const String likesTable = 'likes';
  static const String viewsTable = 'post_views';
  static const String reportsTable = 'reports';

  // Storage
  static const String communityMediaBucket = 'community-media';

  // Pagination
  static const int postsPerPage = 20;
  static const int commentsPerPage = 50;

  // File upload limits
  static const int maxImageSizeMB = 5;
  static const int maxVideoSizeMB = 50;
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024;
  static const int maxVideoSizeBytes = maxVideoSizeMB * 1024 * 1024;

  // Content limits
  static const int maxPostContentLength = 5000;
  static const int maxCommentContentLength = 1000;
  static const int maxTitleLength = 200;

  // Rate limiting
  static const int maxPostsPerHour = 10;

  // Media types
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];

  static const List<String> allowedVideoExtensions = ['mp4', 'mov', 'avi'];
}
