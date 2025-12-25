import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_text_styles.dart';

class FeatureItemCard extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback onTap;

  const FeatureItemCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(color: Colors.transparent),
              child: icon,
            ),

            SizedBox(height: 4.h),

            // Title
            Text(
              title,
              style: AppTextStyles.textstyle14.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
