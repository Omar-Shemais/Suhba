// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/constants/assets.dart';
import 'package:islamic_app/core/routes/app_routes.dart';
import '../widgets/feature_item_card.dart';

class FeaturesGridSection extends StatelessWidget {
  const FeaturesGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ألوان أكثر تناسق للثيم الإسلامي
    final iconColorsLight = [
      AppColors.primaryColor,
      const Color(0xFF8B7355),
      const Color(0xFF6B4E9A),
      const Color(0xFF2C8C7E),
      const Color(0xFFD4A056),
      const Color(0xFF4A6FA5),
      const Color(0xFF5C8E5C),
    ];

    final iconColorsDark = [
      const Color(0xFF4DD0E1),
      const Color(0xFFD4A373),
      const Color(0xFFB39DDB),
      const Color(0xFF4DB6AC),
      const Color(0xFFFFD54F),
      const Color(0xFF64B5F6),
      const Color(0xFF81C784),
    ];
    final features = [
      // 1- Mushaf
      FeatureItemData(
        title: "Mushaf".tr(),
        icon: SvgPicture.asset(
          AssetsData.quranIcon,
          width: 24.w,
          height: 24.h,

          color: isDark ? iconColorsDark[0] : iconColorsLight[0],
        ),
        onTap: () => GoRouter.of(context).push(AppRoutes.mushaf),
      ),
      // 5- Qibla
      FeatureItemData(
        title: "qibla".tr(),
        icon: SvgPicture.asset(
          AssetsData.qiblaIcon,
          width: 24.w,
          height: 24.h,
          color: isDark ? iconColorsDark[4] : iconColorsLight[4],
        ),
        onTap: () => GoRouter.of(context).push(AppRoutes.qibla),
      ),

      // 2- Hadith
      FeatureItemData(
        title: "hadith".tr(),
        icon: SvgPicture.asset(
          AssetsData.hadithIcon,
          width: 24.w,
          height: 24.h,
          color: isDark ? iconColorsDark[1] : iconColorsLight[1],
        ),
        onTap: () => GoRouter.of(context).push(AppRoutes.hadith),
      ),
      // 7- Nearby Masjed
      FeatureItemData(
        title: "nearby_masjed".tr(),
        icon: SvgPicture.asset(
          AssetsData.mosqurLocationIcon,
          width: 24.w,
          height: 24.h,
          color: isDark ? iconColorsDark[6] : iconColorsLight[6],
        ),
        onTap: () => GoRouter.of(context).push(AppRoutes.nearestMasjedScreen),
      ),

      // 3- Azkar
      FeatureItemData(
        title: "Azkar".tr(),
        icon: SvgPicture.asset(
          AssetsData.azkarIcon,
          width: 24.w,
          height: 24.h,
          color: isDark ? iconColorsDark[2] : iconColorsLight[2],
        ),
        onTap: () {
          GoRouter.of(context).push(AppRoutes.azkar);
        },
      ),

      // 4- Tasbih
      FeatureItemData(
        title: "Tasbih".tr(),
        icon: SvgPicture.asset(
          AssetsData.tasbihIcon,
          width: 24.w,
          height: 24.h,
          color: isDark ? iconColorsDark[3] : iconColorsLight[3],
        ),
        onTap: () {
          GoRouter.of(context).push(AppRoutes.tasbeeh);
        },
      ),

      // 6- Radio
      FeatureItemData(
        title: "radio".tr(),
        icon: SvgPicture.asset(
          AssetsData.radioIcon,
          width: 24.w,
          height: 24.h,
          color: isDark ? iconColorsDark[5] : iconColorsLight[5],
        ),
        onTap: () => GoRouter.of(context).push(AppRoutes.radio),
      ),
    ];

    return Container(
      height: 200.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryDarkColor : AppColors.containerColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10.w,
          crossAxisSpacing: 10.h,
          childAspectRatio: 0.85,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return FeatureItemCard(
            title: feature.title,
            icon: feature.icon,
            onTap: feature.onTap,
          );
        },
      ),
    );
  }
}

class FeatureItemData {
  final String title;
  final Widget icon;
  final VoidCallback onTap;

  FeatureItemData({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}
