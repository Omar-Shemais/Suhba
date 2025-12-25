import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/quran_cubit.dart';
import '../cubit/quran_state.dart';
import '../pages/surah_detail_screen.dart';
import '../widgets/surah_list_item.dart';
import '../../../../../core/widgets/custom_error_widget.dart';
import '../../../../../core/widgets/custom_shimmer.dart';

class SurahList extends StatelessWidget {
  const SurahList({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<QuranCubit, QuranState>(
        builder: (context, state) {
          if (state is QuranLoading) {
            return ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      CustomShimmer(width: 50.w, height: 50.h),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomShimmer(
                              width: double.infinity,
                              height: 16.h,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            SizedBox(height: 8.h),
                            CustomShimmer(
                              width: 120.w,
                              height: 12.h,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          // Error
          if (state is QuranError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () => context.read<QuranCubit>().loadSurahs(),
            );
          }

          // Loaded
          if (state is QuranLoaded) {
            final surahs = state.surahs;

            if (surahs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                    SizedBox(height: 16.h),
                    Text(
                      "no_result".tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: surahs.length,
              itemBuilder: (context, index) {
                final surah = surahs[index];
                return SurahListItem(
                  surah: surah,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SurahDetailScreen(surahId: surah.id),
                      ),
                    );
                  },
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
