import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islamic_app/core/services/native_radio_service.dart';
import '../../data/repositories/audio_repo.dart';
import '../../data/helpers/reciter_storage_manager.dart';
import '../cubit/audio_state.dart';
import 'package:just_audio/just_audio.dart';

class AudioCubit extends Cubit<AudioState> {
  final AudioRepository audioRepository;

  // 1. Local Player (For Ayahs only - Fast, In-app)
  final AudioPlayer _localPlayer = AudioPlayer();

  // 2. Native Service (For Surah & Radio - Background Notification)
  final NativeRadioService _nativeService = NativeRadioService();

  int? _currentSurahId;
  int? _currentReciterId;
  int? _currentAyahNumber;

  // StreamSubscriptions (For Local Player only)
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

  DateTime? _lastPositionEmit;
  static const _positionUpdateInterval = Duration(milliseconds: 500);

  AudioCubit(this.audioRepository) : super(AudioInitial()) {
    _initializeLocalPlayer();
    _loadSavedReciter();
  }

  Future<void> _loadSavedReciter() async {
    _currentReciterId = await ReciterStorageManager.getSelectedReciterId();
  }

  void _initializeLocalPlayer() {
    _playerStateSubscription = _localPlayer.playerStateStream.listen((
      playerState,
    ) {
      if (playerState.processingState == ProcessingState.completed) {
        if (!isClosed) {
          emit(
            AudioCompleted(
              currentSurahId: _currentSurahId,
              currentAyahNumber: _currentAyahNumber,
            ),
          );
        }
        _resetCurrentPlayback();
      }
    });

    _positionSubscription = _localPlayer.positionStream
        .distinct((prev, next) => prev.inSeconds == next.inSeconds)
        .listen((position) {
          if (isClosed) return;

          final now = DateTime.now();
          if (_lastPositionEmit != null &&
              now.difference(_lastPositionEmit!) < _positionUpdateInterval) {
            return;
          }
          _lastPositionEmit = now;

          // Only emit position for Ayahs (since they use local player)
          if (state is AudioPlayingAyah) {
            final currentState = state as AudioPlayingAyah;
            emit(
              AudioPlayingAyah(
                currentPosition: position,
                totalDuration: currentState.totalDuration,
                currentSurahId: _currentSurahId,
                currentAyahNumber: _currentAyahNumber,
              ),
            );
          }
        });

    _durationSubscription = _localPlayer.durationStream.listen((duration) {
      if (isClosed || duration == null) return;
      if (state is AudioPlayingAyah) {
        emit(
          AudioPlayingAyah(
            currentPosition: _localPlayer.position,
            totalDuration: duration,
            currentSurahId: _currentSurahId,
            currentAyahNumber: _currentAyahNumber,
          ),
        );
      }
    });
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ===========================================================================
  // 🟢 PLAY SURAH (FIXED: Stops Local Player ONLY)
  // ===========================================================================
  // ===========================================================================
  // 🟢 PLAY SURAH (FIXED: Uses Native Service)
  // ===========================================================================
  Future<void> playSurah(int surahId, {int? reciterId}) async {
    try {
      final hasInternet = await _checkInternetConnection();
      if (!hasInternet) {
        if (!isClosed)
          emit(AudioError(message: "no_internet".tr(), targetSurahId: surahId));
        return;
      }

      // 1. STOP Local Player (In case an Ayah was playing)
      // Do NOT call full stop() or you kill the service!
      await _localPlayer.stop();

      // 2. Setup IDs
      if (reciterId == null) {
        _currentReciterId = await ReciterStorageManager.getSelectedReciterId();
      } else {
        _currentReciterId = reciterId;
      }
      _currentSurahId = surahId;
      _currentAyahNumber = null; // Important: Null means it's a Surah

      // 3. Get Audio URL
      final audioUrl = await audioRepository.getAudioUrl(
        _currentReciterId!,
        surahId,
      );

      // 4. ▶️ CALL NATIVE SERVICE (This is what triggers the Notification & Pause capability)
      await _nativeService.play(
        url: audioUrl,
        title: "Surah $surahId",
        desc: "Reciter $_currentReciterId",
      );

      // 5. Update Flutter UI State
      if (!isClosed) {
        emit(
          AudioPlaying(
            currentPosition: Duration.zero,
            totalDuration: Duration.zero,
            currentSurahId: surahId,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          AudioError(
            message: 'Failed to play Surah: ${e.toString()}',
            targetSurahId: surahId,
          ),
        );
      }
      _resetCurrentPlayback();
    }
  }

  // ===========================================================================
  // PLAY AYAH (Uses Local Player)
  // ===========================================================================
  Future<void> playAyah(int surahId, int ayahNumber, {int? reciterId}) async {
    try {
      final hasInternet = await _checkInternetConnection();
      if (!hasInternet) {
        if (!isClosed) {
          emit(
            AudioError(
              message: "no_internet".tr(),
              targetSurahId: surahId,
              targetAyahNumber: ayahNumber,
            ),
          );
        }
        return;
      }

      // 🛑 For Ayah: We MUST stop Native Service (if Radio was playing)
      await _nativeService.stop();
      await _localPlayer.stop();

      if (reciterId == null) {
        _currentReciterId = await ReciterStorageManager.getSelectedReciterId();
      } else {
        _currentReciterId = reciterId;
      }

      _currentSurahId = surahId;
      _currentAyahNumber = ayahNumber;

      final audioUrl = await audioRepository.getAyahAudioUrl(
        _currentReciterId!,
        surahId,
        ayahNumber,
      );

      await _localPlayer.setUrl(audioUrl);

      if (!isClosed) {
        emit(
          AudioPlayingAyah(
            currentPosition: Duration.zero,
            totalDuration: _localPlayer.duration ?? Duration.zero,
            currentSurahId: surahId,
            currentAyahNumber: ayahNumber,
          ),
        );
      }

      await _localPlayer.play();
    } catch (e) {
      if (!isClosed) {
        emit(
          AudioError(
            message: 'Failed to play Ayah: ${e.toString()}',
            targetSurahId: surahId,
            targetAyahNumber: ayahNumber,
          ),
        );
      }
      _resetCurrentPlayback();
    }
  }

  // ===========================================================================
  // 🟢 ROBUST PAUSE (Fixes "Didn't Pause" Issue)
  // ===========================================================================
  Future<void> pause() async {
    // 1. Force pause Local Player (JustAudio)
    print("🔻 AudioCubit: Pause Called"); // <--- Debug Log
    // We check if it's playing first to avoid errors
    if (_localPlayer.playing) {
      await _localPlayer.pause();
    }

    // 2. Force pause Native Service (Background Audio)
    await _nativeService.pause();

    // 3. Update UI State manually to ensure the button icon changes
    if (!isClosed) {
      // Determine current Surah/Ayah from existing variables
      if (state is AudioPlaying) {
        final current = state as AudioPlaying;
        emit(
          AudioPaused(
            currentPosition: current.currentPosition,
            totalDuration: current.totalDuration,
            currentSurahId: _currentSurahId,
          ),
        );
      } else if (state is AudioPlayingAyah) {
        final current = state as AudioPlayingAyah;
        emit(
          AudioPaused(
            currentPosition: _localPlayer.position,
            totalDuration: current.totalDuration,
            currentSurahId: _currentSurahId,
            currentAyahNumber: _currentAyahNumber,
          ),
        );
      }
    }
  }

  // ===========================================================================
  // 🟢 RESUME (Handles Both)
  // ===========================================================================
  Future<void> resume() async {
    if (_currentAyahNumber != null) {
      // Resume Local (Ayah)
      await _localPlayer.play();
    } else {
      // Resume Native (Surah/Radio)
      await _nativeService.resume();
    }

    if (!isClosed && state is AudioPaused) {
      final current = state as AudioPaused;

      if (_currentAyahNumber != null) {
        emit(
          AudioPlayingAyah(
            currentPosition: _localPlayer.position,
            totalDuration: current.totalDuration,
            currentSurahId: _currentSurahId,
            currentAyahNumber: _currentAyahNumber,
          ),
        );
      } else {
        emit(
          AudioPlaying(
            currentPosition: current.currentPosition,
            totalDuration: current.totalDuration,
            currentSurahId: _currentSurahId,
          ),
        );
      }
    }
  }

  // ===========================================================================
  // 🟢 STOP (Stops Everything)
  // ===========================================================================
  Future<void> stop() async {
    await _localPlayer.stop(); // Stop Local
    await _nativeService.stop(); // Stop Native Background Service

    _resetCurrentPlayback();
    if (!isClosed) emit(AudioInitial());
  }

  Future<void> seek(Duration position) async {
    // Only seek if using Local Player
    if (_currentAyahNumber != null) {
      await _localPlayer.seek(position);
    }
  }

  Future<void> setVolume(double volume) async {
    await _localPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  // ===========================================================================
  // 🟢 PLAY RADIO (FIXED)
  // ===========================================================================
  Future<void> playRadio(String url, {String stationName = "Radio"}) async {
    try {
      // 🛑 FIX: Stop only LOCAL player.
      await _localPlayer.stop();

      _currentSurahId = null;
      _currentAyahNumber = null;

      await _nativeService.play(
        url: url,
        title: stationName,
        desc: "Live Stream",
      );

      if (!isClosed) emit(AudioPlayingRadio(url: url));
    } catch (e) {
      if (!isClosed)
        emit(AudioError(message: 'Error: $e', targetRadioUrl: url));
    }
  }

  // Change Reciter Logic
  Future<void> changeReciter(int reciterId) async {
    try {
      final reciter = await audioRepository.getReciterById(reciterId);
      await ReciterStorageManager.saveSelectedReciter(
        reciterId: reciter.id,
        reciterName: reciter.name,
        reciterArabicName: reciter.arabicName,
      );
      _currentReciterId = reciterId;

      if (_currentSurahId != null) {
        if (_currentAyahNumber != null) {
          // Replay Ayah (Local)
          await playAyah(
            _currentSurahId!,
            _currentAyahNumber!,
            reciterId: reciterId,
          );
        } else {
          // Replay Surah (Native)
          await playSurah(_currentSurahId!, reciterId: reciterId);
        }
      }
    } catch (e) {
      if (!isClosed)
        emit(AudioError(message: 'Failed to change reciter: ${e.toString()}'));
    }
  }

  Future<int> getCurrentReciterId() async {
    return _currentReciterId ??
        await ReciterStorageManager.getSelectedReciterId();
  }

  void _resetCurrentPlayback() {
    _currentSurahId = null;
    _currentAyahNumber = null;
    _lastPositionEmit = null;
  }

  bool get isPlaying =>
      state is AudioPlaying ||
      state is AudioPlayingAyah ||
      state is AudioPlayingRadio;
  bool get isPaused => state is AudioPaused;
  int? get currentSurahId => _currentSurahId;
  int? get currentAyahNumber => _currentAyahNumber;

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _localPlayer.dispose();
    _nativeService.stop();
    return super.close();
  }
}
