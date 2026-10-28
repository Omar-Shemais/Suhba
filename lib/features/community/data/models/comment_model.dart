import '../../domain/entities/comment_entity.dart';

/// Comment model - Data layer
/// Extends CommentEntity and adds JSON serialization
class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.userId,
    required super.userName,
    super.userAvatar,
    required super.content,
    super.isDeleted,
    required super.createdAt,
  });

  /// Create CommentModel from JSON (Supabase response)
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      userName: _extractUserName(json),
      userAvatar: _extractUserAvatar(json),
      content: json['content'] as String,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert CommentModel to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
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

  /// Create a copy with updated fields
  @override
  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    bool? isDeleted,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
