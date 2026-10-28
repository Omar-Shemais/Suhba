import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SalawatBottomSheet {
  static void show(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int salawatCount = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          isDark ? const Color(0xFF282C32) : const Color(0xFFFAF5ED),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
                  left: 20.w,
                  right: 20.w,
                  top: 12.h,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // مقبض السحب
                      Container(
                        width: 44.w,
                        height: 4.5.h,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : const Color(0xFFC7B9A9),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      SizedBox(height: 18.h),

                      // أيقونة وعنوان الشيت
                      Container(
                        width: 54.w,
                        height: 54.w,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : const Color(0xFFE8F1EC),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.spa_rounded,
                          size: 28.sp,
                          color: const Color(0xFF143427),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'الصَّلَاةُ عَلَى النَّبِيِّ ﷺ',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF143427),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : const Color(0xFFF7F2EA),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'قال رسول الله ﷺ: «مَنْ صَلَّى عَلَيَّ صَلَاةً صَلَّى الله عَلَيْهِ بِهَا عَشْرًا»',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : const Color(0xFF736152),
                          ),
                        ),
                      ),

                      SizedBox(height: 18.h),

                      // بطاقة الصيغة الإبراهيمية
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF21252A) : const Color(0xFFFAF5ED),
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(
                            color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.stars_rounded,
                                        size: 18.sp,
                                        color: const Color(0xFFB8782E),
                                      ),
                                      SizedBox(width: 6.w),
                                      Flexible(
                                        child: Text(
                                          'الصيغة الإبراهيمية',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : const Color(0xFF143427),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.copy_rounded,
                                    size: 18.sp,
                                    color: isDark ? Colors.white70 : const Color(0xFF736152),
                                  ),
                                  tooltip: 'نسخ',
                                  onPressed: () {
                                    Clipboard.setData(const ClipboardData(
                                      text:
                                          'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
                                    ));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('تم نسخ الصيغة الإبراهيمية'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              '«اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ»',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 15.5.sp,
                                height: 1.8,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFF6E8DC) : const Color(0xFF38291D),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // بطاقة الصيغة الموجزة
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF21252A) : const Color(0xFFFAF5ED),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
                            width: 1.1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '«اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَى نَبِيِّنَا مُحَمَّدٍ ﷺ»',
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF143427),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.copy_rounded,
                                size: 18.sp,
                                color: isDark ? Colors.white70 : const Color(0xFF736152),
                              ),
                              tooltip: 'نسخ',
                              onPressed: () {
                                Clipboard.setData(const ClipboardData(
                                  text: 'اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَى نَبِيِّنَا مُحَمَّدٍ ﷺ',
                                ));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم نسخ الصيغة'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 18.h),

                      // زر التفاعل مع عداد الصلوات
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18.r),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setSheetState(() {
                              salawatCount++;
                            });
                          },
                          child: Container(
                            height: 52.h,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2E7D5E)
                                  : const Color(0xFF143427),
                              borderRadius: BorderRadius.circular(18.r),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark
                                          ? const Color(0xFF2E7D5E)
                                          : const Color(0xFF143427))
                                      .withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.favorite_rounded,
                                  color: const Color(0xFFC7A87A),
                                  size: 20.sp,
                                ),
                                SizedBox(width: 10.w),
                                Flexible(
                                  child: Text(
                                    salawatCount == 0
                                        ? 'اضغط هنا للصلاة على النبي ﷺ'
                                        : 'صلّيت ﷺ (${_toArabicDigits(salawatCount)}) مرات',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.5.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static String _toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => int.tryParse(d) != null ? arabicDigits[int.parse(d)] : d)
        .join('');
  }
}
