import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islamic_app/core/utils/service_locator.dart';
import '../cubit/audio_cubit.dart';
import '../widgets/audio_error_listener.dart';
import '../widgets/radio_view_body.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  late AudioCubit _audioCubit;

  @override
  void initState() {
    super.initState();
    _audioCubit = getIt<AudioCubit>();
  }

  @override
  void dispose() {
    _audioCubit.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AudioCubit>(),
      child: AudioErrorListener(child: const Scaffold(body: RadioViewBody())),
    );
  }
}
