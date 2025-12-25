import 'dart:io';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class AyahShareManager {
  static final GlobalKey _globalKey = GlobalKey();

  static Future<void> shareAyahAsImage({
    required String arabicText,
    required String translation,
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
    required BuildContext context,
  }) async {
    // حفظ الـ context قبل أي async operation
    final navigator = Navigator.of(context, rootNavigator: true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    OverlayEntry? overlay;
    bool dialogShown = false;

    try {
      // عرض Loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
        dialogShown = true;
      }

      // إنشاء الـ Widget
      overlay = OverlayEntry(
        builder: (context) => Positioned(
          left: -10000, // خارج الشاشة
          top: -10000,
          child: Material(
            color: Colors.transparent,
            child: RepaintBoundary(
              key: _globalKey,
              child: _AyahShareCard(
                arabicText: arabicText,
                translation: translation,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                surahName: surahName,
              ),
            ),
          ),
        ),
      );

      // إضافة للـ Overlay
      if (context.mounted) {
        final overlayState = Overlay.of(context);
        overlayState.insert(overlay);
      }

      // انتظار الرسم
      await Future.delayed(const Duration(milliseconds: 500));

      // التقاط الصورة
      final boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // حفظ الملف
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/ayah_${surahNumber}_$ayahNumber.png');
      await file.writeAsBytes(pngBytes);

      // إزالة من الـ Overlay
      overlay.remove();
      overlay = null;

      // إغلاق Loading قبل المشاركة
      if (dialogShown) {
        navigator.pop();
        dialogShown = false;
      }

      // المشاركة (بدون await عشان ميعلقش)
      // ignore: deprecated_member_use
      await Share.shareXFiles([
        XFile(file.path),
      ], text: '$surahName ($surahNumber:$ayahNumber)');
    } catch (e) {
      // إزالة الـ overlay لو موجود
      overlay?.remove();

      // إغلاق Loading
      if (dialogShown) {
        navigator.pop();
      }

      // عرض الخطأ
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('فشل مشاركة الآية: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  static Future<void> shareAyahAsText({
    required String arabicText,
    required String translation,
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
  }) async {
    final text =
        '''
$surahName ($surahNumber:$ayahNumber)

$arabicText

$translation

---
${"app_name".tr()}''';

    // ignore: deprecated_member_use
    await Share.share(text);
  }
}

class _AyahShareCard extends StatelessWidget {
  final String arabicText;
  final String translation;
  final int surahNumber;
  final int ayahNumber;
  final String surahName;

  const _AyahShareCard({
    required this.arabicText,
    required this.translation,
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600.w,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade300, width: 1.w),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // رقم الآية (نفس الكارد)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '$surahNumber:$ayahNumber',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),

          SizedBox(height: 20.h),

          // النص العربي (نفس الستايل)
          Text(
            arabicText,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 28.sp,
              height: 2.0.h,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 16.h),

          // الترجمة (نفس الستايل)
          Text(
            translation,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black54,
              height: 1.5.h,
            ),
          ),

          SizedBox(height: 20.h),

          // أيقونات الأكشن (ديكور فقط)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildIconButton(Icons.play_circle_outline),
              SizedBox(width: 16.w),
              _buildIconButton(Icons.bookmark_border),
              SizedBox(width: 16.w),
              _buildIconButton(Icons.share_outlined),
            ],
          ),

          Divider(color: Colors.grey, thickness: 0.5, height: 30.h),

          // Footer
          Center(
            child: Text(
              '$surahName • ${"app_name".tr()}',
              style: TextStyle(color: Colors.grey, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: Colors.grey, size: 24),
    );
  }
}
