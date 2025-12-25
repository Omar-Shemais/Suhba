import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/widgets/custom_app_bar.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  int count = 0;
  final List<String> azkarList = [
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'لا إله إلا الله',
  ];

  int currentZekrIndex = 0;

  void _increment() {
    setState(() {
      count++;
    });
  }

  void _reset() {
    setState(() {
      count = 0;
    });
  }

  void _nextZekr() {
    setState(() {
      count = 0;
      if (currentZekrIndex < azkarList.length - 1) {
        currentZekrIndex++;
      } else {
        currentZekrIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: 'tasbeeh'.tr(), showReciterIcon: false),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            azkarList[currentZekrIndex],
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30.h),
          Text(
            '$count',
            style: theme.textTheme.displayMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 50.h),
          GestureDetector(
            onTap: _increment,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 180.h,
              width: 180.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: .4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.fingerprint,
                color: theme.colorScheme.onPrimary,
                size: 70,
              ),
            ),
          ),
          SizedBox(height: 40.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                onPressed: _reset,
                icon: Icon(Icons.refresh, color: theme.colorScheme.onPrimary),
                label: Text(
                  'reset'.tr(),
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
              ),
              SizedBox(width: 20.w),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                onPressed: _nextZekr,
                icon: Icon(
                  Icons.arrow_forward,
                  color: theme.colorScheme.onPrimary,
                ),
                label: Text(
                  'next'.tr(),
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/*

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  int count = 2;
  final List<String> azkarList = [
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'لا إله إلا الله',
  ];
  int currentZekrIndex = 0;

  void _increment() {
    setState(() {
      count++;
    });
  }

  void _reset() {
    setState(() {
      count = 0;
    });
  }

  void _nextZekr() {
    setState(() {
      count = 0;
      if (currentZekrIndex < azkarList.length - 1) {
        currentZekrIndex++;
      } else {
        currentZekrIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'المسبحة',
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            azkarList[currentZekrIndex],
            style: const TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryColor,
            ),
          ),
          const SizedBox(height: 30.h),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 70.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.blackColor,
            ),
          ),
          const SizedBox(height: 50.h),
          GestureDetector(
            onTap: _increment,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 180.h,
              width: 180.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: .4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.fingerprint,
                color: AppColors.whiteColor,
                size: 70,
              ),
            ),
          ),
          const SizedBox(height: 40.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                onPressed: _reset,
                icon: const Icon(Icons.refresh, color: AppColors.whiteColor),
                label: const Text(
                  'تصفير',
                  style: TextStyle(color: AppColors.whiteColor),
                ),
              ),
              const SizedBox(width: 20.w),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                onPressed: _nextZekr,
                icon: const Icon(
                  Icons.arrow_forward,
                  color: AppColors.whiteColor,
                ),
                label: const Text(
                  'التالي',
                  style: TextStyle(color: AppColors.whiteColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/
