import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';

/// Service for handling file uploads and downloads with Supabase Storage
class SupabaseStorageService {
  final SupabaseClient _client;

  SupabaseStorageService(this._client);

  /// Upload a file to Supabase Storage
  /// Returns the signed URL for accessing the file
  Future<String> uploadFile({
    required String bucketName,
    required String filePath,
    required String userId,
  }) async {
    try {
      debugPrint('📤 [Storage] Uploading file: $filePath');

      final file = File(filePath);

      // Validate file exists
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      // Validate file size
      final fileSize = await file.length();
      final extension = path
          .extension(filePath)
          .toLowerCase()
          .replaceAll('.', '');

      if (SupabaseConstants.allowedImageExtensions.contains(extension)) {
        if (fileSize > SupabaseConstants.maxImageSizeBytes) {
          throw Exception(
            'Image size exceeds limit (${SupabaseConstants.maxImageSizeMB}MB)',
          );
        }
      } else if (SupabaseConstants.allowedVideoExtensions.contains(extension)) {
        if (fileSize > SupabaseConstants.maxVideoSizeBytes) {
          throw Exception(
            'Video size exceeds limit (${SupabaseConstants.maxVideoSizeMB}MB)',
          );
        }
      } else {
        throw Exception('Unsupported file type: $extension');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_${timestamp}_${path.basename(filePath)}';

      debugPrint('📦 [Storage] Uploading as: $fileName');
      debugPrint(
        '📊 [Storage] File size: ${(fileSize / 1024).toStringAsFixed(2)} KB',
      );

      // Upload file
      final uploadPath = await _client.storage
          .from(bucketName)
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      debugPrint('✅ [Storage] File uploaded: $uploadPath');

      // Get public URL (permanent access if bucket is public)
      final publicUrl = _client.storage.from(bucketName).getPublicUrl(fileName);

      debugPrint('🔗 [Storage] Public URL created: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ [Storage] Upload failed: $e');
      rethrow;
    }
  }

  /// Delete a file from Supabase Storage
  Future<void> deleteFile({
    required String bucketName,
    required String fileName,
  }) async {
    try {
      debugPrint('🗑️ [Storage] Deleting file: $fileName');

      await _client.storage.from(bucketName).remove([fileName]);

      debugPrint('✅ [Storage] File deleted');
    } catch (e) {
      debugPrint('❌ [Storage] Delete failed: $e');
      rethrow;
    }
  }

  /// Get public URL for a file (if bucket is public)
  String getPublicUrl({required String bucketName, required String fileName}) {
    return _client.storage.from(bucketName).getPublicUrl(fileName);
  }

  /// Create a signed URL for temporary access
  Future<String> createSignedUrl({
    required String bucketName,
    required String fileName,
    int expiresInSeconds = 3600, // Default 1 hour
  }) async {
    try {
      final signedUrl = await _client.storage
          .from(bucketName)
          .createSignedUrl(fileName, expiresInSeconds);

      return signedUrl;
    } catch (e) {
      debugPrint('❌ [Storage] Failed to create signed URL: $e');
      rethrow;
    }
  }
}
