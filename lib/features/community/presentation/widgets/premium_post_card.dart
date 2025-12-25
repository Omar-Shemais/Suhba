import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:islamic_app/core/constants/app_colors.dart';
import '../../domain/entities/post_entity.dart';
import '../cubits/community/community_cubit.dart';
import '../pages/premium_post_detail_page.dart';
import '../utils/community_styles.dart';
import '../utils/community_animations.dart';

class PremiumPostCard extends StatefulWidget {
  final PostEntity post;
  final VoidCallback? onLike;
  final VoidCallback? onDelete;
  final bool showMyPostBadge;

  const PremiumPostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onDelete,
    this.showMyPostBadge = false,
  });

  @override
  State<PremiumPostCard> createState() => _PremiumPostCardState();
}

class _PremiumPostCardState extends State<PremiumPostCard>
    with SingleTickerProviderStateMixin {
  bool _showFloatingHeart = false;
  late AnimationController _cardController;
  late Animation<double> _scaleAnimation;
  PageController? _mediaController;
  int _currentMediaIndex = 0;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeInOut),
    );
    _initializeMediaController();
  }

  @override
  void dispose() {
    _mediaController?.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PremiumPostCard oldWidget) {
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

  void _initializeMediaController() {
    if (widget.post.mediaUrls.length > 1) {
      _mediaController = PageController();
    }
  }

  void _handleTap() {
    _cardController.forward().then((_) => _cardController.reverse());
    final cubit = context.read<CommunityCubit>();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) =>
            BlocProvider.value(
              value: cubit,
              child: PremiumPostDetailPage(post: widget.post),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _handleLike() {
    if (!widget.post.isLikedByMe) {
      setState(() {
        _showFloatingHeart = true;
      });
    }
    widget.onLike?.call();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser?.uid == widget.post.userId;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: widget.showMyPostBadge && isOwner
            ? (isDark
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22.r),
                    )
                  : CommunityStyles.gradientBorder(
                      borderRadius: 22,
                      borderwidth: 2.w,
                    ))
            : null,
        child: Container(
          margin: widget.showMyPostBadge && isOwner
              ? const EdgeInsets.all(2)
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: .2)
                    : AppColors.goldenPrimary.withValues(alpha: .15),
                blurRadius: 25,
                offset: const Offset(0, 10),
                spreadRadius: -8,
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(20.r),
              splashColor:
                  (isDark ? theme.colorScheme.primary : AppColors.goldenPrimary)
                      .withValues(alpha: .1),
              highlightColor:
                  (isDark ? theme.colorScheme.primary : AppColors.goldenPrimary)
                      .withValues(alpha: .05),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(isOwner, theme, isDark),
                    SizedBox(height: 14.h),
                    _buildContent(theme, isDark),
                    if (widget.post.mediaUrls.isNotEmpty) ...[
                      SizedBox(height: 14.h),
                      _buildMedia(),
                    ],
                    SizedBox(height: 14.h),
                    _buildStats(theme, isDark),
                    SizedBox(height: 12.h),
                    _buildDivider(theme, isDark),
                    SizedBox(height: 12.h),
                    _buildActions(theme, isDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isOwner, ThemeData theme, bool isDark) {
    return Row(
      children: [
        _buildAvatar(theme, isDark),
        SizedBox(width: 12.w),
        Expanded(child: _buildUserInfo(theme, isDark)),
        if (widget.showMyPostBadge && isOwner) _buildMyPostBadge(theme, isDark),
      ],
    );
  }

  Widget _buildAvatar(ThemeData theme, bool isDark) {
    return Stack(
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
            radius: 24,
            backgroundColor: isDark
                ? theme.colorScheme.surface
                : AppColors.backgroundLight1,
            backgroundImage: widget.post.userAvatar != null
                ? CachedNetworkImageProvider(widget.post.userAvatar!)
                : null,
            child: widget.post.userAvatar == null
                ? Text(
                    widget.post.userName[0].toUpperCase(),
                    style: TextStyle(
                      color: isDark
                          ? theme.colorScheme.onSurface
                          : AppColors.brownPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  )
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 14.w,
            height: 14.h,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(ThemeData theme, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                widget.post.userName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: isDark
                      ? theme.colorScheme.onSurface
                      : AppColors.brownPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.verified,
              size: 16,
              color: isDark
                  ? theme.colorScheme.primary
                  : AppColors.goldenPrimary,
            ),
          ],
        ),
        SizedBox(height: 3.h),
        Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 13,
              color: isDark
                  ? theme.colorScheme.onSurfaceVariant
                  : AppColors.brownSecondary.withValues(alpha: .7),
            ),
            SizedBox(width: 4.w),
            Text(
              timeago.format(widget.post.createdAt, locale: 'en_short'),
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark
                    ? theme.colorScheme.onSurfaceVariant
                    : AppColors.brownSecondary.withValues(alpha: .7),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.post.viewsCount > 0) ...[
              SizedBox(width: 12.w),
              Icon(
                Icons.visibility_rounded,
                size: 13,
                color: isDark
                    ? theme.colorScheme.onSurfaceVariant
                    : AppColors.brownSecondary.withValues(alpha: .6),
              ),
              SizedBox(width: 4.w),
              Text(
                _formatCount(widget.post.viewsCount),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark
                      ? theme.colorScheme.onSurfaceVariant
                      : AppColors.brownSecondary.withValues(alpha: .7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMyPostBadge(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
              )
            : AppColors.goldenTripleGradient,
        borderRadius: BorderRadius.circular(12.r),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 14,
            color: isDark ? theme.colorScheme.onPrimary : Colors.white,
          ),
          SizedBox(width: 4.w),
          Text(
            'Your Post',
            style: TextStyle(
              color: isDark ? theme.colorScheme.onPrimary : Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDark) {
    return Text(
      widget.post.content,
      maxLines: 8,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 15.sp,
        height: 1.5.h,
        color: isDark ? theme.colorScheme.onSurface : AppColors.brownPrimary,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildMedia() {
    final mediaUrls = widget.post.mediaUrls;
    final mediaType = widget.post.mediaType;

    if (mediaUrls.isEmpty && mediaType != MediaType.video) {
      return const SizedBox.shrink();
    }

    Widget buildImage(String url) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 220.h,
        placeholder: (context, value) => Container(
          height: 220.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.backgroundLight1, AppColors.backgroundLight2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.goldenPrimary,
              strokeWidth: 2.w,
            ),
          ),
        ),
        errorWidget: (context, value, error) => Container(
          height: 220.h,
          color: AppColors.backgroundLight1,
          child: const Center(
            child: Icon(Icons.error, color: AppColors.brownSecondary),
          ),
        ),
      );
    }

    Widget buildVideoPlaceholder() {
      return Container(
        height: 220.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.brownPrimary.withValues(alpha: .8),
              AppColors.brownSecondary.withValues(alpha: .6),
            ],
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3.w),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              size: 48,
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
            height: 220.h,
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
            top: 12,
            right: 12,
            child: _buildMediaBadge(mediaType, mediaUrls.length),
          ),
          if (mediaUrls.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(mediaUrls.length, (index) {
                  final isActive = index == _currentMediaIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 14 : 8,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: .5),
                      borderRadius: BorderRadius.circular(4.r),
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
      borderRadius: BorderRadius.circular(10.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .3),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: .2),
              width: 1.w,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme, bool isDark) {
    return Container(
      height: 1.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            (isDark ? theme.colorScheme.outline : AppColors.brownSecondary)
                .withValues(alpha: .2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildStats(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Loved
          Text(
            '${_formatCount(widget.post.likesCount)} ${'loved'.tr()}',
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark
                  ? theme.colorScheme.onSurfaceVariant
                  : AppColors.brownSecondary.withValues(alpha: .7),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 16.w),
          // Comments
          Text(
            '${_formatCount(widget.post.commentsCount)} ${'comments'.tr()}',
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark
                  ? theme.colorScheme.onSurfaceVariant
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

  Widget _buildActions(ThemeData theme, bool isDark) {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(child: _buildLikeButton(theme, isDark)),
            Expanded(child: _buildCommentButton(theme, isDark)),
          ],
        ),
        if (_showFloatingHeart)
          Positioned(
            left: 40,
            bottom: 10,
            child: FloatingHeartAnimation(
              show: _showFloatingHeart,
              onComplete: () {
                setState(() {
                  _showFloatingHeart = false;
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _buildLikeButton(ThemeData theme, bool isDark) {
    return InkWell(
      onTap: _handleLike,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LikeAnimation(
              isLiked: widget.post.isLikedByMe,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.post.isLikedByMe
                      ? Colors.red.withValues(alpha: .1)
                      : (isDark
                            ? theme.colorScheme.surfaceContainerHighest
                            : AppColors.backgroundLight1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  widget.post.isLikedByMe
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 20,
                  color: widget.post.isLikedByMe
                      ? Colors.red
                      : (isDark
                            ? theme.colorScheme.onSurfaceVariant
                            : AppColors.brownSecondary),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'loved'.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                color: widget.post.isLikedByMe
                    ? Colors.red
                    : (isDark
                          ? theme.colorScheme.onSurface
                          : AppColors.brownPrimary),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentButton(ThemeData theme, bool isDark) {
    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : AppColors.backgroundLight1,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 20,
                color: isDark
                    ? theme.colorScheme.onSurfaceVariant
                    : AppColors.brownSecondary,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'comments'.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? theme.colorScheme.onSurface
                    : AppColors.brownPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
