// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/features/quran/data/helpers/ayah_share_manager.dart';
import 'package:islamic_app/features/quran/data/helpers/last_read_storage.dart';

import '../cubit/audio_cubit.dart';
import '../cubit/audio_state.dart';

class AyahActions extends StatefulWidget {
  final int surahId;
  final int ayahNumber;
  final String arabicText;
  final String translation;
  final String surahName;
  final String surahNameArabic;

  const AyahActions({
    super.key,
    required this.surahId,
    required this.ayahNumber,
    required this.arabicText,
    required this.translation,
    required this.surahName,
    required this.surahNameArabic,
  });

  @override
  State<AyahActions> createState() => _AyahActionsState();
}

class _AyahActionsState extends State<AyahActions> {
  bool _isLastRead = false;

  @override
  void initState() {
    super.initState();
    _checkIfLastRead();
  }

  Future<void> _checkIfLastRead() async {
    final lastRead = await LastReadManager.getLastRead();
    if (mounted && !lastRead.isDefault) {
      setState(() {
        _isLastRead =
            lastRead.surahId == widget.surahId &&
            lastRead.ayahNumber == widget.ayahNumber;
      });
    }
  }

  Future<void> _setAsLastRead() async {
    await LastReadManager.saveLastRead(
      surahId: widget.surahId,
      ayahNumber: widget.ayahNumber,
      surahName: widget.surahName,
      surahNameArabic: widget.surahNameArabic,
    );

    if (mounted) {
      setState(() {
        _isLastRead = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.bookmark_added, color: Colors.white),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'last_read_saved'.tr(),
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'share_ayah'.tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.primaryDarkColor
                      : AppColors.primaryLightColor,
                ),
              ),
              SizedBox(height: 20.h),
              ListTile(
                leading: Icon(
                  Icons.image,
                  color: isDark
                      ? AppColors.primaryDarkColor
                      : AppColors.primaryLightColor,
                ),
                title: Text('share_as_image'.tr()),
                onTap: () async {
                  Navigator.pop(context);
                  await AyahShareManager.shareAyahAsImage(
                    arabicText: widget.arabicText,
                    translation: widget.translation,
                    surahNumber: widget.surahId,
                    ayahNumber: widget.ayahNumber,
                    surahName: widget.surahName,
                    context: context,
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.text_fields,
                  color: isDark
                      ? AppColors.primaryDarkColor
                      : AppColors.primaryLightColor,
                ),
                title: const Text('share_as_text').tr(),
                onTap: () async {
                  Navigator.pop(context);
                  await AyahShareManager.shareAyahAsText(
                    arabicText: widget.arabicText,
                    translation: widget.translation,
                    surahNumber: widget.surahId,
                    ayahNumber: widget.ayahNumber,
                    surahName: widget.surahName,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioCubit, AudioState>(
      builder: (context, state) {
        final cubit = context.read<AudioCubit>();

        final isPlayingThis =
            (state is AudioPlayingAyah &&
                state.currentSurahId == widget.surahId &&
                state.currentAyahNumber == widget.ayahNumber) ||
            (state is AudioPlaying &&
                state.currentSurahId == widget.surahId &&
                cubit.currentAyahNumber == widget.ayahNumber);

        final isPausedThis =
            (state is AudioPaused &&
                state.currentSurahId == widget.surahId &&
                state.currentAyahNumber == widget.ayahNumber) ||
            (state is AudioPaused &&
                state.currentSurahId == widget.surahId &&
                cubit.currentAyahNumber == widget.ayahNumber);

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildActionButton(
              context: context,
              icon: isPlayingThis
                  ? Icons.pause_circle
                  : Icons.play_circle_outline,
              isActive: isPlayingThis,
              onTap: () {
                if (isPlayingThis) {
                  cubit.pause();
                } else if (isPausedThis) {
                  cubit.resume();
                } else {
                  cubit.playAyah(widget.surahId, widget.ayahNumber);
                }
              },
            ),
            SizedBox(width: 16.w),
            _buildActionButton(
              context: context,
              icon: _isLastRead
                  ? Icons.bookmark_added
                  : Icons.bookmark_add_outlined,
              isActive: _isLastRead,
              onTap: _setAsLastRead,
            ),
            SizedBox(width: 16.w),
            _buildActionButton(
              context: context,
              icon: Icons.share_outlined,
              onTap: _showShareOptions,
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: isActive
            ? BoxDecoration(
                color:
                    (isDark
                            ? AppColors.primaryDarkColor
                            : AppColors.primaryLightColor)
                        .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              )
            : null,
        child: Icon(
          icon,
          color: isActive
              ? (isDark
                    ? AppColors.primaryDarkColor
                    : AppColors.primaryLightColor)
              : AppColors.textSecondary,
          size: 26,
        ),
      ),
    );
  }
}
