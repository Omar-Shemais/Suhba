import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/constants/app_text_styles.dart';
import '../pages/mushaf_reader_screen.dart';
import '../pages/radio_screen.dart';

class SurahTabs extends StatelessWidget {
  const SurahTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final isdark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text('Alquran'.tr(), style: AppTextStyles.subHead),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MushafReaderScreen()),
            );
          },
          child: TapContainer(
            isdark: isdark,
            text: "Mushaf".tr(),
            icon: Icons.auto_stories_outlined,
          ),
        ),
        SizedBox(width: 10.w),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RadioScreen()),
            );
          },
          child: TapContainer(
            isdark: isdark,
            text: "radio".tr(),
            icon: Icons.radio_outlined,
          ),
        ),
        SizedBox(width: 10.w),
        // GestureDetector(
        //   onTap: () {
        //     // Navigate to Favorites Screen
        //   },
        //   child: TapContainer(
        //     isdark: isdark,
        //     text: "fav".tr(),
        //     icon: Icons.favorite_border_outlined,
        //   ),
        // ),
      ],
    );
  }
}

class TapContainer extends StatelessWidget {
  const TapContainer({
    super.key,
    required this.isdark,
    required this.text,
    this.icon,
  });

  final bool isdark;
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: isdark
            ? AppColors.primaryDarkColor
            : AppColors.primaryLightColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: isdark ? Colors.white38 : Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: AppTextStyles.subHead.copyWith(
              color: AppColors.primaryColor,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(width: 5.w),

          Icon(
            icon ?? Icons.auto_stories_outlined,
            color: AppColors.primaryColor,
            size: 16,
          ),
        ],
      ),
    );
  }
}
