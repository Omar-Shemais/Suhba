import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/azkar_cubit.dart';
import '../widgets/azkar_reader_view.dart';

class EveningAzkarScreen extends StatelessWidget {
  const EveningAzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AzkarCubit()..getEveningAzkar(),
      child: AzkarReaderView(
        title: 'evening_azkar'.tr(),
        icon: Icons.nights_stay_rounded,
        accentColor: const Color(0xFF6C63FF),
        azkarType: 'evening',
      ),
    );
  }
}
