import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/services/supabase_storage_service.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';

/// Remote data source for Community feature
/// Handles all Supabase operations
abstract class CommunityRemoteDataSource {
  Future<List<PostModel>> getPosts({required int page, required int limit});
  Future<PostModel> getPostById(String postId);
  Future<PostModel> createPost({
    required String userId,
    String? title,
    required String content,
    List<String>? mediaPaths,
  });
  Future<void> deletePost({required String postId, required String userId});
  Future<List<PostModel>> searchPosts(String query);
  Future<List<CommentModel>> getComments({
    required String postId,
    required int page,
  });
  Future<CommentModel> addComment({
    required String postId,
    required String userId,
    required String content,
  });
  Future<void> deleteComment({
    required String commentId,
    required String userId,
  });
  Future<bool> toggleLike({required String postId, required String userId});
  Future<int> getLikesCount(String postId);
  Stream<PostModel> subscribeToNewPosts();
  Stream<CommentModel> subscribeToNewComments(String postId);
  Future<void> reportContent({
    required String targetTable,
    required String targetId,
    required String userId,
    required String reason,
  });
  Future<void> recordView({required String postId, required String userId});
}

class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final SupabaseClient client = SupabaseClientWrapper.client;
  final SupabaseStorageService storageService;

  CommunityRemoteDataSourceImpl({required this.storageService});

  @override
  Future<List<PostModel>> getPosts({
    required int page,
    required int limit,
  }) async {
    try {
      debugPrint('📥 [DataSource] Fetching posts page $page...');

      // Get current user ID from Firebase Auth
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      debugPrint('🔍 [DataSource] Current User ID: $currentUserId');

      final response = await client
          .from(SupabaseConstants.postsTable)
          .select('''
            *,
            users!inner(name, avatar_url)
          ''')
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .range(page * limit, (page + 1) * limit - 1);

      final posts = <PostModel>[];
      final postIds = (response as List)
          .map((json) => json['id'] as String)
          .toList();

      // Get all likes for these posts in one query
      Map<String, int> likesCountMap = {};
      Set<String> userLikedPosts = {};

      if (postIds.isNotEmpty) {
        // Get likes count for all posts
        final allLikes = await client
            .from(SupabaseConstants.likesTable)
            .select('post_id, user_id')
            .inFilter('post_id', postIds);

        // Count likes per post
        debugPrint(
          '🔍 [DataSource] Total likes fetched: ${(allLikes as List).length}',
        );
        for (final like in allLikes as List) {
          final postId = like['post_id'] as String;
          final likeUserId = like['user_id'] as String;
          likesCountMap[postId] = (likesCountMap[postId] ?? 0) + 1;

          // Track which posts current user liked
          if (currentUserId != null && likeUserId == currentUserId) {
            debugPrint('✅ [DataSource] User liked post: $postId');
            userLikedPosts.add(postId);
          }
        }
        debugPrint(
          '🔍 [DataSource] User liked ${userLikedPosts.length} posts: $userLikedPosts',
        );

        // Get comments count for all posts
        final allComments = await client
            .from(SupabaseConstants.commentsTable)
            .select('post_id')
            .inFilter('post_id', postIds)
            .eq('is_deleted', false);

        Map<String, int> commentsCountMap = {};
        for (final comment in allComments as List) {
          final postId = comment['post_id'] as String;
          commentsCountMap[postId] = (commentsCountMap[postId] ?? 0) + 1;
        }

        // Get views count for all posts
        final allViews = await client
            .from(SupabaseConstants.viewsTable)
            .select('post_id')
            .inFilter('post_id', postIds);

        Map<String, int> viewsCountMap = {};
        for (final view in allViews as List) {
          final postId = view['post_id'] as String;
          viewsCountMap[postId] = (viewsCountMap[postId] ?? 0) + 1;
        }

        // Build posts with counts
        for (final json in response as List) {
          final postData = Map<String, dynamic>.from(
            json as Map<String, dynamic>,
          );
          final postId = postData['id'] as String;

          postData['likes_count'] = likesCountMap[postId] ?? 0;
          postData['comments_count'] = commentsCountMap[postId] ?? 0;
          postData['views_count'] = viewsCountMap[postId] ?? 0;
          postData['is_liked_by_me'] = userLikedPosts.contains(postId);

          debugPrint(
            '📝 [DataSource] Post $postId: likes=${postData['likes_count']}, comments=${postData['comments_count']}, views=${postData['views_count']}, isLikedByMe=${postData['is_liked_by_me']}',
          );

          posts.add(PostModel.fromJson(postData));
        }
      }

      debugPrint('✅ [DataSource] Fetched ${posts.length} posts');
      return posts;
    } catch (e) {
      debugPrint('❌ [DataSource] Error fetching posts: $e');
      throw Exception('فشل تحميل المنشورات: $e');
    }
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    try {
      debugPrint('📥 [DataSource] Fetching post: $postId');

      final response = await client
          .from(SupabaseConstants.postsTable)
          .select('''
            *,
            users!inner(name, avatar_url)
          ''')
          .eq('id', postId)
          .single();

      return PostModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ [DataSource] Error fetching post: $e');
      throw Exception('فشل تحميل المنشور: $e');
    }
  }

  @override
  Future<PostModel> createPost({
    required String userId,
    String? title,
    required String content,
    List<String>? mediaPaths,
  }) async {
    try {
      debugPrint('📤 [DataSource] Creating post for user: $userId');

      final uploadedMediaUrls = <String>[];

      // 1. Upload media if exists
      if (mediaPaths != null && mediaPaths.isNotEmpty) {
        for (final path in mediaPaths.where((path) => path.isNotEmpty)) {
          debugPrint('📤 [DataSource] Uploading media: $path');
          final uploadedUrl = await storageService.uploadFile(
            bucketName: SupabaseConstants.communityMediaBucket,
            filePath: path,
            userId: userId,
          );
          uploadedMediaUrls.add(uploadedUrl);
        }
        debugPrint(
          '✅ [DataSource] Uploaded ${uploadedMediaUrls.length} media files',
        );
      }

      String? primaryMediaUrl;
      String? mediaType;
      if (uploadedMediaUrls.isNotEmpty) {
        primaryMediaUrl = uploadedMediaUrls.first;
        mediaType = _resolveMediaType(mediaPaths?.first ?? '');
      }

      final insertPayload = <String, dynamic>{
        'user_id': userId,
        'title': title,
        'content': content,
        'media_url': _encodeMediaField(uploadedMediaUrls, primaryMediaUrl),
        'media_type': mediaType,
      };

      if (uploadedMediaUrls.length > 1) {
        insertPayload['media_urls'] = uploadedMediaUrls;
      }

      Future<PostModel> insertPost(Map<String, dynamic> payload) async {
        final response = await client
            .from(SupabaseConstants.postsTable)
            .insert(payload)
            .select('''
              *,
              users!inner(name, avatar_url)
            ''')
            .single();
        return PostModel.fromJson(response);
      }

      try {
        final post = await insertPost(insertPayload);
        debugPrint('✅ [DataSource] Post created');
        return post;
      } catch (error) {
        final errorMessage = error.toString();
        final shouldRetryWithoutMediaArray =
            uploadedMediaUrls.length > 1 && errorMessage.contains('media_urls');

        if (shouldRetryWithoutMediaArray) {
          debugPrint(
            '⚠️ [DataSource] media_urls column unavailable, retrying with JSON string',
          );
          final fallbackPayload = Map<String, dynamic>.from(insertPayload)
            ..remove('media_urls')
            ..['media_url'] = jsonEncode(uploadedMediaUrls);
          final post = await insertPost(fallbackPayload);
          debugPrint('✅ [DataSource] Post created with fallback payload');
          return post;
        }

        rethrow;
      }
    } catch (e) {
      debugPrint('❌ [DataSource] Error creating post: $e');
      throw Exception('فشل إنشاء المنشور: $e');
    }
  }

  @override
  Future<void> deletePost({
    required String postId,
    required String userId,
  }) async {
    try {
      debugPrint('🗑️ [DataSource] Deleting post: $postId');

      // Soft delete
      await client
          .from(SupabaseConstants.postsTable)
          .update({'is_deleted': true})
          .eq('id', postId)
          .eq('user_id', userId);

      debugPrint('✅ [DataSource] Post deleted');
    } catch (e) {
      debugPrint('❌ [DataSource] Error deleting post: $e');
      throw Exception('فشل حذف المنشور: $e');
    }
  }

  @override
  Future<List<PostModel>> searchPosts(String query) async {
    try {
      debugPrint('🔍 [DataSource] Searching posts: $query');

      final response = await client
          .from(SupabaseConstants.postsTable)
          .select('''
            *,
            users!inner(name, avatar_url)
          ''')
          .textSearch('search_vector', query, config: 'english')
          .eq('is_deleted', false)
          .limit(50);

      final posts = (response as List)
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('✅ [DataSource] Found ${posts.length} posts');
      return posts;
    } catch (e) {
      debugPrint('❌ [DataSource] Error searching: $e');
      throw Exception('فشل البحث: $e');
    }
  }

  @override
  Future<List<CommentModel>> getComments({
    required String postId,
    required int page,
  }) async {
    try {
      debugPrint('📥 [DataSource] Fetching comments for post: $postId');

      final response = await client
          .from(SupabaseConstants.commentsTable)
          .select('''
            *,
            users!inner(name, avatar_url)
          ''')
          .eq('post_id', postId)
          .eq('is_deleted', false)
          .order('created_at', ascending: true)
          .range(
            page * SupabaseConstants.commentsPerPage,
            (page + 1) * SupabaseConstants.commentsPerPage - 1,
          );

      final comments = (response as List)
          .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('✅ [DataSource] Fetched ${comments.length} comments');
      return comments;
    } catch (e) {
      debugPrint('❌ [DataSource] Error fetching comments: $e');
      throw Exception('فشل تحميل التعليقات: $e');
    }
  }

  @override
  Future<CommentModel> addComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    try {
      debugPrint('📤 [DataSource] Adding comment...');

      final response = await client
          .from(SupabaseConstants.commentsTable)
          .insert({'post_id': postId, 'user_id': userId, 'content': content})
          .select('''
            *,
            users!inner(name, avatar_url)
          ''')
          .single();

      debugPrint('✅ [DataSource] Comment added');
      return CommentModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ [DataSource] Error adding comment: $e');
      throw Exception('فشل إضافة التعليق: $e');
    }
  }

  @override
  Future<void> deleteComment({
    required String commentId,
    required String userId,
  }) async {
    try {
      debugPrint('🗑️ [DataSource] Deleting comment: $commentId');

      // Soft delete
      await client
          .from(SupabaseConstants.commentsTable)
          .update({'is_deleted': true})
          .eq('id', commentId)
          .eq('user_id', userId);

      debugPrint('✅ [DataSource] Comment deleted');
    } catch (e) {
      debugPrint('❌ [DataSource] Error deleting comment: $e');
      throw Exception('فشل حذف التعليق: $e');
    }
  }

  @override
  Future<bool> toggleLike({
    required String postId,
    required String userId,
  }) async {
    try {
      debugPrint('❤️ [DataSource] Toggling like...');

      // Check if already liked
      final existing = await client
          .from(SupabaseConstants.likesTable)
          .select()
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        // Unlike
        await client
            .from(SupabaseConstants.likesTable)
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);

        debugPrint('✅ [DataSource] Post unliked');
        return false;
      } else {
        // Like
        await client.from(SupabaseConstants.likesTable).insert({
          'post_id': postId,
          'user_id': userId,
        });

        debugPrint('✅ [DataSource] Post liked');
        return true;
      }
    } catch (e) {
      debugPrint('❌ [DataSource] Error toggling like: $e');
      throw Exception('فشل تحديث الإعجاب: $e');
    }
  }

  @override
  Future<int> getLikesCount(String postId) async {
    try {
      final response = await client
          .from(SupabaseConstants.likesTable)
          .select()
          .eq('post_id', postId)
          .count();

      return response.count;
    } catch (e) {
      debugPrint('❌ [DataSource] Error getting likes count: $e');
      return 0;
    }
  }

  @override
  Stream<PostModel> subscribeToNewPosts() {
    return client
        .from(SupabaseConstants.postsTable)
        .stream(primaryKey: ['id'])
        .map((data) {
          // Filter non-deleted posts
          final posts = data
              .where((item) => item['is_deleted'] == false)
              .toList();

          if (posts.isEmpty) {
            throw Exception('No posts available');
          }

          return PostModel.fromJson(posts.first);
        });
  }

  @override
  Stream<CommentModel> subscribeToNewComments(String postId) {
    return client
        .from(SupabaseConstants.commentsTable)
        .stream(primaryKey: ['id'])
        .map((data) {
          // Filter comments for specific post
          final comments = data
              .where(
                (item) =>
                    item['post_id'] == postId && item['is_deleted'] == false,
              )
              .toList();

          if (comments.isEmpty) {
            throw Exception('No comments available');
          }

          return CommentModel.fromJson(comments.first);
        });
  }

  @override
  Future<void> reportContent({
    required String targetTable,
    required String targetId,
    required String userId,
    required String reason,
  }) async {
    try {
      debugPrint('🚨 [DataSource] Reporting content...');

      await client.from(SupabaseConstants.reportsTable).insert({
        'target_table': targetTable,
        'target_id': targetId,
        'user_id': userId,
        'reason': reason,
      });

      debugPrint('✅ [DataSource] Content reported');
    } catch (e) {
      debugPrint('❌ [DataSource] Error reporting: $e');
      throw Exception('فشل الإبلاغ: $e');
    }
  }

  @override
  Future<void> recordView({
    required String postId,
    required String userId,
  }) async {
    try {
      debugPrint('👁️ [DataSource] Recording view for post: $postId');

      // Insert or ignore (unique constraint handles duplicates)
      await client.from(SupabaseConstants.viewsTable).upsert({
        'post_id': postId,
        'user_id': userId,
      }, onConflict: 'post_id,user_id');

      debugPrint('✅ [DataSource] View recorded');
    } catch (e) {
      debugPrint('❌ [DataSource] Error recording view: $e');
      // Don't throw - views are not critical
    }
  }

  String? _resolveMediaType(String path) {
    if (path.isEmpty) return null;
    final extension = path.split('.').last.toLowerCase();

    if (SupabaseConstants.allowedImageExtensions.contains(extension)) {
      return 'image';
    }
    if (SupabaseConstants.allowedVideoExtensions.contains(extension)) {
      return 'video';
    }
    return null;
  }

  String? _encodeMediaField(List<String> mediaUrls, String? primaryMediaUrl) {
    if (mediaUrls.isEmpty) return null;
    return primaryMediaUrl ?? mediaUrls.first;
  }
}
