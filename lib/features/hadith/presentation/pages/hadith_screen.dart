import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islamic_app/core/utils/service_locator.dart';
import '../../data/repositories/hadith_repository.dart';
import '../cubit/hadith_cubit.dart';
import '../widgets/hadiths_view_body.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          create: (_) => HadithCubit(getIt<HadithRepository>())..loadHadiths(),
          child: const HadithsViewBody(),
        ),
      ),
    );
  }
}
