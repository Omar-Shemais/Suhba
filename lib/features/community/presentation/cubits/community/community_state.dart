import 'package:equatable/equatable.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/entities/comment_entity.dart';

/// Base state for Community
abstract class CommunityState extends Equatable {
  final List<PostEntity> posts;
  final List<CommentEntity> comments;

  const CommunityState({this.posts = const [], this.comments = const []});

  @override
  List<Object?> get props => [posts, comments];
}

/// Initial state
class CommunityInitial extends CommunityState {
  const CommunityInitial() : super(posts: const [], comments: const []);
}

/// Loading first page
class CommunityLoading extends CommunityState {
  const CommunityLoading({super.comments}) : super(posts: const []);
}

/// Loading more posts (pagination)
class CommunityLoadingMore extends CommunityState {
  const CommunityLoadingMore(List<PostEntity> posts, {super.comments})
    : super(posts: posts);
}

/// Posts loaded successfully
class CommunityLoaded extends CommunityState {
  final bool hasMore;

  const CommunityLoaded(
    List<PostEntity> posts, {
    this.hasMore = true,
    super.comments,
  }) : super(posts: posts);

  @override
  List<Object?> get props => [posts, hasMore, comments];
}

/// Creating a new post
class CommunityCreatingPost extends CommunityState {
  const CommunityCreatingPost(List<PostEntity> posts, {super.comments})
    : super(posts: posts);
}

/// Post created successfully
class CommunityPostCreated extends CommunityState {
  final PostEntity post;

  const CommunityPostCreated(
    this.post,
    List<PostEntity> posts, {
    super.comments,
  }) : super(posts: posts);

  @override
  List<Object?> get props => [post, posts, comments];
}

/// Toggling like on a post
class CommunityTogglingLike extends CommunityState {
  final String postId;

  const CommunityTogglingLike(
    this.postId,
    List<PostEntity> posts, {
    super.comments,
  }) : super(posts: posts);

  @override
  List<Object?> get props => [postId, posts, comments];
}

/// Error state
class CommunityError extends CommunityState {
  final String message;

  const CommunityError(this.message, {super.posts});

  @override
  List<Object?> get props => [message, posts];
}

/// Refreshing feed
class CommunityRefreshing extends CommunityState {
  const CommunityRefreshing(List<PostEntity> posts, {super.comments})
    : super(posts: posts);
}

/// Loading comments for a post
class CommunityLoadingComments extends CommunityState {
  const CommunityLoadingComments(List<PostEntity> posts, {super.comments})
    : super(posts: posts);
}

/// Comments loaded
class CommunityCommentsLoaded extends CommunityState {
  const CommunityCommentsLoaded(
    List<PostEntity> posts,
    List<CommentEntity> comments,
  ) : super(posts: posts, comments: comments);
}
