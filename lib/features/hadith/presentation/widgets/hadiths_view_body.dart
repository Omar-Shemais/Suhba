import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/routes/app_routes.dart';
import '../cubit/hadith_cubit.dart';
import '../cubit/hadith_state.dart';
import '../widgets/book_tabs.dart';
import '../widgets/hadith_card.dart';
import '../widgets/hadith_loading_shimer.dart';
import '../../../../../core/widgets/custom_app_bar.dart';

class HadithsViewBody extends StatefulWidget {
  const HadithsViewBody({super.key});

  @override
  State<HadithsViewBody> createState() => _HadithsViewBodyState();
}

class _HadithsViewBodyState extends State<HadithsViewBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<HadithCubit>().loadMoreHadiths();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8.h),

        CustomAppBar(
          title: 'hadith'.tr(),
          leadingIcon: Icons.search,
          showReciterIcon: false,
          onMore: () {
            GoRouter.of(context).push(AppRoutes.hadithSearch);
          },
        ),
        SizedBox(height: 8.h),
        // Book Tabs
        BlocBuilder<HadithCubit, HadithState>(
          builder: (context, state) {
            final currentBook = context.read<HadithCubit>().currentBook;
            return BookTabs(
              selectedBook: currentBook,
              onBookSelected: (book) {
                context.read<HadithCubit>().loadHadiths(book: book);
              },
            );
          },
        ),

        // Hadiths List
        Expanded(
          child: BlocBuilder<HadithCubit, HadithState>(
            builder: (context, state) {
              if (state is HadithLoading) {
                return const Center(child: HadithCardShimmerList(itemCount: 4));
              }

              if (state is HadithError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getErrorIcon(state.message),
                          size: 80,
                          color: Colors.red.shade300,
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<HadithCubit>().loadHadiths();
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text('إعادة المحاولة'.tr()),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 12.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is HadithLoaded) {
                if (state.hadiths.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.library_books_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'لا توجد أحاديث'.tr(),
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: state.hadiths.length + (state.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.hadiths.length) {
                      return Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Center(
                          child: HadithCardShimmerList(itemCount: 4),
                        ),
                      );
                    }

                    return HadithCard(hadith: state.hadiths[index]);
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  IconData _getErrorIcon(String errorMessage) {
    if (errorMessage.contains('إنترنت') || errorMessage.contains('اتصال')) {
      return Icons.wifi_off;
    } else if (errorMessage.contains('مهلة') || errorMessage.contains('وقت')) {
      return Icons.access_time;
    } else if (errorMessage.contains('خادم')) {
      return Icons.cloud_off;
    } else {
      return Icons.error_outline;
    }
  }
}
