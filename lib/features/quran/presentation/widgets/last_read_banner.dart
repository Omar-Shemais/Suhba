// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/constants/app_text_styles.dart';
import 'package:islamic_app/core/constants/assets.dart';
import 'package:islamic_app/features/quran/data/helpers/last_read_storage.dart';
import 'package:islamic_app/features/quran/presentation/pages/surah_detail_screen.dart';

class LastReadBanner extends StatefulWidget {
  const LastReadBanner({super.key});

  @override
  State<LastReadBanner> createState() => _LastReadBannerState();
}

class _LastReadBannerState extends State<LastReadBanner> {
  LastReadModel? _lastRead;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLastRead();

    // 🔥 إضافة الليسنر بدون أي تغيير في الشكل
    LastReadManager.lastReadUpdated.addListener(_loadLastRead);
  }

  @override
  void dispose() {
    LastReadManager.lastReadUpdated.removeListener(_loadLastRead);
    super.dispose();
  }

  Future<void> _loadLastRead() async {
    final lastRead = await LastReadManager.getLastRead();
    if (mounted) {
      setState(() {
        _lastRead = lastRead;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = EasyLocalization.of(context)?.locale.languageCode == 'ar';
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: 150.h,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: InkWell(
        onTap: () {
          if (_lastRead != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SurahDetailScreen(surahId: _lastRead!.surahId),
              ),
            ).then((_) => _loadLastRead());
          }
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDark ? AppColors.primaryDarkColor : AppColors.primaryColor,
                isDark
                    ? AppColors.primaryDarkColor.withOpacity(0.4)
                    : AppColors.primaryColor.withOpacity(0.5),
                isDark
                    ? AppColors.primaryDarkColor.withOpacity(0.1)
                    : AppColors.primaryColor.withOpacity(0.1),
              ],
              begin: Alignment.bottomRight,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: -10,
                right: -10,
                child: Image.asset(
                  AssetsData.game3,
                  width: 200.w,
                  height: 100.h,
                  fit: BoxFit.cover,
                  opacity: isDark
                      ? const AlwaysStoppedAnimation(.3)
                      : const AlwaysStoppedAnimation(1),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),
                            Text("Last_Read".tr(), style: AppTextStyles.body),
                            SizedBox(height: 8.h),
                            Text(
                              isArabic
                                  ? _lastRead!.surahName
                                  : _lastRead?.surahNameArabic ??
                                        'سُورَةُ ٱلْفَاتِحَةِ',
                              style: AppTextStyles.basmala(
                                context,
                              ).copyWith(fontSize: 24.sp),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${"Ayah_No".tr()}: ${_lastRead?.ayahNumber ?? 1}',
                              style: AppTextStyles.secondary,
                            ),
                          ],
                        ),
                      ),
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
