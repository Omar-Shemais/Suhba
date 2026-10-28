import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:islamic_app/features/quran/presentation/cubit/audio_cubit.dart';

void main() {
  test('AudioCubit Alafasy URL matches requested format', () {
    expect(
      '${AudioCubit.alafasySurahBaseUrl}/1.mp3',
      'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/1.mp3',
    );
    expect(
      '${AudioCubit.alafasySurahBaseUrl}/2.mp3',
      'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/2.mp3',
    );
  });

  test('ConcatenatingAudioSource can be constructed with Alafasy surah URLs', () {
    final surahIds = [1, 2];
    final playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: surahIds.map((id) =>
        AudioSource.uri(
          Uri.parse('${AudioCubit.alafasySurahBaseUrl}/$id.mp3'),
          tag: id,
        ),
      ).toList(),
    );

    expect(playlist.length, 2);
    expect(playlist.children.length, 2);
    final first = playlist.children[0] as UriAudioSource;
    final second = playlist.children[1] as UriAudioSource;
    expect(first.tag, 1);
    expect(first.uri.toString(), 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/1.mp3');
    expect(second.tag, 2);
    expect(second.uri.toString(), 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/2.mp3');
  });
}



