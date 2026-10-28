// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/features/quran/data/helpers/last_read_storage.dart';
import 'package:islamic_app/features/quran/presentation/cubit/audio_cubit.dart';
import 'package:islamic_app/features/quran/presentation/cubit/audio_state.dart';
import '../../data/models/quran_models.dart';
import 'ayah_share_bottom_sheet.dart';

class DeluxeAyahCard extends StatefulWidget {
  final VerseModel ayah;
  final int surahId;
  final String surahName;
  final String surahNameArabic;
  final double fontSize;
  final bool showTranslation;

  const DeluxeAyahCard({
    super.key,
    required this.ayah,
    required this.surahId,
    required this.surahName,
    required this.surahNameArabic,
    required this.fontSize,
    required this.showTranslation,
  });

  @override
  State<DeluxeAyahCard> createState() => _DeluxeAyahCardState();
}

class _DeluxeAyahCardState extends State<DeluxeAyahCard> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = LastReadManager.isAyahLastRead(
      widget.surahId,
      widget.ayah.id,
    );
    LastReadManager.lastReadUpdated.addListener(_onLastReadUpdated);
  }

  @override
  void dispose() {
    LastReadManager.lastReadUpdated.removeListener(_onLastReadUpdated);
    super.dispose();
  }

  void _onLastReadUpdated() {
    final updated = LastReadManager.isAyahLastRead(
      widget.surahId,
      widget.ayah.id,
    );
    if (_isBookmarked != updated && mounted) {
      setState(() => _isBookmarked = updated);
    }
  }

  String _toArabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.parse(d)])
        .join('');
  }

  Future<void> _toggleBookmark() async {
    await LastReadManager.saveLastRead(
      surahId: widget.surahId,
      ayahNumber: widget.ayah.id,
      surahName: widget.surahName,
      surahNameArabic: widget.surahNameArabic,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.bookmark_added_rounded, color: Colors.white),
              SizedBox(width: 8.w),
              Text('تم حفظ الآية كعلامة مرجعية'),
            ],
          ),
          backgroundColor: AppColors.goldenPrimary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
    }
  }

  void _copyAyahText() {
    Clipboard.setData(
      ClipboardData(text: '${widget.ayah.text} ﴿${widget.ayah.id}﴾'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.copy_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('تم نسخ الآية الكريمة إلى الحافظة'),
          ],
        ),
        backgroundColor: AppColors.goldenPrimary,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AyahShareBottomSheet(
        arabicText: widget.ayah.text,
        translation: widget.ayah.translation,
        surahNumber: widget.surahId,
        ayahNumber: widget.ayah.id,
        surahName: widget.surahName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AudioCubit, AudioState>(
      builder: (context, audioState) {
        final audioCubit = context.read<AudioCubit>();

        final bool isPlayingThis =
            (audioState is AudioPlayingAyah &&
                audioState.currentSurahId == widget.surahId &&
                audioState.currentAyahNumber == widget.ayah.id) ||
            (audioState is AudioPlaying &&
                audioState.currentSurahId == widget.surahId &&
                audioCubit.currentAyahNumber == widget.ayah.id);

        final bool isPausedThis =
            (audioState is AudioPaused &&
                audioState.currentSurahId == widget.surahId &&
                audioState.currentAyahNumber == widget.ayah.id) ||
            (audioState is AudioPaused &&
                audioState.currentSurahId == widget.surahId &&
                audioCubit.currentAyahNumber == widget.ayah.id);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: isPlayingThis
                ? (isDark
                    ? const Color(0xFF2E7D5E).withValues(alpha: 0.18)
                    : const Color(0xFF143427).withValues(alpha: 0.1))
                : (isDark ? const Color(0xFF282C32) : const Color(0xFFFAFAF7)),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isPlayingThis
                  ? (isDark
                      ? const Color(0xFF2E7D5E)
                      : const Color(0xFF143427))
                  : (isDark
                        ? const Color(0xFF383E46)
                        : const Color(0xFFEADBCE)),
              width: isPlayingThis ? 1.5 : 1.0,
            ),
            boxShadow: isPlayingThis
                ? [
                    BoxShadow(
                      color: AppColors.goldenPrimary.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.08 : 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الشريط العلوي للآية: رقم الآية وأزرار التفاعل السريع
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // شارة رقم الآية المزخرفة
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.goldenPrimary.withOpacity(0.2),
                          AppColors.goldenSecondary.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.goldenPrimary.withOpacity(0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'الآية',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.goldenPrimary,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _toArabicNumber(widget.ayah.id),
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.brownPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // أزرار التحكم بالآية (تشغيل صوت، علامة، نسخ، مشاركة)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // زر الاستماع للآية
                      _buildQuickAction(
                        icon: isPlayingThis
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_outline_rounded,
                        color: isPlayingThis
                            ? AppColors.goldenPrimary
                            : (isDark ? Colors.white60 : Colors.black54),
                        onTap: () {
                          if (isPlayingThis) {
                            audioCubit.pause();
                          } else if (isPausedThis) {
                            audioCubit.resume();
                          } else {
                            audioCubit.playAyah(widget.surahId, widget.ayah.id);
                          }
                        },
                      ),

                      SizedBox(width: 4.w),

                      // زر العلامة المرجعية
                      _buildQuickAction(
                        icon: _isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: _isBookmarked
                            ? AppColors.goldenPrimary
                            : (isDark ? Colors.white60 : Colors.black54),
                        onTap: _toggleBookmark,
                      ),

                      SizedBox(width: 4.w),

                      // زر النسخ
                      _buildQuickAction(
                        icon: Icons.copy_rounded,
                        color: isDark ? Colors.white60 : Colors.black54,
                        onTap: _copyAyahText,
                      ),

                      SizedBox(width: 4.w),

                      // زر المشاركة
                      _buildQuickAction(
                        icon: Icons.share_rounded,
                        color: isDark ? Colors.white60 : Colors.black54,
                        onTap: _showShareOptions,
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 14.h),

              // النص القرآني الشريف
              Text(
                '${widget.ayah.text} ۝',
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: widget.fontSize.sp,
                  height: 2.1,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                ),
              ),

            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.all(6.r),
        child: Icon(icon, size: 20.sp, color: color),
      ),
    );
  }
}
