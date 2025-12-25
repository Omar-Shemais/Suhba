import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import '../cubits/community/community_cubit.dart';
import '../cubits/community/community_state.dart';

class PremiumCreatePostPage extends StatefulWidget {
  const PremiumCreatePostPage({super.key});

  @override
  State<PremiumCreatePostPage> createState() => _PremiumCreatePostPageState();
}

class _PremiumCreatePostPageState extends State<PremiumCreatePostPage>
    with TickerProviderStateMixin {
  final _contentController = TextEditingController();
  final List<File> _selectedMedia = [];
  bool _isUploading = false;
  late AnimationController _pageController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _pageController, curve: Curves.easeOutCubic),
        );
    _pageController.forward();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_selectedMedia.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('max_5_images'.tr()),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        for (var file in pickedFiles) {
          if (_selectedMedia.length < 5) {
            _selectedMedia.add(File(file.path));
          }
        }
      });
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  Future<void> _submitPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white),
              SizedBox(width: 12.w),
              Text('الرجاء كتابة محتوى المنشور'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final mediaPaths = _selectedMedia.isNotEmpty
        ? _selectedMedia.map((f) => f.path).toList()
        : null;

    context.read<CommunityCubit>().createPost(
      content: _contentController.text.trim(),
      mediaPaths: mediaPaths,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<CommunityCubit, CommunityState>(
        listener: (context, state) {
          if (state is CommunityPostCreated) {
            _pageController.reverse().then((_) {
              Navigator.pop(context);
            });
          }
          if (state is CommunityError) {
            setState(() {
              _isUploading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildUserHeader(user),
                        _buildContentField(),
                        if (_selectedMedia.isNotEmpty) _buildMediaPreview(),
                        SizedBox(height: 100.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                ? theme.colorScheme.primaryContainer
                : Colors.white.withValues(alpha: .2),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.close_rounded,
            color: isDark ? theme.colorScheme.onPrimaryContainer : Colors.white,
            size: 20,
          ),
        ),
        onPressed: () {
          _pageController.reverse().then((_) {
            Navigator.pop(context);
          });
        },
      ),
      title: Text(
        'create_post'.tr(),
        style: TextStyle(
          color: isDark ? theme.colorScheme.onSurface : Colors.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        BlocBuilder<CommunityCubit, CommunityState>(
          builder: (context, state) {
            if (state is CommunityCreatingPost || _isUploading) {
              return Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5.w,
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Hero(
                tag: 'post_button',
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.colorScheme.primaryContainer
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _submitPost,
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Text(
                          'post'.tr(),
                          style: TextStyle(
                            color: isDark
                                ? theme.colorScheme.onPrimaryContainer
                                : AppColors.goldenPrimary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUserHeader(User? user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : AppColors.backgroundLight1,
              backgroundImage: user?.photoURL != null
                  ? CachedNetworkImageProvider(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? Icon(
                      Icons.person_rounded,
                      color: isDark
                          ? theme.colorScheme.onSurface
                          : AppColors.brownPrimary,
                      size: 32,
                    )
                  : null,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'user'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: isDark
                        ? theme.colorScheme.onSurface
                        : AppColors.brownPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  theme.colorScheme.primary.withValues(
                                    alpha: .3,
                                  ),
                                  theme.colorScheme.primary.withValues(
                                    alpha: .15,
                                  ),
                                ]
                              : [
                                  AppColors.goldenPrimary.withValues(alpha: .2),
                                  AppColors.goldenSecondary.withValues(
                                    alpha: .1,
                                  ),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.public_rounded,
                            size: 14,
                            color: isDark
                                ? theme.colorScheme.onSurfaceVariant
                                : AppColors.brownSecondary.withValues(
                                    alpha: .8,
                                  ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'public'.tr(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? theme.colorScheme.onSurfaceVariant
                                  : AppColors.brownSecondary.withValues(
                                      alpha: .8,
                                    ),
                            ),
                          ),
                        ],
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

  Widget _buildContentField() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
      child: TextField(
        controller: _contentController,
        decoration: InputDecoration(
          hintText: 'share_something_inspiring'.tr(),
          hintStyle: TextStyle(
            color: isDark
                ? theme.colorScheme.onSurfaceVariant.withValues(alpha: .5)
                : AppColors.brownSecondary.withValues(alpha: .5),
            fontSize: 16.sp,
          ),
          border: InputBorder.none,
        ),
        maxLines: null,
        minLines: 8,
        maxLength: 5000,
        style: TextStyle(
          fontSize: 16.sp,
          height: 1.6.h,
          color: isDark ? theme.colorScheme.onSurface : AppColors.brownPrimary,
        ),
        buildCounter:
            (context, {required currentLength, required isFocused, maxLength}) {
              return Container(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '$currentLength / $maxLength',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: currentLength > maxLength! * 0.9
                        ? Colors.red
                        : (isDark
                              ? theme.colorScheme.onSurfaceVariant.withValues(
                                  alpha: .6,
                                )
                              : AppColors.brownSecondary.withValues(alpha: .6)),
                  ),
                ),
              );
            },
      ),
    );
  }

  Widget _buildMediaPreview() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedMedia.length,
        itemBuilder: (context, index) {
          return Container(
            width: 160.w,
            margin: const EdgeInsets.only(right: 12),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.file(
                            _selectedMedia[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: .3),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  '${index + 1}/${_selectedMedia.length}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _removeMedia(index),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.red, Color(0xFFD32F2F)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: .4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surface.withValues(alpha: .9)
                : Colors.white.withValues(alpha: .9),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? theme.colorScheme.outline.withValues(alpha: .2)
                    : AppColors.brownSecondary.withValues(alpha: .1),
                width: 1.w,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                _buildMediaButton(
                  icon: Icons.image_rounded,
                  label: 'photo'.tr(),
                  color: isDark
                      ? theme.colorScheme.primary
                      : AppColors.goldenPrimary,
                  onTap: _isUploading ? null : _pickImage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: color.withValues(alpha: .3),
                width: 1.w,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 24),
                SizedBox(height: 4.h),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
