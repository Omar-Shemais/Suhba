import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/quran_cubit.dart';
import '../cubit/quran_state.dart';
import '../pages/surah_detail_screen.dart';
import '../surah_search_screen.dart';
import '../widgets/last_read_banner.dart';
import '../widgets/main_app_bar.dart';
import '../widgets/surah_list_item.dart';
import '../widgets/surah_loading_shimmer.dart';
import '../widgets/surah_tabs.dart';
import '../../../../../core/widgets/custom_error_widget.dart';

class QuranViewBody extends StatelessWidget {
  const QuranViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          MainAppBar(
            title: 'quran'.tr(),
            onSearchTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuranSearchScreen(),
                ),
              );
            },
          ),

          const LastReadBanner(),

          SizedBox(height: 16.h),

          const SurahTabs(),

          SizedBox(height: 16.h),

          Expanded(
            child: BlocBuilder<QuranCubit, QuranState>(
              builder: (context, state) {
                // Loading State مع Shimmer
                if (state is QuranLoading) {
                  return SurahsloadingShimmer();
                }

                // Error State
                if (state is QuranError) {
                  return CustomErrorWidget(
                    message: state.message,
                    onRetry: () {
                      context.read<QuranCubit>().loadSurahs();
                    },
                  );
                }

                // Loaded State
                if (state is QuranLoaded) {
                  final surahs = state.surahs;

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
          ),
        ],
      ),
    );
  }
}
