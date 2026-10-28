// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/widgets/custom_shimmer.dart';

class HomeLoadingShimmer extends StatelessWidget {
  const HomeLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 10.h)),

        // Next Prayer Banner Shimmer
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: CustomShimmer(
              width: double.infinity,
              height: 240.h,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 4.h)),
        // Date Card Shimmer
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: CustomShimmer(
              width: double.infinity,
              height: 80.h,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 16.h)),

        // Features Grid Shimmer
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                return CustomShimmer(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: BorderRadius.circular(12.r),
                );
              },
            ),
          ),
        ),

        // Prayer Times List Shimmer
        SliverToBoxAdapter(
          child: SizedBox(
            height: 160.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(16.r),
              itemCount: 6,
              separatorBuilder: (context, index) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                return CustomShimmer(
                  width: 100.w,
                  height: 150.h,
                  borderRadius: BorderRadius.circular(16.r),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
