import '../../domain/entities/like_entity.dart';

/// Like model - Data layer
/// Extends LikeEntity and adds JSON serialization
class LikeModel extends LikeEntity {
  const LikeModel({
    required super.id,
    required super.postId,
    required super.userId,
    required super.createdAt,
  });

  /// Create LikeModel from JSON (Supabase response)
  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert LikeModel to JSON (for Supabase insert)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
