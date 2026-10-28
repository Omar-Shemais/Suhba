import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ImageHelper {
  // Target image size
  static const int targetSize = 512;
  static const int quality = 85;
  static const int maxFileSizeKB = 150;

  /// Convert URL (like Google photo) to base64
  static Future<String?> urlToBase64(String url) async {
    try {
      // Download image from URL
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        return null;
      }

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_image.jpg');
      await tempFile.writeAsBytes(response.bodyBytes);

      // Compress and convert to base64
      return await fileToBase64(tempFile);
    } catch (e) {
      log('Error converting URL to base64: $e');
      return null;
    }
  }

  /// Convert File to compressed base64
  static Future<String?> fileToBase64(File imageFile) async {
    try {
      // Compress image
      final compressedBytes = await compressImage(imageFile);

      if (compressedBytes == null) {
        return null;
      }

      // Convert to base64
      final base64String = base64Encode(compressedBytes);
      return base64String;
    } catch (e) {
      log('Error converting file to base64: $e');
      return null;
    }
  }

  /// Compress image to target size
  static Future<Uint8List?> compressImage(File imageFile) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: targetSize,
        minHeight: targetSize,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      // Check file size, if still too large, reduce quality
      if (result != null && result.lengthInBytes > maxFileSizeKB * 1024) {
        return await FlutterImageCompress.compressWithFile(
          imageFile.absolute.path,
          minWidth: targetSize,
          minHeight: targetSize,
          quality: 70, // Reduce quality more
          format: CompressFormat.jpeg,
        );
      }

      return result;
    } catch (e) {
      log('Error compressing image: $e');
      return null;
    }
  }

  /// Decode base64 to Uint8List for display
  static Uint8List? base64ToBytes(String base64String) {
    try {
      log(
        '[ImageHelper] Decoding base64 string, length: ${base64String.length}',
      );
      final bytes = base64Decode(base64String);
      log('[ImageHelper] Successfully decoded base64, bytes: ${bytes.length}');
      return bytes;
    } catch (e) {
      log(
        '[ImageHelper] Error decoding base64: $e, length: ${base64String.length}',
      );
      return null;
    }
  }

  /// Generate initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return '؟';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      // Single name, return first 2 letters
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    } else {
      // Multiple names, return first letter of each
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
  }

  /// Get color for avatar based on name hash
  static Color getAvatarColor(String name) {
    final colors = [
      const Color(0xFF1ABC9C), // Turquoise
      const Color(0xFF2ECC71), // Emerald
      const Color(0xFF3498DB), // Peter River
      const Color(0xFF9B59B6), // Amethyst
      const Color(0xFF34495E), // Wet Asphalt
      const Color(0xFFF39C12), // Orange
      const Color(0xFFE74C3C), // Alizarin
      const Color(0xFFE67E22), // Carrot
      const Color(0xFF95A5A6), // Concrete
      const Color(0xFF16A085), // Green Sea
    ];

    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }

  /// Generate avatar image from initials
  static Future<Uint8List> generateInitialsAvatar({
    required String name,
    int size = 512,
  }) async {
    final initials = getInitials(name);
    final backgroundColor = getAvatarColor(name);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
    );

    // Draw background circle
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    // Draw text (initials)
    final textPainter = TextPainter(
      text: TextSpan(
        text: initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    // Convert to image
    final picture = recorder.endRecording();
    final img = await picture.toImage(size, size);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  /// Generate base64 initials avatar
  static Future<String> generateInitialsAvatarBase64(String name) async {
    final bytes = await generateInitialsAvatar(name: name);
    return base64Encode(bytes);
  }

  /// Check if string is valid base64
  static bool isValidBase64(String? str) {
    if (str == null || str.isEmpty) return false;

    // Quick check: base64 should have length divisible by 4
    if (str.length % 4 != 0) return false;

    // Check if string contains only valid base64 characters
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
    if (!base64Pattern.hasMatch(str)) return false;

    // Try to decode a small portion to verify it's actually valid base64
    try {
      // Only decode first 100 characters to avoid performance issues
      final sample = str.length > 100 ? str.substring(0, 100) : str;
      base64Decode(sample);
      return true;
    } catch (e) {
      log('Base64 validation failed: $e');
      return false;
    }
  }

  /// Get image size in KB from base64
  static double getBase64SizeKB(String base64String) {
    final bytes = base64Decode(base64String);
    return bytes.lengthInBytes / 1024;
  }
}
