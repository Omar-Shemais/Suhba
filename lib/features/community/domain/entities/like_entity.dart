import 'package:equatable/equatable.dart';

/// Like entity - Domain layer
/// Represents a like on a post
class LikeEntity extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final DateTime createdAt;

  const LikeEntity({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, postId, userId, createdAt];
}
