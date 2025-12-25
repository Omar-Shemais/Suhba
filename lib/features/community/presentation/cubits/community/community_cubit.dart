import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/usecases/create_post_usecase.dart';
import '../../../domain/usecases/delete_post_usecase.dart';
import '../../../domain/usecases/get_posts_usecase.dart';
import '../../../domain/usecases/toggle_like_usecase.dart';
import '../../../domain/usecases/get_comments_usecase.dart';
import '../../../domain/usecases/add_comment_usecase.dart';
import 'community_state.dart';

/// Community Cubit - Manages community feed state
class CommunityCubit extends Cubit<CommunityState> {
  final GetPostsUseCase getPostsUseCase;
  final CreatePostUseCase createPostUseCase;
  final ToggleLikeUseCase toggleLikeUseCase;
  final DeletePostUseCase deletePostUseCase;
  final GetCommentsUseCase getCommentsUseCase;
  final AddCommentUseCase addCommentUseCase;

  int _currentPage = 0;
  bool _hasMore = true;

  CommunityCubit({
    required this.getPostsUseCase,
    required this.createPostUseCase,
    required this.toggleLikeUseCase,
    required this.deletePostUseCase,
    required this.getCommentsUseCase,
    required this.addCommentUseCase,
  }) : super(const CommunityInitial());

  /// Load posts (with optional refresh)
  Future<void> loadPosts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
      emit(CommunityLoading(comments: state.comments));
    } else {
      if (!_hasMore) {
        debugPrint('⚠️ [CommunityCubit] No more posts to load');
        return;
      }
      emit(CommunityLoadingMore(state.posts, comments: state.comments));
    }

    debugPrint('📥 [CommunityCubit] Loading posts page $_currentPage...');

    final result = await getPostsUseCase(page: _currentPage, limit: 20);

    result.fold(
      (failure) {
        debugPrint('❌ [CommunityCubit] Error: ${failure.message}');
        emit(CommunityError(failure.message, posts: state.posts));
      },
      (newPosts) {
        debugPrint('✅ [CommunityCubit] Loaded ${newPosts.length} posts');

        if (newPosts.isEmpty) {
          _hasMore = false;
          emit(
            CommunityLoaded(
              state.posts,
              hasMore: false,
              comments: state.comments,
            ),
          );
        } else {
          _currentPage++;
          final allPosts = refresh ? newPosts : [...state.posts, ...newPosts];

          emit(
            CommunityLoaded(
              allPosts,
              hasMore: newPosts.length >= 20,
              comments: state.comments,
            ),
          );
        }
      },
    );
  }

  /// Refresh feed (pull-to-refresh)
  Future<void> refreshFeed() async {
    emit(CommunityRefreshing(state.posts, comments: state.comments));
    await loadPosts(refresh: true);
  }

  /// Create a new post
  Future<void> createPost({
    required String content,
    String? title,
    List<String>? mediaPaths,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(const CommunityError('يجب تسجيل الدخول أولاً'));
      return;
    }

    emit(CommunityCreatingPost(state.posts, comments: state.comments));
    debugPrint('📤 [CommunityCubit] Creating post...');

    final result = await createPostUseCase(
      userId: user.uid,
      title: title,
      content: content,
      mediaPaths: mediaPaths,
    );

    result.fold(
      (failure) {
        debugPrint('❌ [CommunityCubit] Create post error: ${failure.message}');
        emit(CommunityError(failure.message, posts: state.posts));
      },
      (post) {
        debugPrint('✅ [CommunityCubit] Post created successfully');
        emit(CommunityPostCreated(post, state.posts, comments: state.comments));

        // Refresh feed to show new post
        Future.delayed(const Duration(milliseconds: 500), () {
          loadPosts(refresh: true);
        });
      },
    );
  }

  /// Toggle like on a post
  Future<void> toggleLike(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(const CommunityError('يجب تسجيل الدخول أولاً'));
      return;
    }

    // Save original state before toggle
    final originalPosts = List<PostEntity>.from(state.posts);
    final currentPost = state.posts.firstWhere((post) => post.id == postId);

    // Optimistic update
    final optimisticPosts = state.posts.map((post) {
      if (post.id == postId) {
        final newLikedState = !post.isLikedByMe;
        final newCount = newLikedState
            ? post.likesCount + 1
            : post.likesCount - 1;
        return post.copyWith(isLikedByMe: newLikedState, likesCount: newCount);
      }
      return post;
    }).toList();

    emit(
      CommunityTogglingLike(postId, optimisticPosts, comments: state.comments),
    );

    debugPrint(
      '❤️ [CommunityCubit] Toggling like for post: $postId (current: ${currentPost.isLikedByMe})',
    );

    final result = await toggleLikeUseCase(postId: postId, userId: user.uid);

    result.fold(
      (failure) {
        debugPrint('❌ [CommunityCubit] Toggle like error: ${failure.message}');
        // Revert to original state
        emit(
          CommunityLoaded(
            originalPosts,
            hasMore: _hasMore,
            comments: state.comments,
          ),
        );
        emit(CommunityError(failure.message, posts: originalPosts));
      },
      (isLiked) {
        debugPrint('✅ [CommunityCubit] Like toggled successfully: $isLiked');

        // Update with actual result from database based on original state
        final newCount = isLiked
            ? currentPost.likesCount + 1
            : (currentPost.likesCount > 0 ? currentPost.likesCount - 1 : 0);

        final finalPosts = originalPosts.map((post) {
          if (post.id == postId) {
            return post.copyWith(isLikedByMe: isLiked, likesCount: newCount);
          }
          return post;
        }).toList();

        emit(
          CommunityLoaded(
            finalPosts,
            hasMore: _hasMore,
            comments: state.comments,
          ),
        );
      },
    );
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(const CommunityError('يجب تسجيل الدخول أولاً'));
      return;
    }

    debugPrint('🗑️ [CommunityCubit] Deleting post: $postId');

    final result = await deletePostUseCase(postId: postId, userId: user.uid);

    result.fold(
      (failure) {
        debugPrint('❌ [CommunityCubit] Delete error: ${failure.message}');
        emit(CommunityError(failure.message, posts: state.posts));
      },
      (_) {
        debugPrint('✅ [CommunityCubit] Post deleted');
        // Remove from list
        final updatedPosts = state.posts
            .where((post) => post.id != postId)
            .toList();
        emit(
          CommunityLoaded(
            updatedPosts,
            hasMore: _hasMore,
            comments: state.comments,
          ),
        );
      },
    );
  }

  /// Load more posts (for infinite scroll)
  Future<void> loadMore() async {
    if (_hasMore && state is! CommunityLoadingMore) {
      await loadPosts(refresh: false);
    }
  }

  /// Load comments for a specific post
  Future<void> loadComments(String postId) async {
    emit(CommunityLoadingComments(state.posts, comments: state.comments));
    debugPrint('💬 [CommunityCubit] Loading comments for post: $postId');

    final result = await getCommentsUseCase(postId: postId);

    result.fold(
      (failure) {
        debugPrint(
          '❌ [CommunityCubit] Load comments error: ${failure.message}',
        );
        emit(CommunityError(failure.message, posts: state.posts));
      },
      (comments) {
        debugPrint('✅ [CommunityCubit] Loaded ${comments.length} comments');
        emit(CommunityCommentsLoaded(state.posts, comments));
      },
    );
  }

  /// Add a comment to a post
  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(const CommunityError('يجب تسجيل الدخول أولاً'));
      return;
    }

    debugPrint('💬 [CommunityCubit] Adding comment to post: $postId');

    final result = await addCommentUseCase(
      postId: postId,
      userId: user.uid,
      content: content,
    );

    result.fold(
      (failure) {
        debugPrint('❌ [CommunityCubit] Add comment error: ${failure.message}');
        emit(CommunityError(failure.message, posts: state.posts));
      },
      (comment) {
        debugPrint('✅ [CommunityCubit] Comment added');

        // Update post comments count
        final updatedPosts = state.posts.map((post) {
          if (post.id == postId) {
            return post.copyWith(commentsCount: post.commentsCount + 1);
          }
          return post;
        }).toList();

        // Reload comments
        loadComments(postId);

        // Update posts list
        emit(CommunityCommentsLoaded(updatedPosts, state.comments));
      },
    );
  }
}
