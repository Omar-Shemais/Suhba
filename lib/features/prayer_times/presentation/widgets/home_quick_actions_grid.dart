import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/assets.dart';
import 'package:islamic_app/core/routes/app_routes.dart';

class HomeQuickActionsGrid extends StatelessWidget {
  const HomeQuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      // الصف الأول
      // 1- القرآن الكريم (أخضر زمردي)
      _QuickActionItem(
        title: 'القرآن الكريم',
        icon: SvgPicture.asset(
          AssetsData.quranIcon,
          width: 26.w,
          height: 26.w,
          colorFilter: const ColorFilter.mode(
            Color(0xFF2E8555),
            BlendMode.srcIn,
          ),
        ),
        onTap: () => GoRouter.of(context).push(AppRoutes.quran),
      ),

      // 2- الأذكار (برتقالي/عنبري)
      _QuickActionItem(
        title: 'الأذكار',
        icon: Icon(
          Icons.menu_book_rounded,
          size: 27.sp,
          color: const Color(0xFFD97724),
        ),
        onTap: () => GoRouter.of(context).push(AppRoutes.azkar),
      ),

      // 3- الأحاديث (بني/برونزي)
      _QuickActionItem(
        title: 'الأحاديث',
        icon: SvgPicture.asset(
          AssetsData.hadithIcon,
          width: 26.w,
          height: 26.w,
          colorFilter: const ColorFilter.mode(
            Color(0xFFA06A38),
            BlendMode.srcIn,
          ),
        ),
        onTap: () => GoRouter.of(context).push(AppRoutes.hadith),
      ),

      // 4- الأدعية (ذهبي/عنبري دافئ)
      _QuickActionItem(
        title: 'الأدعية',
        icon: Icon(
          Icons.favorite_rounded,
          size: 26.sp,
          color: const Color(0xFFC0732A),
        ),
        onTap: () => GoRouter.of(context).push(AppRoutes.duaa),
      ),

      // الصف الثاني
      // 5- القبلة (أخضر غابات)
      _QuickActionItem(
        title: 'القبلة',
        icon: SvgPicture.asset(
          AssetsData.qiblaIcon,
          width: 26.w,
          height: 26.w,
          colorFilter: const ColorFilter.mode(
            Color(0xFF387B57),
            BlendMode.srcIn,
          ),
        ),
        onTap: () => GoRouter.of(context).push(AppRoutes.qibla),
      ),

      // 6- المساجد القريبة (تركواز/أزرق مخضر)
      _QuickActionItem(
        title: 'المساجد القريبة',
        icon: SvgPicture.asset(
          AssetsData.mosqurLocationIcon,
          width: 26.w,
          height: 26.w,
          colorFilter: const ColorFilter.mode(
            Color(0xFF2E8B7A),
            BlendMode.srcIn,
          ),
        ),
        onTap: () => GoRouter.of(context).push(AppRoutes.nearestMasjedScreen),
      ),

      // 7- تسبيح (أزرق سماوي/سيان)
      _QuickActionItem(
        title: 'تسبيح',
        icon: SvgPicture.asset(
          AssetsData.tasbihIcon,
          width: 26.w,
          height: 26.w,
          colorFilter: const ColorFilter.mode(
            Color(0xFF2B8CA3),
            BlendMode.srcIn,
          ),
        ),
        onTap: () => GoRouter.of(context).push(AppRoutes.tasbeeh),
      ),

      // 8- المزيد (رمادي/بني دافئ)
      _QuickActionItem(
        title: 'المزيد',
        icon: Icon(
          Icons.more_horiz_rounded,
          size: 28.sp,
          color: const Color(0xFF6B5A4B),
        ),
        onTap: () => _showMoreFeaturesSheet(context, isDark),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 10.w,
          childAspectRatio: 0.88,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildGridCard(context, item, isDark);
        },
      ),
    );
  }

  Widget _buildGridCard(
    BuildContext context,
    _QuickActionItem item,
    bool isDark,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF282C32) : const Color(0xFFFCFAF7),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // الأيقونة الملونة
              SizedBox(
                height: 32.h,
                child: Center(child: item.icon),
              ),

              SizedBox(height: 6.h),

              // العنوان
              Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFFF2E6D8)
                      : const Color(0xFF38291B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoreFeaturesSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF282C32) : const Color(0xFFFAF5ED),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      'المزيد من المميزات',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF38291D),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildMoreTile(
                    ctx,
                    icon: Icons.auto_stories_rounded,
                    iconColor: const Color(0xFF2E8555),
                    title: 'خِتمة القرآن الكريم',
                    subtitle: 'خطة وجدول ذكي لختم القرآن وتتبع الورد اليومي',
                    onTap: () {
                      Navigator.pop(ctx);
                      GoRouter.of(context).push(AppRoutes.khatmah);
                    },
                  ),
                  _buildMoreTile(
                    ctx,
                    icon: Icons.checklist_rtl_rounded,
                    iconColor: const Color(0xFF143427),
                    title: 'الفروض والسنن',
                    subtitle:
                        'متابعة الصلوات الخمس، السنن الرواتب، وصيام التطوع',
                    onTap: () {
                      Navigator.pop(ctx);
                      GoRouter.of(context).push(AppRoutes.fastingSunan);
                    },
                  ),
                  _buildMoreTile(
                    ctx,
                    icon: Icons.radio_rounded,
                    iconColor: const Color(0xFF4A7C59),
                    title: 'إذاعة القرآن الكريم',
                    subtitle: 'استمع للبث المباشر لإذاعات القرآن',
                    onTap: () {
                      Navigator.pop(ctx);
                      GoRouter.of(context).push(AppRoutes.radio);
                    },
                  ),
                  _buildMoreTile(
                    ctx,
                    icon: Icons.calendar_month_rounded,
                    iconColor: const Color(0xFF2C8C7E),
                    title: 'التقويم الهجري والميلادي',
                    subtitle: 'عرض التاريخ الهجري ومناسبات الشهر',
                    onTap: () {
                      Navigator.pop(ctx);
                      GoRouter.of(context).push(AppRoutes.calendar);
                    },
                  ),
                  _buildMoreTile(
                    ctx,
                    icon: Icons.notifications_active_rounded,
                    iconColor: const Color(0xFF38291D),
                    title: 'إعدادات الإشعارات والأذان',
                    subtitle: 'التحكم بإشعارات الصلاة والفجر والسنن والختمة',
                    onTap: () {
                      Navigator.pop(ctx);
                      GoRouter.of(context).push(AppRoutes.notificationSettings);
                    },
                  ),
                  _buildMoreTile(
                    ctx,
                    icon: Icons.help_outline_rounded,
                    iconColor: const Color(0xFF7E57C2),
                    title: 'المساعدة والدعم',
                    subtitle: 'تواصل معنا أو أرسل اقتراحك',
                    onTap: () {
                      Navigator.pop(ctx);
                      GoRouter.of(context).push(AppRoutes.helpSupport);
                    },
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoreTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: iconColor, size: 22.sp),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14.5.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF38291B),
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12.sp,
          color: isDark ? Colors.white60 : const Color(0xFF8C7A6B),
        ),
      ),
      trailing: Icon(
        Icons.chevron_left_rounded,
        size: 20.sp,
        color: isDark ? Colors.white38 : const Color(0xFFB0A294),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 2.h),
    );
  }
}

class _QuickActionItem {
  final String title;
  final Widget icon;
  final VoidCallback onTap;

  _QuickActionItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}
