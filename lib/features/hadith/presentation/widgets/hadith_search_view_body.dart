import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/hadith_card.dart';

class HadithSearchViewBody extends StatefulWidget {
  const HadithSearchViewBody({super.key});

  @override
  State<HadithSearchViewBody> createState() => _HadithSearchViewBodyState();
}

class _HadithSearchViewBodyState extends State<HadithSearchViewBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back, size: 24.sp),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث في الأحاديث...'.tr(),
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<SearchCubit>().clear();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: Colors.green.shade400,
                        width: 2.w,
                      ),
                    ),
                  ),
                  onSubmitted: (query) {
                    if (query.trim().isNotEmpty) {
                      context.read<SearchCubit>().search(query.trim());
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Search Results
        Expanded(
          child: BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              if (state is SearchInitial) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 100,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'ابحث في الأحاديث النبوية'.tr(),
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'يمكنك البحث بالعربية أو الإنجليزية'.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is SearchLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16.h),
                      Text(
                        'جاري البحث...'.tr(),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              if (state is SearchError) {
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
                            final query = _searchController.text.trim();
                            if (query.isNotEmpty) {
                              context.read<SearchCubit>().search(query);
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة').tr(),
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

              if (state is SearchLoaded) {
                if (state.results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 100,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'لم يتم العثور على نتائج'.tr(),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'حاول استخدام كلمات مختلفة'.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // عدد النتائج
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      color: Colors.green.shade50,
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'results_found'.tr(
                              args: [state.results.length.toString()],
                            ),
                            style: TextStyle(
                              color: Colors.green.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // قائمة النتائج
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.results.length,
                        itemBuilder: (context, index) {
                          return HadithCard(hadith: state.results[index]);
                        },
                      ),
                    ),
                  ],
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
