import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum QuranTabFilter { all, meccan, medinan, juz, hizb }

class QuranFilterTabs extends StatelessWidget {
  final QuranTabFilter selectedFilter;
  final ValueChanged<QuranTabFilter> onFilterChanged;

  const QuranFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tabs = [
      {'filter': QuranTabFilter.all, 'label': 'الكل'},
      {'filter': QuranTabFilter.meccan, 'label': 'مكية'},
      {'filter': QuranTabFilter.medinan, 'label': 'مدنية'},
      {'filter': QuranTabFilter.juz, 'label': 'الجزء'},
      {'filter': QuranTabFilter.hizb, 'label': 'الحزب'},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: tabs.map((tab) {
          final filter = tab['filter'] as QuranTabFilter;
          final label = tab['label'] as String;
          final isSelected = selectedFilter == filter;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onFilterChanged(filter),
                  borderRadius: BorderRadius.circular(20.r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF143427)
                          : isDark
                              ? const Color(0xFF2C2219)
                              : const Color(0xFFF3ECE0),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF143427)
                            : isDark
                                ? const Color(0xFF3D3126)
                                : const Color(0xFFE8DFCF),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF143427)
                                    .withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : isDark
                                  ? const Color(0xFFC7B7A6)
                                  : const Color(0xFF8C7A6B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
