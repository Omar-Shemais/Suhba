import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islamic_app/core/utils/service_locator.dart';
import '../../data/repositories/hadith_repository.dart';
import '../cubit/search_cubit.dart';
import '../widgets/hadith_search_view_body.dart';

class HadithSearchScreen extends StatelessWidget {
  const HadithSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          create: (_) => SearchCubit(getIt<HadithRepository>()),
          child: const HadithSearchViewBody(),
        ),
      ),
    );
  }
}
