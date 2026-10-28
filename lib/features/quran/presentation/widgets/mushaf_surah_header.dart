import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MushafSurahHeader extends StatelessWidget {
  final int surahId;
  final String surahName;
  final int totalVerses;

  const MushafSurahHeader({
    super.key,
    required this.surahId,
    required this.surahName,
    required this.totalVerses,
  });

  String _toArabic(int n) {
    const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) => d[int.parse(c)]).join('');
  }

  @override
  Widget build(BuildContext context) {
    final cleanName = surahName
        .replaceAll('سُورَةُ ', '')
        .replaceAll('سورة ', '')
        .trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: EdgeInsets.only(top: 4.h, bottom: 8.h),
        height: 80.h,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // الإطار الزخرفي ذو النقوش الخضراء والذهبية بتقنية الـ 9-Slice
            Positioned.fill(
              child: Image.asset(
                'assets/images/mushaf_banner_frame.png',
                fit: BoxFit.fill,
                centerSlice: const Rect.fromLTRB(95, 20, 245, 75),
              ),
            ),

            // المحتوى: يمين (ترتيبها) • منتصف (اسم السورة) • يسار (عدد الآيات)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Row(
                children: [
                  // الميدالية اليمنى: ترتيب السورة في المصحف
                  SizedBox(
                    width: 52.w,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _toArabic(surahId),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF231B15),
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'ترتيبها',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4A3728),
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // المنتصف: اسم السورة بالخط القرآني الفاخر
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'سُورَةُ $cleanName',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF231B15),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // الميدالية اليسرى: عدد آيات السورة
                  SizedBox(
                    width: 52.w,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _toArabic(totalVerses),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF231B15),
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'آية',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4A3728),
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
