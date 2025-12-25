import 'dart:convert';

import '../../domain/entities/post_entity.dart';

/// Post model - Data layer
/// Extends PostEntity and adds JSON serialization
class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.userId,
    required super.userName,
    super.userAvatar,
    super.title,
    required super.content,
    super.mediaUrl,
    super.mediaUrls,
    super.mediaType,
    super.isPinned,
    super.isDeleted,
    super.likesCount,
    super.commentsCount,
    super.viewsCount,
    super.isLikedByMe,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create PostModel from JSON (Supabase response)
  factory PostModel.fromJson(Map<String, dynamic> json) {
    final extractedMediaUrls = _extractMediaUrls(json);
    final primaryMediaUrl = extractedMediaUrls.isNotEmpty
        ? extractedMediaUrls.first
        : json['media_url'] as String?;

    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: _extractUserName(json),
      userAvatar: _extractUserAvatar(json),
      title: json['title'] as String?,
      content: json['content'] as String,
      mediaUrl: primaryMediaUrl,
      mediaUrls: extractedMediaUrls,
      mediaType: _inferMediaType(
        declaredType: json['media_type'] as String?,
        url: primaryMediaUrl,
      ),
      isPinned: json['is_pinned'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      likesCount: _extractCount(json, 'likes_count'),
      commentsCount: _extractCount(json, 'comments_count'),
      viewsCount: _extractCount(json, 'views_count'),
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert PostModel to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'media_url': mediaUrl,
      'is_pinned': isPinned,
      'media_urls': mediaUrls.isNotEmpty ? mediaUrls : null,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Helper: Extract user name from nested users object
  static String _extractUserName(Map<String, dynamic> json) {
    if (json['users'] != null && json['users'] is Map) {
      return (json['users'] as Map)['name'] as String? ?? 'مستخدم';
    }
    return 'مستخدم';
  }

  /// Helper: Extract user avatar from nested users object
  static String? _extractUserAvatar(Map<String, dynamic> json) {
    if (json['users'] != null && json['users'] is Map) {
      return (json['users'] as Map)['avatar_url'] as String?;
    }
    return null;
  }

  /// Helper: Extract count (likes or comments)
  static int _extractCount(Map<String, dynamic> json, String key) {
    // Try direct key first
    if (json.containsKey(key)) {
      final value = json[key];
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
    }

    // Try nested array count
    final arrayKey = key.replaceAll('_count', '');
    if (json.containsKey(arrayKey) && json[arrayKey] is List) {
      return (json[arrayKey] as List).length;
    }

    return 0;
  }

  /// Helper: Parse media type from URL
  static MediaType? _inferMediaType({String? declaredType, String? url}) {
    if (declaredType != null) {
      final normalized = declaredType.toLowerCase();
      if (normalized.contains('image')) {
        return MediaType.image;
      }
      if (normalized.contains('video')) {
        return MediaType.video;
      }
    }

    if (url == null || url.isEmpty) return null;

    final sanitizedUrl = url.split('?').first;
    final segments = sanitizedUrl.split('.');
    if (segments.length < 2) return null;
    final extension = segments.last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension)) {
      return MediaType.image;
    }
    if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
      return MediaType.video;
    }

    return null;
  }

  static List<String> _extractMediaUrls(Map<String, dynamic> json) {
    final urls = <String>[];

    void addUrl(String? value) {
      if (value == null || value.trim().isEmpty) return;
      if (!urls.contains(value)) {
        urls.add(value);
      }
    }

    final mediaUrlsField = json['media_urls'];
    if (mediaUrlsField is List) {
      for (final item in mediaUrlsField) {
        if (item is String) {
          addUrl(item);
        }
      }
    } else if (mediaUrlsField is String) {
      final parsed = _tryParseJsonArray(mediaUrlsField);
      if (parsed != null) {
        for (final item in parsed) {
          addUrl(item);
        }
      } else {
        addUrl(mediaUrlsField);
      }
    }

    final mediaUrlField = json['media_url'];
    if (mediaUrlField is String) {
      final parsed = _tryParseJsonArray(mediaUrlField);
      if (parsed != null) {
        for (final item in parsed) {
          addUrl(item);
        }
      } else {
        addUrl(mediaUrlField);
      }
    }

    return urls;
  }

  static List<String>? _tryParseJsonArray(String value) {
    final trimmed = value.trim();
    if (!(trimmed.startsWith('[') && trimmed.endsWith(']'))) {
      return null;
    }

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is List) {
        return decoded.whereType<String>().toList();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Create a copy with updated fields
  @override
  PostModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? title,
    String? content,
    String? mediaUrl,
    MediaType? mediaType,
    List<String>? mediaUrls,
    bool? isPinned,
    bool? isDeleted,
    int? likesCount,
    int? commentsCount,
    int? viewsCount,
    bool? isLikedByMe,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      title: title ?? this.title,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      mediaType: mediaType ?? this.mediaType,
      isPinned: isPinned ?? this.isPinned,
      isDeleted: isDeleted ?? this.isDeleted,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
