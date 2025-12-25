import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/utils/service_locator.dart';
import 'package:islamic_app/features/quran/data/repositories/quran_repo.dart';
import 'package:islamic_app/features/quran/presentation/cubit/quran_cubit.dart';
import 'package:islamic_app/features/quran/presentation/cubit/quran_state.dart';
import 'package:islamic_app/features/quran/presentation/pages/surah_detail_screen.dart';
import 'package:islamic_app/features/quran/presentation/widgets/surah_list_item.dart';

class QuranSearchScreen extends StatefulWidget {
  const QuranSearchScreen({super.key});

  @override
  State<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends State<QuranSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late QuranCubit _quranCubit;

  @override
  void initState() {
    super.initState();
    _quranCubit = QuranCubit(getIt<QuranRepository>())..loadSurahs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quranCubit.close();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      _quranCubit.loadSurahs();
    } else {
      _quranCubit.searchSurahs(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.locale.languageCode == 'ar';

    return BlocProvider.value(
      value: _quranCubit,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // زر الرجوع
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8.w),

                  // مربع البحث
                  Expanded(
                    child: Container(
                      height: 45.h,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16.sp,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          hintText: isArabic
                              ? 'ابحث عن سورة...'
                              : 'Search for surah...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 15.sp,
                          ),
                          border: InputBorder.none,
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                )
                              : Icon(
                                  Icons.search,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: BlocBuilder<QuranCubit, QuranState>(
          builder: (context, state) {
            if (state is QuranLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is QuranError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16.h),
                    Text(state.message),
                  ],
                ),
              );
            }

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
                        isArabic ? 'لا توجد نتائج' : 'No results found',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: surahs.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
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
    );
  }
}
