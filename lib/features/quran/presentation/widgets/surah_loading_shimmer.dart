import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/widgets/custom_shimmer.dart';

class SurahsloadingShimmer extends StatelessWidget {
  const SurahsloadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              // رقم السورة
              CustomShimmer(
                width: 50.w,
                height: 50.h,
                borderRadius: BorderRadius.all(Radius.circular(8.r)),
              ),
              SizedBox(width: 12.w),
              // بيانات السورة
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
}
