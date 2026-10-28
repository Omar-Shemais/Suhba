// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/quran_cubit.dart';
import '../cubit/quran_state.dart';
import '../widgets/surah_header.dart';
import '../../../../../core/widgets/custom_shimmer.dart';
import '../../../../../core/widgets/custom_error_widget.dart';

class SurahHeaderHandler extends StatelessWidget {
  final int surahId;

  const SurahHeaderHandler({super.key, required this.surahId});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<QuranCubit, QuranState>(
        builder: (context, state) {
          return switch (state) {
            QuranLoading() => const _HeaderShimmer(),

            QuranError() => Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomErrorWidget(
                message: state.message,
                icon: Icons.error_outline,
                iconSize: 48,
                onRetry: () =>
                    context.read<QuranCubit>().loadSurahById(surahId),
              ),
            ),

            SurahDetailLoaded() => SurahHeader(
              name: state.surah.name,
              translation: state.surah.translation,
              numberOfAyahs: state.surah.totalVerses,
            ),

            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _HeaderShimmer extends StatelessWidget {
  const _HeaderShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          CustomShimmer(
            width: 150.w,
            height: 24.h,
            borderRadius: BorderRadius.all(Radius.circular(8.r)),
          ),
          SizedBox(height: 12.h.h),
          CustomShimmer(
            width: 120.w,
            height: 16.h,
            borderRadius: BorderRadius.all(Radius.circular(8.r)),
          ),
          SizedBox(height: 8.h.h),
          CustomShimmer(
            width: 80.w,
            height: 14.h,
            borderRadius: BorderRadius.all(Radius.circular(8.r)),
          ),
        ],
      ),
    );
  }
}
