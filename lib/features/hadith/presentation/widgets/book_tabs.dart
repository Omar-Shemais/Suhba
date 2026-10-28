// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class BookTabs extends StatelessWidget {
  final String selectedBook;
  final Function(String) onBookSelected;

  const BookTabs({
    super.key,
    required this.selectedBook,
    required this.onBookSelected,
  });

  // static Map<String, String> books = {
  //   'all': 'all'.tr(),
  //   'sahih-bukhari': 'البخاري'.tr(),
  //   'sahih-muslim': 'مسلم'.tr(),
  //   'sunan-nasai': 'النسائي'.tr(),
  //   'abu-dawood': 'أبو داود'.tr(),
  //   'al-tirmidhi': 'الترمذي'.tr(),
  //   'ibn-e-majah': 'ابن ماجه'.tr(),
  // };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Map<String, String> books = {
      'all': 'all'.tr(),
      'sahih-bukhari': 'البخاري'.tr(),
      'sahih-muslim': 'مسلم'.tr(),
      'sunan-nasai': 'النسائي'.tr(),
      'abu-dawood': 'أبو داود'.tr(),
      'al-tirmidhi': 'الترمذي'.tr(),
      'ibn-e-majah': 'ابن ماجه'.tr(),
    };

    return SizedBox(
      height: 50.h.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final bookKey = books.keys.elementAt(index);
          final bookName = books[bookKey]!;
          final isSelected = selectedBook == bookKey;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: ChoiceChip(
              backgroundColor: isDark
                  ? const Color(0xFF282C32)
                  : const Color(0xFFFCFAF7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: BorderSide(
                  color: isSelected
                      ? (isDark
                            ? const Color(0xFF2E7D5E)
                            : const Color(0xFF143427))
                      : (isDark
                            ? const Color(0xFF383E46)
                            : const Color(0xFFEADBCE)),
                  width: 1.2.w,
                ),
              ),
              label: Text(bookName, style: TextStyle(fontSize: 14.sp)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onBookSelected(bookKey);
              },
              selectedColor: isDark
                  ? const Color(0xFF2E7D5E)
                  : const Color(0xFF143427),
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF736152)),
              ),
            ),
          );
        },
      ),
    );
  }
}
