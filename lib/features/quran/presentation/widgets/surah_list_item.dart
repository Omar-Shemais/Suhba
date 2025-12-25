import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/constants/app_text_styles.dart';
import '../../data/models/quran_models.dart';

class SurahListItem extends StatelessWidget {
  final SurahModel surah;
  final VoidCallback onTap;

  const SurahListItem({super.key, required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 30),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.primaryDarkColor
                    : AppColors.primaryLightColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              alignment: Alignment.center,
              child: Text(
                surah.id.toString().padLeft(2, '0'),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),

            SizedBox(width: 16.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(surah.transliteration, style: AppTextStyles.body),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        surah.type == 'meccan'
                            ? Icons.mosque
                            : Icons.location_city,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${surah.totalVerses} ${'Ayahs'.tr()}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Text(surah.name, style: AppTextStyles.basmala(context)),
          ],
        ),
      ),
    );
  }
}
