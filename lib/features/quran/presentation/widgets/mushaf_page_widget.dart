// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import '../../data/models/mushaf_models.dart';
import 'mushaf_text_builder.dart';

class MushafPageWidget extends StatelessWidget {
  final MushafPage page;
  final Function(bool)? onZoomChanged;
  final double textScale;

  const MushafPageWidget({
    super.key,
    required this.page,
    this.onZoomChanged,
    this.textScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: isDark ? const Color(0xFF1E2125) : const Color(0xFFFAF5ED),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF282C32) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: MushafTextBuilder.buildContinuousText(
                          verses: page.verses,
                          isDark: isDark,
                          isArabic: isArabic,
                          textScale: textScale,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
