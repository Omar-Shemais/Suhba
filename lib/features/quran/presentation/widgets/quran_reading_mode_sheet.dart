// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import '../../data/helpers/quran_reading_mode_helper.dart';

class QuranReadingModeSheet extends StatefulWidget {
  final QuranScrollMode currentMode;
  final ValueChanged<QuranScrollMode> onModeSelected;

  const QuranReadingModeSheet({
    super.key,
    required this.currentMode,
    required this.onModeSelected,
  });

  static Future<QuranScrollMode?> show(
    BuildContext context, {
    required QuranScrollMode currentMode,
    required ValueChanged<QuranScrollMode> onModeSelected,
  }) {
    return showModalBottomSheet<QuranScrollMode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuranReadingModeSheet(
        currentMode: currentMode,
        onModeSelected: onModeSelected,
      ),
    );
  }

  @override
  State<QuranReadingModeSheet> createState() => _QuranReadingModeSheetState();
}

class _QuranReadingModeSheetState extends State<QuranReadingModeSheet> {
  late QuranScrollMode _selectedMode;
  bool _rememberChoice = true;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.currentMode;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF282C32) : const Color(0xFFFAF5ED);
    final cardBg = isDark ? const Color(0xFF21252A) : const Color(0xFFF9F7F2);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مقبض السحب العلوي
          Container(
            width: 48.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.35),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 18.h),

          // العنوان
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book_rounded,
                color: AppColors.goldenPrimary,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'طريقة عرض وقراءة القرآن',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.brownPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'اختر أسلوب التصفح الأنسب لك، ويمكنك تغييره بأي وقت',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          SizedBox(height: 22.h),

          // الخيار الأول: التمرير الرأسي
          _buildModeOption(
            mode: QuranScrollMode.vertical,
            title: 'تمرير رأسي (من أسفل لأعلى)',
            subtitle: 'قراءة مستمرة وانسيابية، مع ميزة التمرير التلقائي الذكي وشريط التحكم بالسرعة',
            badgeText: 'موصى به • تمرير تلقائي',
            icon: Icons.swap_vert_rounded,
            cardBg: cardBg,
            isDark: isDark,
          ),
          SizedBox(height: 14.h),

          // الخيار الثاني: التمرير الأفقي
          _buildModeOption(
            mode: QuranScrollMode.horizontal,
            title: 'تصفح أفقي (من اليمين لليسار)',
            subtitle: 'تقليب صفحات المصحف الشريف أفقياً صفحة بصفحة تماماً كالمصحف المطبوع',
            badgeText: 'كالمصحف المطبوع',
            icon: Icons.auto_stories_rounded,
            cardBg: cardBg,
            isDark: isDark,
          ),
          SizedBox(height: 16.h),

          // تذكر خياري
          InkWell(
            onTap: () => setState(() => _rememberChoice = !_rememberChoice),
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _rememberChoice,
                    onChanged: (v) => setState(() => _rememberChoice = v ?? true),
                    activeColor: AppColors.goldenPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Text(
                    'تذكر خياري كافتراضي',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // زر التطبيق
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () async {
                if (_rememberChoice) {
                  await QuranReadingModeHelper.saveScrollMode(_selectedMode);
                }
                widget.onModeSelected(_selectedMode);
                if (mounted) {
                  Navigator.pop(context, _selectedMode);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldenPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 3,
                shadowColor: AppColors.goldenPrimary.withOpacity(0.4),
              ),
              child: Text(
                'تأكيد واختيار',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildModeOption({
    required QuranScrollMode mode,
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData icon,
    required Color cardBg,
    required bool isDark,
  }) {
    final isSelected = _selectedMode == mode;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      borderRadius: BorderRadius.circular(18.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isSelected ? AppColors.goldenPrimary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.goldenPrimary.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // أيقونة النمط
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? [AppColors.goldenPrimary, AppColors.goldenSecondary]
                      : [
                          isDark ? Colors.white12 : Colors.black12,
                          isDark ? Colors.white10 : Colors.black12,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                size: 26.sp,
              ),
            ),
            SizedBox(width: 14.w),

            // النصوص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.goldenPrimary.withOpacity(0.18)
                              : Colors.grey.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.goldenPrimary : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.4,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),
            // Radio Circle
            Container(
              width: 22.r,
              height: 22.r,
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.goldenPrimary : Colors.grey.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.r,
                        height: 12.r,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.goldenPrimary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
