import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/duaa_item.dart';
import '../../data/repositories/duaa_repository.dart';
import 'duaa_category_detail_screen.dart';

class DuaaScreen extends StatefulWidget {
  const DuaaScreen({super.key});

  @override
  State<DuaaScreen> createState() => _DuaaScreenState();
}

class _DuaaScreenState extends State<DuaaScreen> {
  List<DuaaCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _categories = DuaaRepository.getCategories();
  }

  void _copyDuaa(DuaaItem item) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: '${item.arabic}\n\n${item.translation}'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.copy_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('تم نسخ الدعاء إلى الحافظة ✨'),
          ],
        ),
        backgroundColor: AppColors.goldenPrimary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  void _shareDuaa(DuaaItem item) {
    HapticFeedback.selectionClick();
    final text = '${item.arabic}\n\n${item.translation}\n\n— من تطبيق صُحبة';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1E2125) : const Color(0xFFFAF5ED),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.brownPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'duaa'.tr(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.brownPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          children: [
            // 1. Quranic Banner
            _buildSpiritualBanner(isDark),

            SizedBox(height: 16.h),

            // Featured Supplication
            _buildFeaturedDuaa(isDark),

            SizedBox(height: 20.h),

            // Categories Header
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: AppColors.goldenPrimary,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'أبواب الأدعية المأثورة',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.brownPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_categories.length} أقسام',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.goldenPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Categories List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return _buildCategoryCard(context, cat, isDark);
              },
            ),

            SizedBox(height: 20.h),

            // Prophetic Hadith Footer
            _buildHadithFooter(isDark),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSpiritualBanner(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.goldenPrimary.withValues(alpha: 0.2),
                  AppColors.containerDarkColor,
                ]
              : [
                  const Color(0xFFFFF3E0),
                  const Color(0xFFFDF8F0),
                ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.goldenPrimary.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: AppColors.goldenPrimary,
            size: 26,
          ),
          SizedBox(height: 4.h),
          Text(
            '« وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ »',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16.sp,
              height: 1.7,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.brownPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            'سورة البقرة : ١٨٦',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.goldenPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFeaturedDuaa(bool isDark) {
    const featuredArabic =
        '« رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ »';
    const featuredTranslation =
        'Our Lord, give us in this world that which is good and in the Hereafter that which is good and protect us from the punishment of the Fire.';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF282C32), Color(0xFF21252A)]
              : const [Color(0xFFFFF9ED), Color(0xFFFFF3DE)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? const Color(0xFF383E46)
              : const Color(0xFFEADBCE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldenPrimary.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: AppColors.goldenGradient,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'جامع الدعاء',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                tooltip: 'نسخ',
                color: AppColors.goldenPrimary,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(const ClipboardData(
                    text: '$featuredArabic\n\n$featuredTranslation',
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('تم نسخ الدعاء إلى الحافظة ✨'),
                      backgroundColor: AppColors.goldenPrimary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  );
                },
                constraints: const BoxConstraints(),
                padding: EdgeInsets.all(4.r),
              ),
              SizedBox(width: 8.w),
              IconButton(
                icon: const Icon(Icons.share_rounded, size: 18),
                tooltip: 'مشاركة',
                color: AppColors.goldenPrimary,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Share.share('$featuredArabic\n\n$featuredTranslation\n\n— من تطبيق صُحبة');
                },
                constraints: const BoxConstraints(),
                padding: EdgeInsets.all(4.r),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            featuredArabic,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 17.sp,
              height: 1.8,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.brownPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            featuredTranslation,
            style: TextStyle(
              fontSize: 11.sp,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white70 : AppColors.brownPrimary.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, DuaaCategory category, bool isDark) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DuaaCategoryDetailScreen(category: category),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF282C32) : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isDark
                ? const Color(0xFF383E46)
                : const Color(0xFFEADBCE),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: category.accentColor.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: category.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(category.icon, color: category.accentColor, size: 24),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        category.titleAr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.brownPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: category.accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '${category.count} دعاء',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: category.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    category.descriptionAr,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? Colors.white60 : Colors.brown.shade400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: isDark ? Colors.white38 : AppColors.brownPrimary.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHadithFooter(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? const Color(0xFF383E46)
              : const Color(0xFFEADBCE),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.menu_book_rounded,
            color: AppColors.goldenPrimary,
            size: 20,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'قال رسول الله ﷺ:',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldenPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '« الدُّعَاءُ هُوَ الْعِبَادَةُ »',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.brownPrimary,
                  ),
                ),
                Text(
                  'رواه الترمذي وقال: حديث حسن صحيح',
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
