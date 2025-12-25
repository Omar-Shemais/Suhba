import 'package:equatable/equatable.dart';

/// Post entity - Domain layer
/// Represents a post in the community
class PostEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String? title;
  final String content;
  final String? mediaUrl;
  final List<String> mediaUrls;
  final MediaType? mediaType;
  final bool isPinned;
  final bool isDeleted;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final bool isLikedByMe;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.title,
    required this.content,
    this.mediaUrl,
    this.mediaUrls = const [],
    this.mediaType,
    this.isPinned = false,
    this.isDeleted = false,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.viewsCount = 0,
    this.isLikedByMe = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userAvatar,
    title,
    content,
    mediaUrl,
    mediaUrls,
    mediaType,
    isPinned,
    isDeleted,
    likesCount,
    commentsCount,
    viewsCount,
    isLikedByMe,
    createdAt,
    updatedAt,
  ];

  /// Create a copy with modified fields
  PostEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? title,
    String? content,
    String? mediaUrl,
    List<String>? mediaUrls,
    MediaType? mediaType,
    bool? isPinned,
    bool? isDeleted,
    int? likesCount,
    int? commentsCount,
    int? viewsCount,
    bool? isLikedByMe,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostEntity(
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

/// Media type enum
enum MediaType { image, video }
