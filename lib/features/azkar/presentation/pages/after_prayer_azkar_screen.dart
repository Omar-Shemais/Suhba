import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/azkar_cubit.dart';
import '../widgets/azkar_reader_view.dart';

class AfterPrayerAzkarScreen extends StatelessWidget {
  const AfterPrayerAzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AzkarCubit()..getAfterPrayerAzkar(),
      child: AzkarReaderView(
        title: 'after_prayer_azkar'.tr(),
        icon: Icons.mosque_rounded,
        accentColor: const Color(0xFF2E7D32),
        azkarType: 'after_prayer',
      ),
    );
  }
}
