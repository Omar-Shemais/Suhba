import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_text_styles.dart';
import '../cubit/prayer_cubit.dart';
import '../widgets/features_grid_section.dart';
import '../widgets/home_loading_shimmer.dart';
import '../widgets/next_prayer_banner.dart';
import '../widgets/prayer_date_card.dart';
import '../widgets/prayer_times_list.dart';

class MainHomeViewBody extends StatelessWidget {
  const MainHomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PrayerCubit, PrayerState>(
      // ✅ Listener للتعامل مع حالات الخطأ
      listener: (context, state) {
        // عرض Snackbar لو حصل خطأ ومفيش بيانات قديمة
        if (state is PrayerError && state.lastSuccessfulState == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.white),
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
        }
        // عرض Snackbar بسيط لو فشل التحديث بس فيه بيانات قديمة
        else if (state is PrayerError && state.lastSuccessfulState != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل التحديث. يتم عرض آخر بيانات محفوظة'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },

      // ✅ Builder لعرض الواجهة
      builder: (context, state) {
        // حالة التحميل الأولي (بدون بيانات سابقة)
        if (state is PrayerLoading) {
          return HomeLoadingShimmer();
        }

        // حالة الخطأ بدون بيانات سابقة - نعرض صفحة خطأ
        if (state is PrayerError && state.lastSuccessfulState == null) {
          return _buildErrorWidget(context, state.message);
        }

        // ✅ استخراج البيانات من أي state فيه بيانات
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

        // لو مفيش بيانات خالص
        if (loadedData == null) {
          return const SizedBox.shrink();
        }

        // ✅ عرض البيانات مع RefreshIndicator
        return RefreshIndicator(
          onRefresh: () => context.read<PrayerCubit>().refreshPrayerTimes(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Next Prayer Banner
                    if (loadedData.nextPrayer != null)
                      NextPrayerBanner(
                        prayer: loadedData.nextPrayer!,
                        title: "app_name".tr(),
                      ),

                    // Date Card
                    PrayerDateCard(
                      timeRemaining: context
                          .read<PrayerCubit>()
                          .getTimeRemaining(loadedData.nextPrayer!.time),
                      prayer: loadedData.nextPrayer!,
                      date: loadedData.prayerTimes.date,
                      hijriDate: loadedData.prayerTimes.hijriDateAr,
                      city: loadedData.city,
                      country: loadedData.country,
                      enHijriDate: loadedData.prayerTimes.hijriDateEn,
                    ),

                    SizedBox(height: 16.h),

                    // Features Grid
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0.r),
                      child: FeaturesGridSection(),
                    ),

                    SizedBox(height: 16.h),

                    // Title
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        "prayer_times".tr(),
                        style: AppTextStyles.subHead,
                      ),
                    ),
                  ],
                ),
              ),

              // Prayer Times List
              PrayerTimesList(prayers: loadedData.prayers),

              SliverToBoxAdapter(child: SizedBox(height: 80.h)),
            ],
          ),
        );
      },
    );
  }

  /// ✅ Widget لعرض حالة الخطأ الكاملة (بدون بيانات سابقة)
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
              icon: Icon(Icons.refresh),
              label: Text('حاول مرة أخرى'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
