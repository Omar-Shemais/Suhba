import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/constants/assets.dart';
import 'package:islamic_app/features/quran/data/helpers/ayah_share_manager.dart';
import 'package:islamic_app/features/quran/presentation/widgets/ayah_share_card.dart';

class AyahShareBottomSheet extends StatefulWidget {
  final String arabicText;
  final String translation;
  final int surahNumber;
  final int ayahNumber;
  final String surahName;

  const AyahShareBottomSheet({
    super.key,
    required this.arabicText,
    required this.translation,
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
  });

  @override
  State<AyahShareBottomSheet> createState() => _AyahShareBottomSheetState();
}

class _AyahShareBottomSheetState extends State<AyahShareBottomSheet> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AssetsData.logo), context);
    precacheImage(const AssetImage(AssetsData.logoDark), context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAppDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: isAppDark ? const Color(0xFF1B1917) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isAppDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // Sheet Title & Close Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.goldenPrimary.withValues(alpha: 0.15),
                        ),
                        child: const Icon(
                          Icons.share_rounded,
                          color: AppColors.goldenPrimary,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مشاركة الآية الكريمة',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: isAppDark
                                  ? Colors.white
                                  : AppColors.brownPrimary,
                            ),
                          ),
                          Text(
                            'سورة ${widget.surahName} • الآية ${widget.ayahNumber}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isAppDark
                                  ? Colors.white60
                                  : AppColors.brownSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: isAppDark ? Colors.white60 : Colors.grey[700],
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 0.5),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Theme Selector Chips
                    Row(
                      children: [
                        Text(
                          'تصميم الصورة:',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: isAppDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildThemeOption(
                                  label: 'الثيم الذهبي',
                                  icon: Icons.wb_sunny_rounded,
                                  selected: !_isDark,
                                  onTap: () => setState(() => _isDark = false),
                                  isAppDark: isAppDark,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: _buildThemeOption(
                                  label: 'الثيم الداكن',
                                  icon: Icons.nightlight_round,
                                  selected: _isDark,
                                  onTap: () => setState(() => _isDark = true),
                                  isAppDark: isAppDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Live Card Preview
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: 280.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        color: _isDark
                            ? Colors.black26
                            : AppColors.goldenPrimary.withValues(alpha: 0.04),
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 4.h,
                        ),
                        child: AyahShareCard(
                          arabicText: widget.arabicText,
                          translation: widget.translation,
                          surahNumber: widget.surahNumber,
                          ayahNumber: widget.ayahNumber,
                          surahName: widget.surahName,
                          isDark: _isDark,
                          isPreview: true,
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Action: Share Image (Primary)
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.goldenGradient,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.goldenPrimary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        icon: const Icon(
                          Icons.image_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        label: Text(
                          'مشاركة كصورة',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          final rootContext =
                              Navigator.of(context, rootNavigator: true).context;
                          Navigator.pop(context);
                          AyahShareManager.shareAyahAsImage(
                            arabicText: widget.arabicText,
                            translation: widget.translation,
                            surahNumber: widget.surahNumber,
                            ayahNumber: widget.ayahNumber,
                            surahName: widget.surahName,
                            context: rootContext,
                            isDark: _isDark,
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Secondary Actions: Text Share and Copy Text
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              side: BorderSide(
                                color: isAppDark
                                    ? Colors.white24
                                    : Colors.grey.shade300,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            icon: Icon(
                              Icons.text_fields_rounded,
                              size: 18,
                              color: isAppDark
                                  ? Colors.white70
                                  : AppColors.brownPrimary,
                            ),
                            label: Text(
                              'مشاركة كنص',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: isAppDark
                                    ? Colors.white
                                    : AppColors.brownPrimary,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              AyahShareManager.shareAyahAsText(
                                arabicText: widget.arabicText,
                                translation: widget.translation,
                                surahNumber: widget.surahNumber,
                                ayahNumber: widget.ayahNumber,
                                surahName: widget.surahName,
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              side: BorderSide(
                                color: isAppDark
                                    ? Colors.white24
                                    : Colors.grey.shade300,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            icon: Icon(
                              Icons.copy_rounded,
                              size: 18,
                              color: isAppDark
                                  ? Colors.white70
                                  : AppColors.brownPrimary,
                            ),
                            label: Text(
                              'نسخ الآية',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: isAppDark
                                    ? Colors.white
                                    : AppColors.brownPrimary,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              AyahShareManager.copyAyahAsText(
                                arabicText: widget.arabicText,
                                translation: widget.translation,
                                surahNumber: widget.surahNumber,
                                ayahNumber: widget.ayahNumber,
                                surahName: widget.surahName,
                                context: context,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required bool isAppDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.goldenPrimary.withValues(alpha: 0.15)
              : (isAppDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected
                ? AppColors.goldenPrimary
                : (isAppDark ? Colors.white12 : Colors.grey.shade300),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? AppColors.goldenPrimary
                  : (isAppDark ? Colors.white54 : Colors.grey[600]),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? AppColors.goldenPrimary
                    : (isAppDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
