import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import '../cubit/audio_cubit.dart';
import '../cubit/audio_state.dart';

class AudioButton extends StatelessWidget {
  final int surahId;

  const AudioButton({super.key, required this.surahId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AudioCubit, AudioState>(
      builder: (context, state) {
        final audioCubit = context.read<AudioCubit>();

        // 1. Check if THIS Surah is the one currently active
        final bool isCurrentSurah =
            (state is AudioPlaying && state.currentSurahId == surahId) ||
            (state is AudioPaused && state.currentSurahId == surahId);

        // 2. Determine playing status
        final bool isPlaying = state is AudioPlaying && isCurrentSurah;
        final bool isPaused = state is AudioPaused && isCurrentSurah;

        IconData icon;
        String label;

        if (isPlaying) {
          icon = Icons.pause_circle_filled_rounded;
          label = "Pause_Audio".tr();
        } else if (isPaused) {
          icon = Icons.play_circle_fill_rounded;
          label = "Resume_Audio".tr();
        } else {
          icon = Icons.play_arrow_rounded;
          label = "Play_Audio".tr();
        }

        return GestureDetector(
          onTap: () {
            if (isPlaying) {
              audioCubit.pause();
            } else if (isPaused) {
              audioCubit.resume();
            } else {
              audioCubit.playSurah(surahId);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryDarkColor
                  : const Color.fromARGB(255, 250, 198, 114),
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    icon,
                    key: ValueKey(icon),
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
