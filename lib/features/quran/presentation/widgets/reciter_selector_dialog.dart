import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/features/quran/data/helpers/reciter_storage_manager.dart';
import 'package:islamic_app/features/quran/data/models/audio_model.dart';
import 'package:islamic_app/features/quran/data/repositories/audio_repo.dart';
import 'package:islamic_app/features/quran/presentation/cubit/audio_cubit.dart';

class ReciterSelector extends StatefulWidget {
  final AudioRepository audioRepository;

  const ReciterSelector({super.key, required this.audioRepository});

  @override
  State<ReciterSelector> createState() => _ReciterSelectorState();
}

class _ReciterSelectorState extends State<ReciterSelector> {
  List<ReciterModel> _reciters = [];
  bool _isLoading = true;
  int _selectedReciterId = 2;

  @override
  void initState() {
    super.initState();
    _loadReciters();
  }

  Future<void> _loadReciters() async {
    try {
      // تحميل الشيوخ
      final reciters = await widget.audioRepository.getAllReciters();

      // تحميل الشيخ المحفوظ
      final savedReciterId = await ReciterStorageManager.getSelectedReciterId();

      if (mounted) {
        setState(() {
          _reciters = reciters;
          _selectedReciterId = savedReciterId;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.locale.languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'اختر القارئ' : 'Select Reciter',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.primaryDarkColor
                      : AppColors.primaryLightColor,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Loading or List
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _reciters.length,
                itemBuilder: (context, index) {
                  final reciter = _reciters[index];
                  final isSelected = reciter.id == _selectedReciterId;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    // ignore: deprecated_member_use
                    child: RadioListTile<int>(
                      value: reciter.id,
                      // ignore: deprecated_member_use
                      groupValue: _selectedReciterId,
                      // ignore: deprecated_member_use
                      onChanged: (value) async {
                        if (value != null) {
                          setState(() {
                            _selectedReciterId = value;
                          });

                          // حفظ الشيخ وتغييره
                          await ReciterStorageManager.saveSelectedReciter(
                            reciterId: reciter.id,
                            reciterName: reciter.name,
                            reciterArabicName: reciter.arabicName,
                          );

                          // تغيير القارئ في AudioCubit
                          if (context.mounted) {
                            context.read<AudioCubit>().changeReciter(
                              reciter.id,
                            );
                          }

                          // إظهار رسالة نجاح
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isArabic
                                      ? 'تم اختيار ${reciter.arabicName}'
                                      : 'Selected ${reciter.name}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: isDark
                                        ? AppColors.primaryLightColor
                                        : AppColors.primaryDarkColor,
                                  ),
                                ),
                                backgroundColor: isDark
                                    ? AppColors.primaryDarkColor
                                    : AppColors.primaryLightColor,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            );
                          }

                          // إغلاق البوتوم شيت بعد ثانية
                          await Future.delayed(
                            const Duration(milliseconds: 800),
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      title: Text(
                        isArabic ? reciter.arabicName : reciter.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        isArabic ? reciter.name : reciter.arabicName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      activeColor: isDark
                          ? AppColors.primaryDarkColor
                          : AppColors.primaryLightColor,
                      selected: isSelected,
                      selectedTileColor:
                          (isDark
                                  ? AppColors.primaryDarkColor
                                  : AppColors.primaryLightColor)
                              .withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  );
                },
              ),
            ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

// Helper function to show the bottom sheet
void showReciterSelector(
  BuildContext context,
  AudioRepository audioRepository,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (bottomSheetContext) {
      return BlocProvider.value(
        value: context.read<AudioCubit>(),
        child: ReciterSelector(audioRepository: audioRepository),
      );
    },
  );
}
