import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_text_styles.dart';
import 'package:islamic_app/core/theme/app_scroll_behavior.dart';
import 'package:islamic_app/core/widgets/smooth_entrance_widget.dart';
import '../cubit/prayer_cubit.dart';
import '../widgets/home_header_widget.dart';
import '../widgets/home_loading_shimmer.dart';
import '../widgets/home_prayer_card.dart';
import '../widgets/home_quran_reading_card.dart';
import '../widgets/home_quick_dhikr_card.dart';
import '../widgets/home_quick_actions_grid.dart';

class MainHomeViewBody extends StatelessWidget {
  const MainHomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF1E2125) : const Color(0xFFFAF5ED),
      child: BlocConsumer<PrayerCubit, PrayerState>(
        listener: (context, state) {
          if (state is PrayerError && state.lastSuccessfulState == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white),
                    SizedBox(width: 12.w),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'حاول مرة أخرى',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<PrayerCubit>().loadPrayerTimes();
                  },
                ),
              ),
            );
          } else if (state is PrayerError && state.lastSuccessfulState != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('فشل التحديث. يتم عرض آخر بيانات محفوظة'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PrayerLoading) {
            return const HomeLoadingShimmer();
          }

          if (state is PrayerError && state.lastSuccessfulState == null) {
            return _buildErrorWidget(context, state.message);
          }

          PrayerLoaded? loadedData;
          if (state is PrayerLoaded) {
            loadedData = state;
          } else if (state is PrayerRefreshing) {
            loadedData = state.currentData;
          } else if (state is PrayerLocationLoading) {
            loadedData = state.currentData;
          } else if (state is PrayerError && state.lastSuccessfulState != null) {
            loadedData = state.lastSuccessfulState;
          }

          if (loadedData == null) {
            return const SizedBox.shrink();
          }

          final nextPrayer = loadedData.nextPrayer ?? loadedData.prayers.first;
          final timeRemaining = context
              .read<PrayerCubit>()
              .getTimeRemaining(nextPrayer.time);

          return SingleChildScrollView(
            physics: const SmoothBouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. الهيدر الفني العلوي مع الترحيب واسم صُحبة وزر الإشعارات
                const SmoothEntranceWidget(
                  delay: Duration.zero,
                  child: HomeHeaderWidget(),
                ),

                SizedBox(height: 12.h),

                // 2. بطاقة متابعة قراءة القرآن الكريم باللون الأخضر الملكي مع المجسم ثلاثي الأبعاد
                const SmoothEntranceWidget(
                  delay: Duration(milliseconds: 60),
                  child: HomeQuranReadingCard(),
                ),

                SizedBox(height: 14.h),

                // 3. بطاقة الزاد السريع والأذكار التفاعلية الذكية (فوق مواقيت الصلاة)
                const SmoothEntranceWidget(
                  delay: Duration(milliseconds: 120),
                  child: HomeQuickDhikrCard(),
                ),

                SizedBox(height: 14.h),

                // 4. بطاقة الصلاة القادمة والعداد التنازلي مع شريط مواقيت الصلاة الستة
                SmoothEntranceWidget(
                  delay: const Duration(milliseconds: 180),
                  child: HomePrayerCard(
                    nextPrayer: nextPrayer,
                    timeRemaining: timeRemaining,
                    prayers: loadedData.prayers,
                  ),
                ),

                SizedBox(height: 14.h),

                // 5. شبكة الخدمات السريعة (القرآن الكريم، الأذكار، الأحاديث، الأدعية، القبلة، المساجد القريبة، تسبيح، المزيد)
                const SmoothEntranceWidget(
                  delay: Duration(milliseconds: 240),
                  child: HomeQuickActionsGrid(),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 80.sp, color: Colors.grey[400]),
            SizedBox(height: 24.h),
            Text(
              'لا يوجد اتصال بالإنترنت',
              style: AppTextStyles.headline.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى',
              style: AppTextStyles.secondary.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () {
                context.read<PrayerCubit>().loadPrayerTimes();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('حاول مرة أخرى'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF143427),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
