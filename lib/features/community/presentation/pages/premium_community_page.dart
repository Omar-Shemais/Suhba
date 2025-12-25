import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/routes/app_routes.dart';
import '../cubits/community/community_cubit.dart';
import '../cubits/community/community_state.dart';
import '../widgets/premium_post_card.dart';
import '../utils/community_styles.dart';
import 'premium_create_post_page.dart';

class PremiumCommunityPage extends StatefulWidget {
  const PremiumCommunityPage({super.key});

  @override
  State<PremiumCommunityPage> createState() => _PremiumCommunityPageState();
}

class _PremiumCommunityPageState extends State<PremiumCommunityPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {});
      }
    });
    _checkAuthAndLoad();
    _scrollController.addListener(_onScroll);
  }

  void _checkAuthAndLoad() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Navigate directly to welcome page instead of showing dialog
        context.go(AppRoutes.welcome);
      });
    } else {
      // Only load if posts are empty (use cache if available)
      final cubit = context.read<CommunityCubit>();
      if (cubit.state.posts.isEmpty) {
        cubit.loadPosts(refresh: true);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<CommunityCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: user == null ? _buildLoginRequired() : _buildCommunityContent(),
    );
  }

  Widget _buildCommunityContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<CommunityCubit>().refreshFeed();
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          _buildSliverAppBar(),
          _buildSliverTabBar(),
          _buildContentList(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 140.h,
      floating: true,
      pinned: false,
      snap: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
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
          child: Stack(
            children: [
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200.w,
                  height: 200.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .1),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 150.w,
                  height: 150.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .05),
                  ),
                ),
              ),
              Positioned(
                top: 60,
                left: context.locale.languageCode == 'ar' ? null : 20,
                right: context.locale.languageCode == 'ar' ? 20 : null,
                child: Column(
                  crossAxisAlignment: context.locale.languageCode == 'ar'
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      'community'.tr(),
                      style: TextStyle(
                        color: isDark
                            ? theme.colorScheme.onSurface
                            : Colors.white,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'share_connect_with_muslims'.tr(),
                      style: TextStyle(
                        color: isDark
                            ? theme.colorScheme.onSurfaceVariant
                            : Colors.white.withValues(alpha: .9),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        collapseMode: CollapseMode.parallax,
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.primaryContainer
                  : Colors.white.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.add_rounded,
              color: isDark
                  ? theme.colorScheme.onPrimaryContainer
                  : Colors.white,
              size: 20,
            ),
          ),
          onPressed: () {
            final cubit = context.read<CommunityCubit>();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    BlocProvider.value(
                      value: cubit,
                      child: const PremiumCreatePostPage(),
                    ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
              ),
            );
          },
        ),
        IconButton(
          icon: Stack(
            children: [
              Icon(
                Icons.notifications_rounded,
                color: isDark ? theme.colorScheme.onSurface : Colors.white,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('coming_soon_notifications'.tr())),
            );
          },
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildSliverTabBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverPersistentHeader(
      pinned: false,
      floating: true,
      delegate: _TabBarDelegate(
        theme: theme,
        isDark: isDark,
        tabBar: TabBar(
          controller: _tabController,
          labelColor: isDark ? theme.colorScheme.onPrimary : Colors.white,
          unselectedLabelColor: isDark
              ? theme.colorScheme.onSurfaceVariant
              : AppColors.brownPrimary,
          indicator: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  )
                : AppColors.goldenTripleGradient,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? theme.colorScheme.primary.withValues(alpha: .2)
                    : AppColors.goldenPrimary.withValues(alpha: .3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15.sp,
          ),
          tabs: [
            Tab(text: 'community_feed'.tr()),
            Tab(text: 'my_posts'.tr()),
          ],
        ),
      ),
    );
  }

  Widget _buildContentList() {
    return BlocConsumer<CommunityCubit, CommunityState>(
      listener: (context, state) {
        if (state is CommunityError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );
        }
        if (state is CommunityPostCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 12.w),
                  Text('${'post_created_successfully'.tr()} ✅'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        if (state is CommunityLoading) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
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
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? theme.colorScheme.primary.withValues(alpha: .2)
                              : AppColors.goldenPrimary.withValues(alpha: .3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: CircularProgressIndicator(
                      color: isDark
                          ? theme.colorScheme.onPrimary
                          : Colors.white,
                      strokeWidth: 3.w,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'loading_amazing_content'.tr(),
                    style: TextStyle(
                      color: isDark
                          ? theme.colorScheme.onSurfaceVariant
                          : AppColors.brownSecondary.withValues(alpha: .7),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.posts.isEmpty) {
          return _buildEmptyState();
        }

        final user = FirebaseAuth.instance.currentUser;
        final filteredPosts = _tabController.index == 1 && user != null
            ? state.posts.where((post) => post.userId == user.uid).toList()
            : state.posts;

        if (filteredPosts.isEmpty) {
          return _buildEmptyState();
        }

        return SliverPadding(
          padding: const EdgeInsets.only(top: 16, bottom: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < filteredPosts.length) {
                  final post = filteredPosts[index];
                  return PremiumPostCard(
                    post: post,
                    showMyPostBadge: _tabController.index == 1,
                    onLike: () {
                      context.read<CommunityCubit>().toggleLike(post.id);
                    },
                    onDelete: () {
                      _showDeleteDialog(post.id);
                    },
                  );
                }
                if (state is CommunityLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.goldenPrimary,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              childCount:
                  filteredPosts.length +
                  (state is CommunityLoadingMore ? 1 : 0),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          theme.colorScheme.primary.withValues(alpha: .2),
                          theme.colorScheme.primary.withValues(alpha: .1),
                        ]
                      : [
                          AppColors.goldenPrimary.withValues(alpha: .1),
                          AppColors.goldenSecondary.withValues(alpha: .05),
                        ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_rounded,
                size: 80,
                color: isDark
                    ? theme.colorScheme.onSurfaceVariant
                    : AppColors.brownSecondary.withValues(alpha: .5),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              _tabController.index == 1
                  ? 'no_posts_yet'.tr()
                  : 'no_posts_in_community'.tr(),
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? theme.colorScheme.onSurface
                    : AppColors.brownPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              _tabController.index == 1
                  ? 'create_your_first_post'.tr()
                  : 'be_first_to_post'.tr(),
              style: TextStyle(
                fontSize: 15.sp,
                color: isDark
                    ? theme.colorScheme.onSurfaceVariant
                    : AppColors.brownSecondary.withValues(alpha: .8),
              ),
            ),
            SizedBox(height: 32.h),
            _buildCreatePostButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePostButton() {
    return Container(
      decoration: CommunityStyles.floatingButton(),
      child: ElevatedButton.icon(
        onPressed: () {
          final cubit = context.read<CommunityCubit>();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  BlocProvider.value(
                    value: cubit,
                    child: const PremiumCreatePostPage(),
                  ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
            ),
          );
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'create_post'.tr(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginRequired() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    )
                  : AppColors.goldenTripleGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? theme.colorScheme.primary.withValues(alpha: .2)
                      : AppColors.goldenPrimary.withValues(alpha: .3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.lock_rounded,
              size: 80,
              color: isDark ? theme.colorScheme.onPrimary : Colors.white,
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            'must_login'.tr(),
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? theme.colorScheme.onSurface
                  : AppColors.brownPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'login_to_access_community'.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              color: isDark
                  ? theme.colorScheme.onSurfaceVariant
                  : AppColors.brownSecondary.withValues(alpha: .8),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String postId) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.red, size: 28),
              SizedBox(width: 12.w),
              Text('delete_post'.tr()),
            ],
          ),
          content: Text('confirm_delete_post'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.red, Color(0xFFD32F2F)],
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<CommunityCubit>().deletePost(postId);
                },
                child: Text(
                  'delete'.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final ThemeData theme;
  final bool isDark;

  _TabBarDelegate({
    required this.tabBar,
    required this.theme,
    required this.isDark,
  });

  @override
  double get minExtent => 70;

  @override
  double get maxExtent => 70;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.scaffoldBackgroundColor
            : AppColors.backgroundLight1,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: isDark
                ? theme.colorScheme.outline.withValues(alpha: .3)
                : AppColors.goldenPrimary.withValues(alpha: .2),
            width: 1.w,
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}
