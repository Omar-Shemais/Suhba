import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import '../../data/model/sibha_model.dart';

class DhikrSelectorBottomSheet extends StatelessWidget {
  final List<SibhaModel> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const DhikrSelectorBottomSheet({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  static Future<void> show(
    BuildContext context, {
    required List<SibhaModel> items,
    required int selectedIndex,
    required ValueChanged<int> onSelect,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DhikrSelectorBottomSheet(
        items: items,
        selectedIndex: selectedIndex,
        onSelect: onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.72,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF282C32) : const Color(0xFFFAF5ED),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(
            color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // شريط السحب
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 14.h),

            // عنوان الشيت
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E382B)
                            : const Color(0xFFE8F1EC),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: const Color(0xFF143427),
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اختيار الذكر والتسبيح',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF38291D),
                          ),
                        ),
                        Text(
                          'اختر الذكر أو الصلاة على النبي للتسبيح',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: isDark
                                ? Colors.white54
                                : const Color(0xFF8C7A6B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white70 : const Color(0xFF38291D),
                    size: 20.sp,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const Divider(height: 22, thickness: 0.8),

            // قائمة الأذكار
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = index == selectedIndex;
                  final isSalawat = item.nameAr.contains('صَلِّ') ||
                      item.nameAr.contains('صَلَّى');

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      onSelect(index);
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                ? const Color(0xFF1E382B)
                                : const Color(0xFFE8F1EC))
                            : (isDark
                                ? const Color(0xFF1E2125)
                                : Colors.white),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF143427)
                              : (isDark
                                  ? const Color(0xFF383E46)
                                  : const Color(0xFFEADBCE)),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // أيقونة الحالة
                          Container(
                            width: 32.w,
                            height: 32.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? const Color(0xFF143427)
                                  : (isDark ? Colors.white10 : Colors.black12),
                            ),
                            child: Icon(
                              isSelected
                                  ? Icons.check_rounded
                                  : (isSalawat
                                      ? Icons.favorite_rounded
                                      : Icons.radio_button_unchecked_rounded),
                              color: isSelected
                                  ? Colors.white
                                  : (isSalawat
                                      ? AppColors.goldenPrimary
                                      : Colors.grey),
                              size: 18.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),

                          // نصوص الذكر
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.nameAr,
                                        style: TextStyle(
                                          fontFamily: 'Amiri',
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? const Color(0xFF143427)
                                              : (isDark
                                                  ? Colors.white
                                                  : const Color(0xFF231B15)),
                                        ),
                                      ),
                                    ),
                                    if (isSalawat) ...[
                                      SizedBox(width: 6.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.goldenPrimary
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          border: Border.all(
                                            color: AppColors.goldenPrimary,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          'صلاة على النبي',
                                          style: TextStyle(
                                            fontFamily: 'Amiri',
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? AppColors.goldenPrimary
                                                : const Color(0xFF38291D),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  item.nameEn,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: isDark
                                        ? Colors.white54
                                        : const Color(0xFF8C7A6B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
