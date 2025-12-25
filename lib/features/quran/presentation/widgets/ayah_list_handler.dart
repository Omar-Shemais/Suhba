import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/quran_cubit.dart';
import '../cubit/quran_state.dart';
import '../widgets/ayah_card.dart';
import '../../../../../core/widgets/custom_shimmer.dart';
import '../../../../../core/widgets/custom_error_widget.dart';

class AyahListHandler extends StatelessWidget {
  final int surahId;

  const AyahListHandler({super.key, required this.surahId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranCubit, QuranState>(
      builder: (context, state) {
        return switch (state) {
          QuranLoading() => const _AyahListShimmer(),

          QuranError() => SliverToBoxAdapter(
            child: CustomErrorWidget(
              message: state.message,
              icon: Icons.warning_amber_rounded,
              iconSize: 60,
              onRetry: () => context.read<QuranCubit>().loadSurahById(surahId),
            ),
          ),

          SurahDetailLoaded() => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            sliver: SliverList.builder(
              itemCount: state.surah.verses.length,
              itemBuilder: (context, index) {
                final ayah = state.surah.verses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AyahCard(
                    ayah: ayah,
                    surahId: state.surah.id,
                    surahName: state.surah.name,
                    ensurahName: state.surah.translation,
                  ),
                );
              },
            ),
          ),

          _ => const SliverToBoxAdapter(child: SizedBox.shrink()),
        };
      },
    );
  }
}

class _AyahListShimmer extends StatelessWidget {
  const _AyahListShimmer();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomShimmer(
                      width: 60.w,
                      height: 30.h,
                      borderRadius: BorderRadius.all(Radius.circular(20.r)),
                    ),
                    Icon(Icons.more_horiz, color: Colors.grey),
                  ],
                ),
                SizedBox(height: 16.h),

                CustomShimmer(
                  width: double.infinity,
                  height: 24.h,
                  borderRadius: BorderRadius.all(Radius.circular(8.r)),
                ),
                SizedBox(height: 8.h),
                CustomShimmer(
                  width: double.infinity,
                  height: 24.h,
                  borderRadius: BorderRadius.all(Radius.circular(8.r)),
                ),
                SizedBox(height: 16.h),

                CustomShimmer(
                  width: double.infinity,
                  height: 16.h,
                  borderRadius: BorderRadius.all(Radius.circular(8.r)),
                ),
                SizedBox(height: 8.h),
                CustomShimmer(
                  width: 200.w,
                  height: 16.h,
                  borderRadius: BorderRadius.all(Radius.circular(8.r)),
                ),

                Divider(height: 30.h, thickness: 0.1),
              ],
            ),
          );
        },
      ),
    );
  }
}
