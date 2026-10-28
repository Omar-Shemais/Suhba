import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islamic_app/core/utils/service_locator.dart';
import '../../data/repositories/quran_repo.dart';
import '../cubit/quran_cubit.dart';
import '../widgets/quran_view_body.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => QuranCubit(getIt<QuranRepository>())..loadSurahs(),
        child: QuranViewBody(),
      ),
    );
  }
}
