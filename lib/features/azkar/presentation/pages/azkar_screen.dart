import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/widgets/custom_app_bar.dart';
import '../pages/after_prayer_azkar_screen.dart';
import '../pages/evening_azkar_screen.dart';
import '../pages/morning_azkar.dart';

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface.withValues(alpha: .9),
              theme.colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomAppBar(title: 'azkar'.tr(), showReciterIcon: false),
                SizedBox(height: 60.h),
                _buildAzkarButton(
                  context,
                  icon: Icons.wb_sunny_outlined,
                  text: 'morning_azkar'.tr(),
                  color: Colors.orangeAccent,
                  screen: const MorningAzkar(),
                  theme: theme,
                ),
                SizedBox(height: 18.h),
                _buildAzkarButton(
                  context,
                  icon: Icons.nights_stay_outlined,
                  text: 'evening_azkar'.tr(),
                  color: Colors.indigoAccent,
                  screen: const EveningAzkarScreen(),
                  theme: theme,
                ),
                SizedBox(height: 18.h),
                _buildAzkarButton(
                  context,
                  icon: Icons.mosque_outlined,
                  text: 'after_prayer_azkar'.tr(),
                  color: Colors.green,
                  screen: const AfterPrayerAzkarScreen(),
                  theme: theme,
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAzkarButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
    required Widget screen,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: .3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: .7),
            ),
          ],
        ),
      ),
    );
  }
}

/*
class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFAE8C8), Color(0xFFF5D491)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30.h),
                Text(
                  'azkar'.tr(),
                  style: const TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF704214),
                  ),
                ),
                const SizedBox(height: 60.h),

                _buildAzkarButton(
                  context,
                  icon: Icons.wb_sunny_outlined,
                  text: 'morning_azkar'.tr(),
                  color: Colors.orangeAccent,
                  screen: const MorningAzkar(),
                ),
                const SizedBox(height: 18.h),
                _buildAzkarButton(
                  context,
                  icon: Icons.nights_stay_outlined,
                  text: 'evening_azkar'.tr(),
                  color: Colors.indigoAccent,
                  screen: const EveningAzkarScreen(),
                ),
                const SizedBox(height: 18.h),
                _buildAzkarButton(
                  context,
                  icon: Icons.mosque_outlined,
                  text: 'after_prayer_azkar'.tr(),
                  color: Colors.green,
                  screen: const AfterPrayerAzkarScreen(),
                ),

                const SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAzkarButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
    required Widget screen,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: .3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

*/

/*
class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // خلفية متدرجة ناعمة
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFAE8C8), Color(0xFFF5D491)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // العنوان في الأعلى
                const SizedBox(height: 20.h),
                Text(
                  'azkar'.tr(),
                  style: const TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF704214),
                  ),
                ),
                const SizedBox(height: 30.h),

                // صورة رمزية للأذكار
                Image.asset('assets/images/azkar.png', width: 180.w, height: 180.h),

                const SizedBox(height: 40.h),

             
                _buildAzkarButton(
                  context,
                  icon: Icons.wb_sunny_outlined,
                  text: 'morning_azkar'.tr(),
                  color: Colors.orangeAccent,
                  screen: const MorningAzkar(),
                ),
                const SizedBox(height: 18.h),
                _buildAzkarButton(
                  context,
                  icon: Icons.nights_stay_outlined,
                  text: 'evening_azkar'.tr(),
                  color: Colors.indigoAccent,
                  screen: const EveningAzkarScreen(),
                ),
                const SizedBox(height: 18.h),
                _buildAzkarButton(
                  context,
                  icon: Icons.mosque_outlined,
                  text: 'after_prayer_azkar'.tr(),
                  color: Colors.green,
                  screen: const AfterPrayerAzkarScreen(),
                ),

                const Spacer(),

               
                Text(
                  "تطبيق الأذكار",
                  style: TextStyle(
                    color: Colors.brown.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAzkarButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
    required Widget screen,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: .3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
*/

/*
class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text('azkar'.tr())),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              text: 'morning_azkar'.tr(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MorningAzkar();
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 15.h),
            CustomButton(
              text: 'evening_azkar'.tr(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return EveningAzkarScreen();
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 15.h),

            CustomButton(
              text: 'after_prayer_azkar'.tr(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return AfterPrayerAzkarScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
*/
