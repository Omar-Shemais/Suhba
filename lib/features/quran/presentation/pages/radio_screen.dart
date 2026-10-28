import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islamic_app/core/utils/service_locator.dart';
import '../cubit/audio_cubit.dart';
import '../widgets/audio_error_listener.dart';
import '../widgets/radio_view_body.dart';

class RadioScreen extends StatelessWidget {
  const RadioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocProvider.value(
      value: getIt<AudioCubit>(),
      child: AudioErrorListener(
        child: Scaffold(
          backgroundColor: isDark ? const Color(0xFF1E2125) : const Color(0xFFFAF5ED),
          body: const RadioViewBody(),
        ),
      ),
    );
  }
}
