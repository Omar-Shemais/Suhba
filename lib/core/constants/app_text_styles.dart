import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTextStyles {
  // 🕰️ نصوص المواقيت الزمنية
  static TextStyle timeText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 48.sp,
    fontWeight: FontWeight.w700,
    height: 3.h,
    letterSpacing: 2.w,
  );

  // 🕌 نصوص القرآن الكريم
  static TextStyle quranText = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 22.5.sp,
    height: 2.2.h,
    letterSpacing: 0,
  );

  // 🌿 البسملة أو النصوص المزخرفة
  static TextStyle basmala(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'Amiri',
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.primaryColor : AppColors.secondaryColor,
    );
  }

  // 📚 عناوين السور أو الصفحات الإسلامية
  static TextStyle surahTitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
  );

  // 🕋 النصوص الثانوية (ترجمة / وصف / تفاصيل)
  static TextStyle secondary = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.sp,
    color: AppColors.textSecondary,
  );

  static TextStyle textstyle14 = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    fontSize: 14.sp,
  );

  // ⚙️ نصوص الأزرار أو العمليات
  static TextStyle button = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
  );

  // 🧭 عناوين رئيسية كبيرة
  static TextStyle headline = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 25.sp,
    fontWeight: FontWeight.bold,
  );

  // 🔹 عناوين فرعية
  static TextStyle subHead = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
  );

  // 📄 النصوص الأساسية (Body)
  static TextStyle body = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16.sp,
    height: 1.5.h,
    fontWeight: FontWeight.w500,
  );

  // 💬 نصوص صغيرة (ملاحظات - Hint - Caption)
  static TextStyle caption = TextStyle(fontFamily: 'Poppins', fontSize: 12.sp);

  // 📝 نصوص حقول الإدخال
  static TextStyle input = TextStyle(fontFamily: 'Poppins', fontSize: 16.sp);

  // ⚠️ نصوص الأخطاء
  static TextStyle error = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.sp,
    color: Colors.redAccent,
    fontWeight: FontWeight.w500,
  );

  // ✅ نصوص النجاح
  static TextStyle success = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.sp,
    color: Colors.green,
    fontWeight: FontWeight.w500,
  );

  // 💰 نصوص الأسعار
  static TextStyle price = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
  );

  // 🔖 نصوص الروابط
  static TextStyle link = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.sp,
    color: Colors.blueAccent,
    decoration: TextDecoration.underline,
  );
}
