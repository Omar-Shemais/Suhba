import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/community_remote_datasource.dart';

/// Community repository implementation
/// Implements the repository interface from domain layer
class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityRemoteDataSource remoteDataSource;

  CommunityRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<PostEntity>>> getPosts({
    int page = 0,
    int limit = 20,
  }) async {
    try {
      final posts = await remoteDataSource.getPosts(page: page, limit: limit);
      return Right(posts);
    } catch (e) {
      debugPrint('❌ [Repository] Error in getPosts: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> getPostById(String postId) async {
    try {
      final post = await remoteDataSource.getPostById(postId);
      return Right(post);
    } catch (e) {
      debugPrint('❌ [Repository] Error in getPostById: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> createPost({
    required String userId,
    String? title,
    required String content,
    List<String>? mediaPaths,
  }) async {
    try {
      final post = await remoteDataSource.createPost(
        userId: userId,
        title: title,
        content: content,
        mediaPaths: mediaPaths,
      );
      return Right(post);
    } catch (e) {
      debugPrint('❌ [Repository] Error in createPost: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost({
    required String postId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.deletePost(postId: postId, userId: userId);
      return const Right(null);
    } catch (e) {
      debugPrint('❌ [Repository] Error in deletePost: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> searchPosts(String query) async {
    try {
      final posts = await remoteDataSource.searchPosts(query);
      return Right(posts);
    } catch (e) {
      debugPrint('❌ [Repository] Error in searchPosts: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getComments({
    required String postId,
    int page = 0,
  }) async {
    try {
      final comments = await remoteDataSource.getComments(
        postId: postId,
        page: page,
      );
      return Right(comments);
    } catch (e) {
      debugPrint('❌ [Repository] Error in getComments: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> addComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    try {
      final comment = await remoteDataSource.addComment(
        postId: postId,
        userId: userId,
        content: content,
      );
      return Right(comment);
    } catch (e) {
      debugPrint('❌ [Repository] Error in addComment: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment({
    required String commentId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.deleteComment(
        commentId: commentId,
        userId: userId,
      );
      return const Right(null);
    } catch (e) {
      debugPrint('❌ [Repository] Error in deleteComment: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleLike({
    required String postId,
    required String userId,
  }) async {
    try {
      final isLiked = await remoteDataSource.toggleLike(
        postId: postId,
        userId: userId,
      );
      return Right(isLiked);
    } catch (e) {
      debugPrint('❌ [Repository] Error in toggleLike: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getLikesCount(String postId) async {
    try {
      final count = await remoteDataSource.getLikesCount(postId);
      return Right(count);
    } catch (e) {
      debugPrint('❌ [Repository] Error in getLikesCount: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<PostEntity> subscribeToNewPosts() {
    return remoteDataSource.subscribeToNewPosts();
  }

  @override
  Stream<CommentEntity> subscribeToNewComments(String postId) {
    return remoteDataSource.subscribeToNewComments(postId);
  }

  @override
  Future<Either<Failure, void>> reportContent({
    required String targetTable,
    required String targetId,
    required String userId,
    required String reason,
  }) async {
    try {
      await remoteDataSource.reportContent(
        targetTable: targetTable,
        targetId: targetId,
        userId: userId,
        reason: reason,
      );
      return const Right(null);
    } catch (e) {
      debugPrint('❌ [Repository] Error in reportContent: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<void> recordView({
    required String postId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.recordView(postId: postId, userId: userId);
    } catch (e) {
      debugPrint('❌ [Repository] Error in recordView: $e');
      // Don't throw - views are not critical
    }
  }
}
