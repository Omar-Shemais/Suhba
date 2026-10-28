import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/assets.dart';
import '../../data/models/quran_models.dart';
import 'islamic_surah_badge.dart';

class SurahListItem extends StatelessWidget {
  final SurahModel surah;
  final VoidCallback onTap;
  final bool? isSelected;

  const SurahListItem({
    super.key,
    required this.surah,
    required this.onTap,
    this.isSelected,
  });

  String _cleanSurahName(String rawName) {
    String cleaned = rawName
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll('ٱ', 'ا')
        .trim();

    if (cleaned.startsWith('سورة')) {
      return cleaned;
    }
    return 'سورة $cleaned';
  }

  String _toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.tryParse(d) ?? 0])
        .join('');
  }

  String _formatVersesCount(int count) {
    final arabicNumber = _toArabicDigits(count);
    if (count >= 3 && count <= 10) {
      return '$arabicNumber آيات';
    } else {
      return '$arabicNumber آية';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // تم إلغاء التحديد الافتراضي لسورة البقرة بناءً على طلب المستخدم
    final active = isSelected ?? false;

    final bgColor = active
        ? (isDark ? const Color(0xFF1E382B) : const Color(0xFFF1F6F3))
        : (isDark ? const Color(0xFF282C32) : const Color(0xFFFCF9F3));

    final borderColor = active
        ? (isDark ? const Color(0xFF2E7D5E) : const Color(0xFF386B56))
        : (isDark ? const Color(0xFF383E46) : const Color(0xFFEFE8DA));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.5.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: borderColor, width: active ? 1.5 : 1.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.025),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  // 1. السهم في أقصى اليمين (مطابق للصورة المرجعية)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14.sp,
                    color: isDark
                        ? const Color(0xFF9E8B7A)
                        : const Color(0xFF8C7A6B),
                  ),

                  SizedBox(width: 8.w),

                  // 2. الشارة الإسلامية المثمنة برقم السورة
                  IslamicSurahBadge(surahNumber: surah.id, isDark: isDark),

                  SizedBox(width: 14.w),

                  // 3. تفاصيل السورة في المنتصف: الاسم العربي، الاسم الإنجليزي، وعدد الآيات
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _cleanSurahName(surah.name),
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 18.5.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFF7ECE1)
                                : const Color(0xFF38291B),
                            height: 1.2,
                          ),
                        ),
                        if (surah.transliteration.isNotEmpty) ...[
                          SizedBox(height: 1.5.h),
                          Text(
                            surah.transliteration,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? const Color(0xFFB5A495)
                                  : const Color(0xFF8C7A6B),
                            ),
                          ),
                        ],
                        SizedBox(height: 1.5.h),
                        Text(
                          _formatVersesCount(surah.totalVerses),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFF9E8B7A)
                                : const Color(0xFF9E8B7A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. المعلم الإسلامي الدائري في أقصى اليسار
                  _buildSurahEmblem(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahEmblem(bool isDark) {
    final isMedinan = surah.type == 'medinan';

    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF21252A) : const Color(0xFFF5EFE3),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFE8DFCF),
          width: 1,
        ),
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26.r),
          child: Padding(
            padding: EdgeInsets.all(7.w),
            child: isMedinan
                ? Image.asset(
                    AssetsData.nabawiDome,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.mosque_rounded,
                      size: 26.sp,
                      color: const Color(0xFF143427),
                    ),
                  )
                : Image.asset(
                    AssetsData.kaaba,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.location_city_rounded,
                      size: 26.sp,
                      color: const Color(0xFF143427),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
