import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/azkar_cubit.dart';
import '../widgets/azkar_reader_view.dart';

class MorningAzkar extends StatelessWidget {
  const MorningAzkar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AzkarCubit()..getMorningAzkar(),
      child: AzkarReaderView(
        title: 'morning_azkar'.tr(),
        icon: Icons.wb_sunny_rounded,
        accentColor: const Color(0xFFE5A93C),
        azkarType: 'morning',
      ),
    );
  }
}
