import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/constants/app_text_styles.dart';
import 'package:islamic_app/core/constants/assets.dart';
import '../../data/models/hadith_model.dart';

class HadithCard extends StatefulWidget {
  final HadithModel hadith;

  const HadithCard({super.key, required this.hadith});

  @override
  State<HadithCard> createState() => _HadithCardState();
}

class _HadithCardState extends State<HadithCard> {
  bool _showEnglish = false;

  @override
  Widget build(BuildContext context) {
    final hadith = widget.hadith;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark
                ? const Color(0xFF383E46)
                : const Color(0xFFEADBCE),
            width: 1.2,
          ),
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF282C32), Color(0xFF21252A)]
                : [
                    AppColors.primaryLightColor,
                    AppColors.primaryLightColor.withOpacity(0.1),
                  ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              bottom: -10,
              left: -10,
              child: Image.asset(
                AssetsData.kaaba,
                width: 60.w,
                height: 60.h,
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.2),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Hadith Number Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.15)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.3)
                                : AppColors.primaryLightColor.withOpacity(0.3),
                            width: 1.w,
                          ),
                        ),
                        child: Text(
                          'رقم ${hadith.hadithNumber}',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.primaryLightColor
                                : AppColors.secondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),

                      // Book Name
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          _formatBookName(hadith.bookSlug),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark
                                ? AppColors.primaryLightColor
                                : AppColors.secondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Arabic Narrator (if exists)
                  if (hadith.arabicNarrator != null) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.amber.withOpacity(0.15)
                            : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.3),
                          width: 1.w,
                        ),
                      ),
                      child: Text(
                        hadith.arabicNarrator!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? Colors.amber.shade200
                              : Colors.brown.shade700,
                          height: 1.6.h,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // Hadith Arabic Text
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      hadith.hadithArabic,
                      style: AppTextStyles.basmala(context).copyWith(
                        fontSize: 18.sp,
                        height: 2.0.h,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // زر التبديل لإظهار / إخفاء الترجمة الإنجليزية كخيار مخصص
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _showEnglish = !_showEnglish);
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFF143427).withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : const Color(0xFF143427).withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.translate_rounded,
                                size: 15.sp,
                                color: isDark
                                    ? AppColors.primaryLightColor
                                    : const Color(0xFF143427),
                              ),
                              SizedBox(width: 6.w),
                              Flexible(
                                child: Text(
                                  _showEnglish ? 'إخفاء الترجمة الإنجليزية' : 'عرض الترجمة بالإنجليزية',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.primaryLightColor
                                        : const Color(0xFF143427),
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                _showEnglish
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 17.sp,
                                color: isDark
                                    ? AppColors.primaryLightColor
                                    : const Color(0xFF143427),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // قسم الترجمة الإنجليزية (يظهر فقط إذا اختار المستخدم ذلك)
                  if (_showEnglish) ...[
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey.shade300,
                          width: 1.w,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // English Narrator (if exists)
                          if (hadith.englishNarrator != null) ...[
                            Text(
                              hadith.englishNarrator!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontStyle: FontStyle.italic,
                                color: isDark
                                    ? Colors.white60
                                    : Colors.grey.shade600,
                                height: 1.5.h,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Divider(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.shade300,
                              thickness: 1,
                            ),
                            SizedBox(height: 12.h),
                          ],

                          // English Text
                          Text(
                            hadith.hadithEnglish,
                            style: TextStyle(
                              fontSize: 14.sp,
                              height: 1.7.h,
                              color: isDark
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.grey.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBookName(String bookSlug) {
    final Map<String, String> bookNames = {
      'sahih-bukhari': 'البخاري',
      'sahih-muslim': 'مسلم',
      'sunan-nasai': 'النسائي',
      'abu-dawood': 'أبو داود',
      'al-tirmidhi': 'الترمذي',
      'ibn-e-majah': 'ابن ماجه',
    };

    return bookNames[bookSlug] ?? bookSlug.replaceAll('-', ' ');
  }
}
