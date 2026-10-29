import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/models/audio_model.dart';
import '../cubit/audio_cubit.dart';
import '../cubit/audio_state.dart';

class RadioStationCard extends StatelessWidget {
  final RadioStationModel station;
  final int index;

  const RadioStationCard({
    super.key,
    required this.station,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioCubit, AudioState>(
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryColor =
            isDark ? const Color(0xFF2E7D5E) : const Color(0xFF143427);

        final isPlayingThis =
            state is AudioPlayingRadio && state.url == station.url;

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF282C32) : const Color(0xFFFCFAF7),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isPlayingThis
                  ? primaryColor
                  : (isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE)),
              width: isPlayingThis ? 1.8.w : 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: () {
                if (isPlayingThis) {
                  context.read<AudioCubit>().stop();
                } else {
                  context.read<AudioCubit>().playRadio(
                    station.url,
                    stationName: station.name,
                  );
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Row(
                  children: [
                    // زر التشغيل الدائري الفاخر ذو الإطار الذهبي على اليسار
                    Container(
                      width: 42.w,
                      height: 42.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? const Color(0xFF261E16)
                            : const Color(0xFF2C2219),
                        border: Border.all(
                          color: const Color(0xFFC7A87A),
                          width: 1.5.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isPlayingThis
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),

                    // اسم المحطة والإذاعة في المنتصف
                    Expanded(
                      child: _StationInfo(
                        station: station,
                        isPlaying: isPlayingThis,
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // أيقونة المحطة على اليمين (تتناوب بين الأخضر الغابي والبني البرونزي)
                    _RadioIcon(
                      isPlaying: isPlayingThis,
                      category: station.category,
                      index: index,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RadioIcon extends StatelessWidget {
  final bool isPlaying;
  final String category;
  final int index;

  const _RadioIcon({
    required this.isPlaying,
    required this.category,
    required this.index,
  });

  IconData _getIcon() {
    if (isPlaying) return Icons.graphic_eq_rounded;
    switch (category) {
      case 'hadith':
        return Icons.auto_stories_rounded;
      case 'azkar':
        return Icons.wb_sunny_rounded;
      case 'quran':
      default:
        return Icons.menu_book_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // التناوب الجمالي كما في الصورة المرجعية: كارت أخضر داكن وكارت بني برونزي
    final iconBgColor = index.isEven
        ? const Color(0xFF143427) // أخضر غابي ملكي
        : const Color(0xFF4A3525); // بني برونزي دافئ

    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: iconBgColor,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: isPlaying
            ? [
                BoxShadow(
                  color: iconBgColor.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          _getIcon(),
          color: Colors.white,
          size: 24.sp,
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title =
        station.arabicName.isNotEmpty ? station.arabicName : station.name;
    final showSubtitle =
        station.name.isNotEmpty && station.name != station.arabicName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 14.5.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF38291D),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (showSubtitle) ...[
          SizedBox(height: 3.h),
          Text(
            station.name,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11.5.sp,
              color: isDark ? Colors.white60 : const Color(0xFF8C7A6B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (isPlaying) ...[
          SizedBox(height: 4.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "live".tr(),
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 5.w),
              Container(
                width: 7.w,
                height: 7.w,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
