import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/prayer_times_model.dart';
import '../widgets/prayer_time_card.dart';

class PrayerTimesList extends StatelessWidget {
  final List<PrayerInfo> prayers;

  const PrayerTimesList({super.key, required this.prayers});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const BouncingScrollPhysics(),
        itemCount: prayers.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          return PrayerTimeCard(prayer: prayers[index]);
        },
      ),
    );
  }
}
