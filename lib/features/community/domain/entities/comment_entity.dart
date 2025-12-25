import 'package:equatable/equatable.dart';

/// Comment entity - Domain layer
/// Represents a comment on a post
class CommentEntity extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final bool isDeleted;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    this.isDeleted = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    postId,
    userId,
    userName,
    userAvatar,
    content,
    isDeleted,
    createdAt,
  ];

  /// Create a copy with modified fields
  CommentEntity copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    bool? isDeleted,
    DateTime? createdAt,
  }) {
    return CommentEntity(
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
