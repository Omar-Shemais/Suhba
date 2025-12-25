import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/comment_entity.dart';
import '../entities/post_entity.dart';

/// Community repository interface - Domain layer
/// Defines the contract for community data operations
abstract class CommunityRepository {
  // ==================== Posts ====================

  /// Get paginated posts
  Future<Either<Failure, List<PostEntity>>> getPosts({
    int page = 0,
    int limit = 20,
  });

  /// Get a single post by ID
  Future<Either<Failure, PostEntity>> getPostById(String postId);

  /// Create a new post
  Future<Either<Failure, PostEntity>> createPost({
    required String userId,
    String? title,
    required String content,
    List<String>? mediaPaths,
  });

  /// Delete a post (soft delete)
  Future<Either<Failure, void>> deletePost({
    required String postId,
    required String userId,
  });

  /// Search posts by query
  Future<Either<Failure, List<PostEntity>>> searchPosts(String query);

  // ==================== Comments ====================

  /// Get comments for a post
  Future<Either<Failure, List<CommentEntity>>> getComments({
    required String postId,
    int page = 0,
  });

  /// Add a comment to a post
  Future<Either<Failure, CommentEntity>> addComment({
    required String postId,
    required String userId,
    required String content,
  });

  /// Delete a comment (soft delete)
  Future<Either<Failure, void>> deleteComment({
    required String commentId,
    required String userId,
  });

  // ==================== Likes ====================

  /// Toggle like on a post (like if not liked, unlike if already liked)
  /// Returns true if liked, false if unliked
  Future<Either<Failure, bool>> toggleLike({
    required String postId,
    required String userId,
  });

  /// Get likes count for a post
  Future<Either<Failure, int>> getLikesCount(String postId);

  // ==================== Real-time ====================

  /// Subscribe to new posts in real-time
  Stream<PostEntity> subscribeToNewPosts();

  /// Subscribe to new comments on a post
  Stream<CommentEntity> subscribeToNewComments(String postId);

  // ==================== Reports ====================

  /// Report content (post or comment)
  Future<Either<Failure, void>> reportContent({
    required String targetTable,
    required String targetId,
    required String userId,
    required String reason,
  });
}
