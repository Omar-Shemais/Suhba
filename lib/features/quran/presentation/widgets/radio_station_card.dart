import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/constants/app_text_styles.dart';
import '../../data/models/audio_model.dart';
import '../cubit/audio_cubit.dart';
import '../cubit/audio_state.dart';

class RadioStationCard extends StatelessWidget {
  final RadioStationModel station;

  const RadioStationCard({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    // ✅ Listen to AudioCubit directly.
    // The UI now automatically updates if the Notification stops the radio!
    return BlocBuilder<AudioCubit, AudioState>(
      builder: (context, state) {
        // Check if THIS station is the one currently playing
        final isPlayingThis =
            state is AudioPlayingRadio && state.url == station.url;

        return Card(
          margin: const EdgeInsets.only(bottom: 18),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(
              color: isPlayingThis
                  ? AppColors.primaryColor
                  : Colors.transparent,
              width: 2.w,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () {
              if (isPlayingThis) {
                // 🛑 Stop Radio
                context.read<AudioCubit>().stop();
              } else {
                // ▶️ Play Radio
                context.read<AudioCubit>().playRadio(
                  station.url,
                  stationName: station.name, // Make sure to pass the name!
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _RadioIcon(isPlaying: isPlayingThis),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _StationInfo(
                      station: station,
                      isPlaying: isPlayingThis,
                    ),
                  ),
                  Icon(
                    isPlayingThis ? Icons.pause_circle : Icons.play_circle,
                    color: AppColors.primaryColor,
                    size: 36,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ... _RadioIcon and _StationInfo classes remain the same ...
// Keep your existing _RadioIcon and _StationInfo classes below this
class _RadioIcon extends StatelessWidget {
  final bool isPlaying;
  const _RadioIcon({required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.4), // Fixed .withValues
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        isPlaying ? Icons.pause : Icons.radio,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}

class _StationInfo extends StatelessWidget {
  final RadioStationModel station;
  final bool isPlaying;

  const _StationInfo({required this.station, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          station.arabicName,
          style: AppTextStyles.subHead,
        ), // Ensure style exists
        SizedBox(height: 4.h),
        Text(
          station.name,
          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
        ), // Fallback style
        if (isPlaying) ...[SizedBox(height: 8.h), const _LiveIndicator()],
      ],
    );
  }
}

class _LiveIndicator extends StatelessWidget {
  const _LiveIndicator();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.h,
          decoration: const BoxDecoration(
            color: Colors.redAccent, // Changed to Red for "Live" look
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          "live".tr(),
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
