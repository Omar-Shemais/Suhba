import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/surah_header_handler.dart';
import '../widgets/ayah_list_handler.dart';
import '../../../../../core/widgets/custom_app_bar.dart';

class SurahDetailViewBody extends StatelessWidget {
  final int surahId;

  const SurahDetailViewBody({super.key, required this.surahId});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomAppBar(title: 'quran'.tr()),
          ),
        ),

        // ✅ Surah Header
        SurahHeaderHandler(surahId: surahId),

        SliverToBoxAdapter(child: SizedBox(height: 16.h)),

        // ✅ Ayah List
        AyahListHandler(surahId: surahId),

        SliverToBoxAdapter(child: SizedBox(height: 80.h)),
      ],
    );
  }
}
