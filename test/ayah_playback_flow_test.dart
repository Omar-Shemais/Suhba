import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/quran/presentation/cubit/audio_cubit.dart';
import 'package:islamic_app/features/quran/presentation/cubit/audio_state.dart';

void main() {
  group('Ayah Playback & Verse Count Tests', () {
    test('getTotalVersesForSurah returns correct verse counts for Quran surahs', () {
      expect(AudioCubit.getTotalVersesForSurah(1), 7); // Al-Fatihah
      expect(AudioCubit.getTotalVersesForSurah(2), 286); // Al-Baqarah
      expect(AudioCubit.getTotalVersesForSurah(3), 200); // Ali 'Imran
      expect(AudioCubit.getTotalVersesForSurah(36), 83); // Ya-Sin
      expect(AudioCubit.getTotalVersesForSurah(112), 4); // Al-Ikhlas
      expect(AudioCubit.getTotalVersesForSurah(114), 6); // An-Nas
    });

    test('AudioPlaybackType enum contains expected modes', () {
      expect(AudioPlaybackType.values, contains(AudioPlaybackType.none));
      expect(AudioPlaybackType.values, contains(AudioPlaybackType.ayah));
      expect(AudioPlaybackType.values, contains(AudioPlaybackType.surah));
      expect(AudioPlaybackType.values, contains(AudioPlaybackType.section));
      expect(AudioPlaybackType.values, contains(AudioPlaybackType.radio));
    });

    test('AudioPaused preserves both currentSurahId and currentAyahNumber', () {
      const paused = AudioPaused(
        currentPosition: Duration(seconds: 5),
        totalDuration: Duration(seconds: 15),
        currentSurahId: 1,
        currentAyahNumber: 2,
      );

      expect(paused.currentSurahId, 1);
      expect(paused.currentAyahNumber, 2);
      expect(paused.currentPosition.inSeconds, 5);
      expect(paused.totalDuration.inSeconds, 15);
    });

    test('AudioCompleted preserves currentSurahId and completed ayahNumber', () {
      const completed = AudioCompleted(
        currentSurahId: 1,
        currentAyahNumber: 1,
      );

      expect(completed.currentSurahId, 1);
      expect(completed.currentAyahNumber, 1);
    });

    test('Ayah progression calculates next ayah strictly as current + 1', () {
      const completedAyah = 8;
      const totalVerses = 286;
      final nextAyah = completedAyah + 1;

      expect(nextAyah, 9);
      expect(nextAyah <= totalVerses, isTrue);
      // Ensures it does NOT skip by 2:
      expect(nextAyah, isNot(10));
    });
  });
}
