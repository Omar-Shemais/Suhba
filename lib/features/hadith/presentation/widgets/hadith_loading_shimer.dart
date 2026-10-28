import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/widgets/custom_shimmer.dart';

class HadithCardShimmerList extends StatelessWidget {
  final int itemCount;

  const HadithCardShimmerList({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // رقم الحديث
                CustomShimmer(
                  width: 80.w,
                  height: 20.h,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                SizedBox(height: 12.h),

                // اسم الكتاب
                CustomShimmer(
                  width: 100.w,
                  height: 18.h,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                SizedBox(height: 16.h),

                // Arabic Narrator
                CustomShimmer(
                  width: double.infinity,
                  height: 40.h,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                SizedBox(height: 16.h),

                // Arabic Hadith Text
                CustomShimmer(
                  width: double.infinity,
                  height: 80.h,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                SizedBox(height: 16.h),

                // English Translation
                CustomShimmer(
                  width: double.infinity,
                  height: 80.h,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
