import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../widgets/azkar_reminder_card.dart';
import 'after_prayer_azkar_screen.dart';
import 'evening_azkar_screen.dart';
import 'morning_azkar.dart';

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

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
            color: isDark ? Colors.white : const Color(0xFF38291D),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'azkar'.tr(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF38291D),
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

            // 2. Interactive Azkar Reminder Times Card
            const AzkarReminderCard(),

            SizedBox(height: 20.h),

            // 3. Section Title
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2E7D5E)
                        : const Color(0xFF143427),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'أقسام الأذكار',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF38291D),
                  ),
                ),
                const Spacer(),
                Text(
                  'حصّن يومك',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark
                        ? const Color(0xFF81C784)
                        : const Color(0xFF143427),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // 4. Category Cards
            _buildCategoryCard(
              context: context,
              isDark: isDark,
              title: 'morning_azkar'.tr(),
              subtitle: 'حصّن يومك بالبركة والسكينة من الفجر حتى الشروق',
              tag: 'سُنّة نبوية مؤكدة',
              icon: Icons.wb_sunny_rounded,
              gradientColors: isDark
                  ? const [Color(0xFF282C32), Color(0xFF21252A)]
                  : const [Color(0xFFFFF7EB), Color(0xFFFFEEDB)],
              iconBgColor: const Color(0xFFF39C12),
              borderColor: isDark
                  ? const Color(0xFF383E46)
                  : const Color(0xFFF39C12).withValues(alpha: 0.35),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MorningAzkar()),
                );
              },
            ),

            SizedBox(height: 12.h),

            _buildCategoryCard(
              context: context,
              isDark: isDark,
              title: 'evening_azkar'.tr(),
              subtitle: 'سكينة النفس وحفظ الرحمن من بعد العصر حتى الغروب',
              tag: 'حفظ وسكينة',
              icon: Icons.nights_stay_rounded,
              gradientColors: isDark
                  ? const [Color(0xFF282C32), Color(0xFF21252A)]
                  : const [Color(0xFFF3F2FD), Color(0xFFE8E5FB)],
              iconBgColor: const Color(0xFF5C54C7),
              borderColor: isDark
                  ? const Color(0xFF383E46)
                  : const Color(0xFF5C54C7).withValues(alpha: 0.35),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EveningAzkarScreen()),
                );
              },
            ),

            SizedBox(height: 12.h),

            _buildCategoryCard(
              context: context,
              isDark: isDark,
              title: 'after_prayer_azkar'.tr(),
              subtitle: 'الاستغفار والتسبيحات والدعوات المأثورة دبر كل صلاة',
              tag: 'مغفرة وثواب',
              icon: Icons.mosque_rounded,
              gradientColors: isDark
                  ? const [Color(0xFF282C32), Color(0xFF21252A)]
                  : const [Color(0xFFF0F8F3), Color(0xFFE3F2E8)],
              iconBgColor: const Color(0xFF2E7D32),
              borderColor: isDark
                  ? const Color(0xFF383E46)
                  : const Color(0xFF2E7D32).withValues(alpha: 0.35),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AfterPrayerAzkarScreen(),
                  ),
                );
              },
            ),

            SizedBox(height: 12.h),

            _buildCategoryCard(
              context: context,
              isDark: isDark,
              title: 'الأدعية المأثورة والقرآنية',
              subtitle: 'أدعية اليوم والليلة، السفر، الاستخارة، وجوامع الكلم النبوية',
              tag: 'أدعية جامعة',
              icon: Icons.auto_stories_rounded,
              gradientColors: isDark
                  ? const [Color(0xFF282C32), Color(0xFF21252A)]
                  : const [Color(0xFFF1F6F3), Color(0xFFE4EDE7)],
              iconBgColor: isDark
                  ? const Color(0xFF2E7D5E)
                  : const Color(0xFF143427),
              borderColor: isDark
                  ? const Color(0xFF383E46)
                  : const Color(0xFF143427).withValues(alpha: 0.35),
              onTap: () {
                HapticFeedback.lightImpact();
                GoRouter.of(context).push(AppRoutes.duaa);
              },
            ),

            SizedBox(height: 20.h),

            // 5. Prophetic Hadith Footer
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
              ? const [
                  Color(0xFF282C32),
                  Color(0xFF21252A),
                ]
              : const [
                  Color(0xFFE8EFEA),
                  Color(0xFFF2F7F4),
                ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? const Color(0xFF383E46)
              : const Color(0xFF143427).withValues(alpha: 0.2),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: isDark
                ? const Color(0xFF2E7D5E)
                : const Color(0xFF143427),
            size: 26,
          ),
          SizedBox(height: 4.h),
          Text(
            '« الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ »',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16.sp,
              height: 1.7,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF38291D),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            'سورة الرعد : ٢٨',
            style: TextStyle(
              fontSize: 11.sp,
              color: isDark
                  ? const Color(0xFF81C784)
                  : const Color(0xFF143427),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String subtitle,
    required String tag,
    required IconData icon,
    required List<Color> gradientColors,
    required Color iconBgColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: iconBgColor.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: iconBgColor.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF38291D),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: iconBgColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: iconBgColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.35,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.65)
                          : const Color(0xFF38291D).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: isDark
                  ? Colors.white38
                  : const Color(0xFF38291D).withValues(alpha: 0.4),
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
            color: isDark
                ? const Color(0xFF2E7D5E)
                : const Color(0xFF143427),
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
                    color: isDark
                        ? const Color(0xFF2E7D5E)
                        : const Color(0xFF143427),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '« مَثَلُ الَّذِي يَذْكُرُ رَبَّهُ وَالَّذِي لاَ يَذْكُرُ رَبَّهُ مَثَلُ الحَيِّ وَالمَيِّتِ »',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 13.sp,
                    height: 1.5,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.8)
                        : const Color(0xFF38291D).withValues(alpha: 0.85),
                  ),
                ),
                Text(
                  'رواه البخاري',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
