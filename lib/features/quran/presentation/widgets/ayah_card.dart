import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/constants/app_text_styles.dart';

import '../../data/models/quran_models.dart';
import 'ayah_actions.dart';

class AyahCard extends StatelessWidget {
  final VerseModel ayah;
  final int surahId;
  final String surahName;
  final String ensurahName;

  const AyahCard({
    super.key,
    required this.ayah,
    required this.surahId,
    required this.surahName,
    required this.ensurahName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // رقم الآية
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryDarkColor
                      : AppColors.primaryLightColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '$surahId:${ayah.id}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.more_horiz, color: AppColors.textSecondary),
            ],
          ),

          SizedBox(height: 20.h),

          // النص العربي
          Text(
            ayah.text,
            textAlign: TextAlign.right,
            style: AppTextStyles.quranText,
          ),

          SizedBox(height: 16.h),

          // الترجمة
          Text(
            ayah.translation,
            textAlign: TextAlign.left,
            style: AppTextStyles.secondary,
          ),

          SizedBox(height: 16.h),

          // أزرار الآية
          AyahActions(
            surahId: surahId,
            ayahNumber: ayah.id,
            arabicText: ayah.text,
            translation: ayah.translation,
            surahName: surahName,
            surahNameArabic: ensurahName,
          ),

          Divider(color: AppColors.textSecondary, thickness: .1, height: 30.h),
        ],
      ),
    );
  }
}
