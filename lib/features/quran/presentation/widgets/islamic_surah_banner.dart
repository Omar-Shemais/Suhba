// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class IslamicSurahBanner extends StatelessWidget {
  final int surahId;
  final String surahName;
  final String surahNameArabic;
  final int totalVerses;
  final String type; // 'meccan' or 'medinan'

  const IslamicSurahBanner({
    super.key,
    required this.surahId,
    required this.surahName,
    required this.surahNameArabic,
    required this.totalVerses,
    required this.type,
  });

  String _toArabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((d) => arabicDigits[int.parse(d)]).join('');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMeccan = type.toLowerCase() == 'meccan';
    final revelationText = isMeccan ? 'مَكِّيَّة' : 'مَدَنِيَّة';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF282C32),
                  const Color(0xFF1E2125),
                  const Color(0xFF282C32),
                ]
              : [
                  const Color(0xFFFFF9EE),
                  const Color(0xFFF7ECDA),
                  const Color(0xFFFFF9EE),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: AppColors.goldenPrimary.withOpacity(0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldenPrimary.withOpacity(isDark ? 0.15 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // زخرفة إسلامية خفيفة في الخلفية
          Positioned(
            right: 12.w,
            top: 12.h,
            child: Opacity(
              opacity: isDark ? 0.12 : 0.15,
              child: Icon(
                Icons.star_border_rounded,
                size: 60.sp,
                color: AppColors.goldenPrimary,
              ),
            ),
          ),
          Positioned(
            left: 12.w,
            bottom: 12.h,
            child: Opacity(
              opacity: isDark ? 0.12 : 0.15,
              child: Icon(
                Icons.star_border_rounded,
                size: 60.sp,
                color: AppColors.goldenPrimary,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // زخرفة علوية
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildOrnamentLine(isDark),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '۞',
                        style: TextStyle(
                          color: AppColors.goldenPrimary,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    _buildOrnamentLine(isDark),
                  ],
                ),
                SizedBox(height: 6.h),

                // اسم السورة بالعربي بخط كبير وجميل
                Text(
                  surahNameArabic.isNotEmpty ? surahNameArabic : surahName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.brownPrimary,
                    shadows: [
                      Shadow(
                        color: AppColors.goldenPrimary.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),

                // شارات التفاصيل (مكان النزول، عدد الآيات، رقم السورة)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8.w,
                  runSpacing: 6.h,
                  children: [
                    _buildBadge(
                      label: revelationText,
                      icon: isMeccan ? Icons.location_city_rounded : Icons.mosque_rounded,
                      isDark: isDark,
                    ),
                    _buildBadge(
                      label: '${_toArabicNumber(totalVerses)} آيَات',
                      icon: Icons.format_list_numbered_rounded,
                      isDark: isDark,
                    ),
                    _buildBadge(
                      label: 'ترتيبها ${_toArabicNumber(surahId)}',
                      icon: Icons.auto_stories_rounded,
                      isDark: isDark,
                    ),
                  ],
                ),

                // البسملة (إذا لم تكن سورة التوبة)
                if (surahId != 9) ...[
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.white.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: AppColors.goldenPrimary.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.goldenPrimary : AppColors.secondaryColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrnamentLine(bool isDark) {
    return Container(
      width: 45.w,
      height: 1.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.goldenPrimary.withOpacity(0.8),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.goldenPrimary.withOpacity(0.14)
            : AppColors.primaryLightColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.goldenPrimary.withOpacity(0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13.sp,
            color: AppColors.goldenPrimary,
          ),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppColors.brownPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
