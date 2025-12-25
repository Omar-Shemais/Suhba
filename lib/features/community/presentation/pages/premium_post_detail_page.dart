import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../data/repositories/community_repository_impl.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../cubits/community/community_cubit.dart';
import '../cubits/community/community_state.dart';

class PremiumPostDetailPage extends StatefulWidget {
  final PostEntity post;

  const PremiumPostDetailPage({super.key, required this.post});

  @override
  State<PremiumPostDetailPage> createState() => _PremiumPostDetailPageState();
}

class _PremiumPostDetailPageState extends State<PremiumPostDetailPage>
    with TickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  PageController? _mediaController;
  int _currentMediaIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeMediaController();
    context.read<CommunityCubit>().loadComments(widget.post.id);
    _recordView();
  }

  void _recordView() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final repo = GetIt.instance<CommunityRepositoryImpl>();
      await repo.recordView(postId: widget.post.id, userId: user.uid);
      if (mounted) {
        context.read<CommunityCubit>().refreshFeed();
      }
    } catch (e) {
      // Ignore
    }
  }

  void _initializeMediaController() {
    if (widget.post.mediaUrls.length > 1) {
      _mediaController = PageController();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    _mediaController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PremiumPostDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldCount = oldWidget.post.mediaUrls.length;
    final newCount = widget.post.mediaUrls.length;
    if (oldWidget.post.id != widget.post.id || oldCount != newCount) {
      _mediaController?.dispose();
      _mediaController = null;
      _currentMediaIndex = 0;
      _initializeMediaController();
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;

    context.read<CommunityCubit>().addComment(
      postId: widget.post.id,
      content: _commentController.text.trim(),
    );
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(theme, isDark),
          SliverToBoxAdapter(child: _buildPostContent(theme, isDark)),
          _buildCommentsList(theme, isDark),
        ],
      ),
      bottomNavigationBar: _buildCommentInput(theme, isDark),
    );
  }

  Widget _buildAppBar(ThemeData theme, bool isDark) {
    return SliverAppBar(
      expandedHeight: 80.h,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withValues(alpha: 0.95),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [
                    AppColors.goldenPrimary,
                    AppColors.goldenSecondary,
                    Color(0xFFA86B0D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.onSurface.withValues(alpha: .1)
                : Colors.white.withValues(alpha: .2),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? theme.colorScheme.onSurface : Colors.white,
            size: 20,
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        'Post Details',
        style: TextStyle(
          color: isDark ? theme.colorScheme.onSurface : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
        ),
      ),
      actions: [SizedBox(width: 8.w)],
    );
  }

  Widget _buildPostContent(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: .2)
                : AppColors.goldenPrimary.withValues(alpha: .15),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPostHeader(theme, isDark),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.content,
                  style: TextStyle(
                    fontSize: 16.sp,
                    height: 1.6.h,
                    color: isDark
                        ? theme.colorScheme.onSurface
                        : AppColors.brownPrimary,
                  ),
                  maxLines: null,
                  overflow: TextOverflow.clip,
                ),
                if (widget.post.mediaUrls.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  _buildMedia(theme, isDark),
                ],
                SizedBox(height: 16.h),
                _buildPostStats(theme, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : LinearGradient(
                colors: [
                  AppColors.goldenPrimary.withValues(alpha: .1),
                  AppColors.goldenSecondary.withValues(alpha: .05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isDark ? theme.colorScheme.surface.withValues(alpha: 0.5) : null,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isDark
                  ? LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    )
                  : AppColors.goldenTripleGradient,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? theme.colorScheme.primary.withValues(alpha: .2)
                      : AppColors.goldenPrimary.withValues(alpha: .3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: isDark
                  ? theme.colorScheme.surface
                  : Colors.white,
              backgroundImage: widget.post.userAvatar != null
                  ? CachedNetworkImageProvider(widget.post.userAvatar!)
                  : null,
              child: widget.post.userAvatar == null
                  ? Text(
                      widget.post.userName[0].toUpperCase(),
                      style: TextStyle(
                        color: isDark
                            ? theme.colorScheme.primary
                            : AppColors.goldenPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.post.userName,
                        style: TextStyle(
                          color: isDark
                              ? theme.colorScheme.onSurface
                              : AppColors.brownPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 17.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.verified,
                      size: 18,
                      color: isDark
                          ? theme.colorScheme.primary
                          : AppColors.goldenPrimary,
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: isDark
                          ? theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: .7,
                            )
                          : AppColors.brownSecondary.withValues(alpha: .7),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      timeago.format(widget.post.createdAt, locale: 'en'),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark
                            ? theme.colorScheme.onSurfaceVariant.withValues(
                                alpha: .7,
                              )
                            : AppColors.brownSecondary.withValues(alpha: .7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedia(ThemeData theme, bool isDark) {
    final mediaUrls = widget.post.mediaUrls;
    final mediaType = widget.post.mediaType;

    Widget buildImage(String url) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (context, value) => Container(
          height: 250.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface.withValues(alpha: 0.8),
                    ]
                  : [AppColors.backgroundLight1, AppColors.backgroundLight2],
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: isDark
                  ? theme.colorScheme.primary
                  : AppColors.goldenPrimary,
            ),
          ),
        ),
        errorWidget: (context, value, error) => Container(
          height: 250.h,
          color: isDark
              ? theme.colorScheme.surface
              : AppColors.backgroundLight1,
          child: Center(
            child: Icon(
              Icons.error,
              color: isDark
                  ? theme.colorScheme.onSurfaceVariant
                  : AppColors.brownSecondary,
            ),
          ),
        ),
      );
    }

    Widget buildVideoPlaceholder() {
      return Container(
        height: 250.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    theme.colorScheme.surface.withValues(alpha: .9),
                    theme.colorScheme.surface.withValues(alpha: .7),
                  ]
                : [
                    AppColors.brownPrimary.withValues(alpha: .8),
                    AppColors.brownSecondary.withValues(alpha: .6),
                  ],
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    final mediaContent = mediaType == MediaType.video
        ? buildVideoPlaceholder()
        : mediaUrls.length > 1
        ? SizedBox(
            height: 250.h,
            child: PageView.builder(
              controller: _mediaController,
              itemCount: mediaUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentMediaIndex = index;
                });
              },
              itemBuilder: (context, index) => buildImage(mediaUrls[index]),
            ),
          )
        : buildImage(mediaUrls.first);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Stack(
        children: [
          mediaContent,
          Positioned(
            top: 16,
            right: 16,
            child: _buildMediaBadge(mediaType, mediaUrls.length),
          ),
          if (mediaUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(mediaUrls.length, (index) {
                  final isActive = index == _currentMediaIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 16 : 10,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: .5),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaBadge(MediaType? mediaType, int totalMedia) {
    final isVideo = mediaType == MediaType.video;
    final icon = isVideo ? Icons.videocam_rounded : Icons.image_rounded;
    final label = isVideo
        ? 'Video'
        : totalMedia > 1
        ? '${_currentMediaIndex + 1}/$totalMedia'
        : 'Photo';

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .35),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: .2),
              width: 1.w,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsList(ThemeData theme, bool isDark) {
    return BlocBuilder<CommunityCubit, CommunityState>(
      builder: (context, state) {
        if (state is CommunityLoadingComments) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(
                  color: isDark
                      ? theme.colorScheme.primary
                      : AppColors.goldenPrimary,
                ),
              ),
            ),
          );
        }

        if (state.comments.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: isDark ? theme.colorScheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: .2)
                        : AppColors.goldenPrimary.withValues(alpha: .15),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.primary.withValues(alpha: .15)
                          : AppColors.goldenPrimary.withValues(alpha: .1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 50,
                      color: isDark
                          ? theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: .5,
                            )
                          : AppColors.brownSecondary.withValues(alpha: .5),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No comments yet',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? theme.colorScheme.onSurface
                          : AppColors.brownPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Be the first to comment!',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark
                          ? theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: .7,
                            )
                          : AppColors.brownSecondary.withValues(alpha: .7),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12, top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_rounded,
                        size: 20,
                        color: isDark
                            ? theme.colorScheme.primary
                            : AppColors.goldenPrimary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Comments (${state.comments.length})',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? theme.colorScheme.onSurface
                              : AppColors.brownPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final comment = state.comments[index - 1];
              return _CommentBubble(comment: comment);
            }, childCount: state.comments.length + 1),
          ),
        );
      },
    );
  }

  Widget _buildPostStats(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? theme.colorScheme.outline.withValues(alpha: .2)
                : AppColors.brownSecondary.withValues(alpha: .1),
            width: 1.w,
          ),
          bottom: BorderSide(
            color: isDark
                ? theme.colorScheme.outline.withValues(alpha: .2)
                : AppColors.brownSecondary.withValues(alpha: .1),
            width: 1.w,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Loved
          Text(
            '${_formatCount(widget.post.likesCount)} loved',
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark
                  ? theme.colorScheme.onSurfaceVariant.withValues(alpha: .7)
                  : AppColors.brownSecondary.withValues(alpha: .7),
              fontWeight: FontWeight.w500,
            ),
          ),
          // Comments
          Text(
            '${_formatCount(widget.post.commentsCount)} comments',
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark
                  ? theme.colorScheme.onSurfaceVariant.withValues(alpha: .7)
                  : AppColors.brownSecondary.withValues(alpha: .7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildCommentInput(ThemeData theme, bool isDark) {
    final user = FirebaseAuth.instance.currentUser;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isDark
                  ? null
                  : LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: .98),
                        Colors.white.withValues(alpha: .95),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
              color: isDark
                  ? theme.colorScheme.surface.withValues(alpha: 0.95)
                  : null,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? theme.colorScheme.outline.withValues(alpha: .3)
                      : AppColors.goldenPrimary.withValues(alpha: .2),
                  width: 1.w,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: .3)
                      : AppColors.goldenPrimary.withValues(alpha: .1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isDark
                          ? LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.8,
                                ),
                              ],
                            )
                          : AppColors.goldenTripleGradient,
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? theme.colorScheme.primary.withValues(alpha: .2)
                              : AppColors.goldenPrimary.withValues(alpha: .2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: isDark
                          ? theme.colorScheme.surface
                          : Colors.white,
                      backgroundImage: user?.photoURL != null
                          ? CachedNetworkImageProvider(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? Icon(
                              Icons.person,
                              color: isDark
                                  ? theme.colorScheme.primary
                                  : AppColors.goldenPrimary,
                              size: 18,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.surfaceContainerHighest
                            : AppColors.backgroundLight1,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isDark
                              ? theme.colorScheme.outline.withValues(alpha: .3)
                              : AppColors.goldenPrimary.withValues(alpha: .15),
                          width: 1.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _commentController,
                        focusNode: _commentFocusNode,
                        decoration: InputDecoration(
                          hintText: 'اكتب تعليق...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? theme.colorScheme.onSurfaceVariant.withValues(
                                    alpha: .5,
                                  )
                                : AppColors.brownSecondary.withValues(
                                    alpha: .4,
                                  ),
                            fontSize: 14.sp,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                        maxLines: null,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark
                              ? theme.colorScheme.onSurface
                              : AppColors.brownPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? null
                          : LinearGradient(
                              colors: [
                                AppColors.goldenPrimary,
                                AppColors.goldenSecondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      color: isDark ? theme.colorScheme.primary : null,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? theme.colorScheme.primary.withValues(alpha: .3)
                              : AppColors.goldenPrimary.withValues(alpha: .3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _submitComment,
                        borderRadius: BorderRadius.circular(12.r),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.send_rounded,
                            color: isDark
                                ? theme.colorScheme.onPrimary
                                : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommentBubble extends StatelessWidget {
  final CommentEntity comment;

  const _CommentBubble({required this.comment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    final isMyComment = user?.uid == comment.userId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMyComment
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMyComment) ...[
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isDark
                    ? LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.8),
                        ],
                      )
                    : AppColors.goldenTripleGradient,
              ),
              padding: const EdgeInsets.all(1.5),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: isDark
                    ? theme.colorScheme.surface
                    : Colors.white,
                backgroundImage: comment.userAvatar != null
                    ? CachedNetworkImageProvider(comment.userAvatar!)
                    : null,
                child: comment.userAvatar == null
                    ? Text(
                        comment.userName[0].toUpperCase(),
                        style: TextStyle(
                          color: isDark
                              ? theme.colorScheme.primary
                              : AppColors.goldenPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      )
                    : null,
              ),
            ),
            SizedBox(width: 10.w),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMyComment
                    ? (isDark
                          ? theme.colorScheme.primaryContainer
                          : AppColors.goldenPrimary.withValues(alpha: .15))
                    : (isDark
                          ? theme.colorScheme.surfaceContainerHighest
                          : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMyComment ? 18 : 4),
                  topRight: Radius.circular(isMyComment ? 4 : 18),
                  bottomLeft: Radius.circular(18.r),
                  bottomRight: Radius.circular(18.r),
                ),
                border: Border.all(
                  color: isMyComment
                      ? (isDark
                            ? theme.colorScheme.primary.withValues(alpha: .3)
                            : AppColors.goldenPrimary.withValues(alpha: .3))
                      : (isDark
                            ? theme.colorScheme.outline.withValues(alpha: .2)
                            : AppColors.brownSecondary.withValues(alpha: .1)),
                  width: 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMyComment
                        ? (isDark
                              ? theme.colorScheme.primary.withValues(alpha: .15)
                              : AppColors.goldenPrimary.withValues(alpha: .1))
                        : (isDark
                              ? Colors.black.withValues(alpha: .1)
                              : Colors.black.withValues(alpha: .05)),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          comment.userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: isMyComment
                                ? (isDark
                                      ? theme.colorScheme.onPrimaryContainer
                                      : AppColors.goldenSecondary)
                                : (isDark
                                      ? theme.colorScheme.onSurface
                                      : AppColors.brownPrimary),
                          ),
                        ),
                      ),
                      Text(
                        timeago.format(comment.createdAt, locale: 'en_short'),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark
                              ? theme.colorScheme.onSurfaceVariant.withValues(
                                  alpha: .6,
                                )
                              : AppColors.brownSecondary.withValues(alpha: .6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    comment.content,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.4.h,
                      color: isDark
                          ? theme.colorScheme.onSurface.withValues(alpha: .95)
                          : AppColors.brownPrimary.withValues(alpha: .95),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMyComment) ...[
            SizedBox(width: 10.w),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isDark
                    ? LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.8),
                        ],
                      )
                    : AppColors.goldenTripleGradient,
              ),
              padding: const EdgeInsets.all(1.5),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: isDark
                    ? theme.colorScheme.surface
                    : Colors.white,
                backgroundImage: comment.userAvatar != null
                    ? CachedNetworkImageProvider(comment.userAvatar!)
                    : null,
                child: comment.userAvatar == null
                    ? Text(
                        comment.userName[0].toUpperCase(),
                        style: TextStyle(
                          color: isDark
                              ? theme.colorScheme.primary
                              : AppColors.goldenPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
