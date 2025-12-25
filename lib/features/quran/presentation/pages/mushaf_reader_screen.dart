import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islamic_app/core/utils/service_locator.dart';
import '../../data/repositories/mushaf_repo.dart';
import '../cubit/mushaf_cubit.dart';
import '../widgets/mushaf_view_body.dart';

class MushafReaderScreen extends StatelessWidget {
  const MushafReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MushafCubit(getIt<MushafRepository>())..loadMushaf(),
      child: const Scaffold(body: SafeArea(child: MushafViewBody())),
    );
  }
}
