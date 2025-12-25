import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islamic_app/core/utils/service_locator.dart';
import '../../data/repositories/quran_repo.dart';
import '../cubit/audio_cubit.dart';
import '../cubit/quran_cubit.dart';
import '../widgets/audio_error_listener.dart';
import '../widgets/surah_detail_view_body.dart';
import '../widgets/audio_button.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahId;

  const SurahDetailScreen({super.key, required this.surahId});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  @override
  void dispose() {
    // 🟢 IMPORTANT: Do NOT call _audioCubit.stop() here.
    // This allows the audio to continue playing when you go back.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              QuranCubit(getIt<QuranRepository>())
                ..loadSurahById(widget.surahId),
        ),
        BlocProvider.value(value: getIt<AudioCubit>()),
      ],
      child: AudioErrorListener(
        child: Scaffold(
          body: SurahDetailViewBody(surahId: widget.surahId),
          floatingActionButton: AudioButton(surahId: widget.surahId),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }
}
