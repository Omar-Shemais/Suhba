import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/constants/assets.dart';
import 'package:islamic_app/features/quran/presentation/widgets/ayah_share_card.dart';

class AyahShareManager {
  AyahShareManager._();

  /// مشاركة الآية كصورة احترافية بتصميم وثيم التطبيق وشعاره
  static Future<void> shareAyahAsImage({
    required String arabicText,
    required String translation,
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
    required BuildContext context,
    bool isDark = false,
  }) async {
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    final globalKey = GlobalKey();

    // استخراج الـ Overlay الخاص بالـ root navigator لضمان عمله حتى لو أُغلقت الـ bottom sheet
    OverlayState? overlayState;
    try {
      overlayState = Navigator.of(context, rootNavigator: true).overlay ??
          Overlay.maybeOf(context);
    } catch (_) {
      overlayState = Overlay.maybeOf(context);
    }

    if (overlayState == null) return;

    OverlayEntry? overlay;

    try {
      // Precache logo images
      try {
        await Future.wait([
          precacheImage(const AssetImage(AssetsData.logo), context),
          precacheImage(const AssetImage(AssetsData.logoDark), context),
        ]);
      } catch (_) {}

      // إنشاء الـ Widget خارج الشاشة بجودة فائقة بدون عرض أي نافذة تحميل أو تأخير
      overlay = OverlayEntry(
        builder: (context) => Positioned(
          left: -10000,
          top: -10000,
          child: Material(
            color: Colors.transparent,
            child: RepaintBoundary(
              key: globalKey,
              child: SizedBox(
                width: 600,
                child: AyahShareCard(
                  arabicText: arabicText,
                  translation: translation,
                  surahNumber: surahNumber,
                  ayahNumber: ayahNumber,
                  surahName: surahName,
                  isDark: isDark,
                  isPreview: false,
                ),
              ),
            ),
          ),
        ),
      );

      overlayState.insert(overlay);

      // انتظار رسم الـ Widget
      await Future.delayed(const Duration(milliseconds: 200));

      final renderObject = globalKey.currentContext?.findRenderObject();
      if (renderObject is RenderRepaintBoundary) {
        final image = await renderObject.toImage(pixelRatio: 3.0);
        final byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();

        // حفظ الملف في المسار المؤقت
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/ayah_${surahNumber}_$ayahNumber.png');
        await file.writeAsBytes(pngBytes);

        // إزالة الـ Overlay مباشرة
        overlay.remove();
        overlay = null;

        // نص الآية المرافق للمشاركة
        final shareText = '''
سورة $surahName • الآية $ayahNumber

﴿ $arabicText ﴾
${translation.trim().isNotEmpty ? '\n$translation\n' : ''}
---
تمت المشاركة عبر تطبيق صُـحْـبَـة 🌿''';

        // فتح نافذة المشاركة للنظام (واتساب، إنستغرام، تليجرام، فيسبوك وغيرها)
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(file.path)],
          text: shareText,
          subject: 'سورة $surahName - آية $ayahNumber',
        );
      }
    } catch (e) {
      scaffoldMessenger?.showSnackBar(
        SnackBar(
          content: Text('فشل مشاركة الآية: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      overlay?.remove();
      overlay = null;
    }
  }

  /// مشاركة الآية كنص منسق
  static Future<void> shareAyahAsText({
    required String arabicText,
    required String translation,
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
  }) async {
    final text = '''
سورة $surahName • الآية $ayahNumber

﴿ $arabicText ﴾
${translation.trim().isNotEmpty ? '\n$translation\n' : ''}
---
تمت المشاركة عبر تطبيق صُـحْـبَـة 🌿''';

    // ignore: deprecated_member_use
    await Share.share(
      text,
      subject: 'سورة $surahName - آية $ayahNumber',
    );
  }

  /// نسخ نص الآية إلى الحافظة
  static Future<void> copyAyahAsText({
    required String arabicText,
    required String translation,
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
    required BuildContext context,
  }) async {
    final text = '''
سورة $surahName • الآية $ayahNumber

﴿ $arabicText ﴾
${translation.trim().isNotEmpty ? '\n$translation\n' : ''}
---
تطبيق صُـحْـبَـة''';

    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'تم نسخ نص الآية الكريمة بنجاح',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: AppColors.goldenPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
