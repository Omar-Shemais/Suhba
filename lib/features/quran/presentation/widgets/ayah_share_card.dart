import 'package:flutter/material.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/constants/assets.dart';

class AyahShareCard extends StatelessWidget {
  final String arabicText;
  final String translation;
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final bool isDark;
  final bool isPreview;

  const AyahShareCard({
    super.key,
    required this.arabicText,
    required this.translation,
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    this.isDark = false,
    this.isPreview = false,
  });

  static String toArabicDigits(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String text = number.toString();
    for (int i = 0; i < english.length; i++) {
      text = text.replaceAll(english[i], arabic[i]);
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final arabicDigits = toArabicDigits(ayahNumber);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: isPreview ? double.infinity : 600,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF221D18),
                    Color(0xFF171411),
                    Color(0xFF0F0E0C),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFBF4),
                    Color(0xFFFBF3E4),
                    Color(0xFFF6E7CF),
                  ],
                ),
          borderRadius: BorderRadius.circular(isPreview ? 18 : 24),
          border: Border.all(
            color: AppColors.goldenPrimary,
            width: isPreview ? 1.5 : 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : AppColors.goldenPrimary.withValues(alpha: 0.2),
              blurRadius: isPreview ? 10 : 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Container(
          margin: EdgeInsets.all(isPreview ? 6 : 10),
          padding: EdgeInsets.all(isPreview ? 14 : 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isPreview ? 14 : 18),
            border: Border.all(
              color: isDark
                  ? AppColors.goldenPrimary.withValues(alpha: 0.35)
                  : AppColors.goldenPrimary.withValues(alpha: 0.45),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header: App Branding (Logo + Name) & Surah/Ayah Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Branding
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isPreview ? 3 : 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.8),
                          border: Border.all(
                            color:
                                AppColors.goldenPrimary.withValues(alpha: 0.6),
                            width: 1,
                          ),
                        ),
                        child: Image.asset(
                          AssetsData.logo,
                          width: isPreview ? 26 : 38,
                          height: isPreview ? 26 : 38,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: isPreview ? 8 : 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'صُـحْـبَـة',
                            style: TextStyle(
                              fontSize: isPreview ? 13 : 17,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.goldenPrimary
                                  : AppColors.brownPrimary,
                            ),
                          ),
                          Text(
                            'القرآن الكريم',
                            style: TextStyle(
                              fontSize: isPreview ? 9 : 11,
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.brownSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Surah & Ayah Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isPreview ? 10 : 14,
                      vertical: isPreview ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? LinearGradient(
                              colors: [
                                AppColors.goldenPrimary
                                    .withValues(alpha: 0.25),
                                AppColors.goldenSecondary
                                    .withValues(alpha: 0.12),
                              ],
                            )
                          : const LinearGradient(
                              colors: [
                                Color(0xFFFCECD2),
                                Color(0xFFF5DCBA),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            AppColors.goldenPrimary.withValues(alpha: 0.7),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_stories,
                          size: isPreview ? 12 : 15,
                          color: AppColors.goldenPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'سورة $surahName • آية $arabicDigits',
                          style: TextStyle(
                            fontSize: isPreview ? 11 : 13,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : AppColors.brownPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Bismillah Calligraphy
              Padding(
                padding: EdgeInsets.only(
                  top: isPreview ? 10 : 16,
                  bottom: isPreview ? 6 : 10,
                ),
                child: Center(
                  child: Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: isPreview ? 15 : 19,
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldenPrimary,
                    ),
                  ),
                ),
              ),

              // Ornamental Divider
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: isPreview ? 35 : 55,
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.goldenPrimary.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.diamond_outlined,
                        size: isPreview ? 10 : 13,
                        color: AppColors.goldenPrimary,
                      ),
                    ),
                    Container(
                      width: isPreview ? 35 : 55,
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.goldenPrimary.withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Ayah Quranic Text
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isPreview ? 10 : 16,
                  horizontal: isPreview ? 4 : 8,
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '﴿ ',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: isPreview ? 22 : 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldenPrimary,
                        ),
                      ),
                      TextSpan(
                        text: arabicText,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: isPreview ? 18 : 24,
                          height: 2.1,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.brownPrimary,
                        ),
                      ),
                      TextSpan(
                        text: ' ﴾',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: isPreview ? 22 : 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldenPrimary,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Translation (if provided)
              if (translation.trim().isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPreview ? 6 : 12,
                    vertical: isPreview ? 4 : 8,
                  ),
                  child: Text(
                    translation,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isPreview ? 11 : 13,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white70 : AppColors.brownSecondary,
                    ),
                  ),
                ),
              ],

              // Footer Divider
              Container(
                height: 1,
                margin: EdgeInsets.only(
                  top: isPreview ? 12 : 18,
                  bottom: isPreview ? 8 : 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.goldenPrimary.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Footer: Quote & App Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '﴿ وَذَكِّرْ فَإِنَّ الذِّكْرَىٰ تَنفَعُ الْمُؤْمِنِينَ ﴾',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: isPreview ? 10 : 12,
                      color: isDark
                          ? AppColors.goldenPrimary
                          : AppColors.brownSecondary,
                    ),
                  ),
                  Text(
                    'تطبيق صُحبة • Suhba App',
                    style: TextStyle(
                      fontSize: isPreview ? 9 : 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
