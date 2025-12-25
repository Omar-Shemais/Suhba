import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/mushaf_cubit.dart';
import '../cubit/mushaf_state.dart';
import '../widgets/mushaf_page_viewer.dart';

import '../../../../../core/widgets/custom_error_widget.dart';

class MushafViewBody extends StatelessWidget {
  const MushafViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MushafCubit, MushafState>(
      builder: (context, state) {
        return switch (state) {
          MushafLoading() => const Center(child: CircularProgressIndicator()),

          MushafError() => CustomErrorWidget(
            message: state.message,
            onRetry: () => context.read<MushafCubit>().loadMushaf(),
          ),

          MushafLoaded() => MushafPageViewer(
            pages: state.pages,
            currentPage: state.currentPage,
          ),

          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}
