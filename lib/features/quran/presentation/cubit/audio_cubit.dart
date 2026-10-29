import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islamic_app/core/services/native_radio_service.dart';
import '../../data/repositories/audio_repo.dart';
import '../../data/helpers/reciter_storage_manager.dart';
import '../../data/models/quran_models.dart';
import '../../data/services/surah_audio_download_service.dart';
import '../cubit/audio_state.dart';
import 'package:just_audio/just_audio.dart';

enum AudioPlaybackType {
  none,
  ayah,
  surah,
  section,
  radio,
}

class AudioCubit extends Cubit<AudioState> {
  final AudioRepository audioRepository;

  // 1. Local Player (For Ayahs only - Fast, In-app)
  final AudioPlayer _localPlayer = AudioPlayer();

  // 2. Native Service (For Surah & Radio - Background Notification)
  final NativeRadioService _nativeService = NativeRadioService();

  AudioPlaybackType _playbackType = AudioPlaybackType.none;
  AudioPlaybackType get playbackType => _playbackType;

  int? _currentSurahId;
  int? _currentReciterId;
  int? _currentAyahNumber;
  int? _currentSurahTotalVerses;

  static const List<int> _surahVerseCounts = [
    7, 286, 200, 176, 120, 165, 206, 75, 129, 109,
    123, 111, 43, 52, 99, 128, 111, 110, 98, 135,
    112, 78, 118, 64, 77, 227, 93, 88, 69, 60,
    34, 30, 73, 54, 45, 83, 182, 88, 75, 85,
    54, 53, 89, 59, 37, 35, 38, 29, 18, 45,
    60, 49, 62, 55, 78, 96, 29, 22, 24, 13,
    14, 11, 11, 18, 12, 12, 30, 52, 52, 44,
    28, 28, 20, 56, 40, 31, 50, 40, 46, 42,
    29, 19, 36, 25, 22, 17, 19, 26, 30, 20,
    15, 21, 11, 8, 8, 19, 5, 8, 8, 11,
    11, 8, 3, 9, 5, 4, 7, 3, 6, 3,
    5, 4, 5, 6
  ];

  static int getTotalVersesForSurah(int surahId) {
    if (surahId >= 1 && surahId <= _surahVerseCounts.length) {
      return _surahVerseCounts[surahId - 1];
    }
    return 286;
  }

  // 3. Verse Queue (For continuous playback of Juz / Hizb)
  List<VerseModel>? _activeQueue;
  int _currentQueueIndex = 0;
  String? _activeQueueTitle;

  // 4. Section Surah Queue (For continuous recitation using full surahs via Alafasy)
  static const String alafasySurahBaseUrl =
      'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy';
  List<int>? _activeSurahQueue;
  int _currentSurahQueueIndex = 0;
  String? _sectionRangeDescription;

  // StreamSubscriptions (For Local Player only)
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _currentIndexSubscription;
  bool _isHandlingCompletion = false;

  DateTime? _lastPositionEmit;
  static const _positionUpdateInterval = Duration(milliseconds: 500);

  AudioCubit(this.audioRepository) : super(AudioInitial()) {
    _initializeLocalPlayer();
    _loadSavedReciter();
    _setupControlCenterListener();
  }

  Future<void> _loadSavedReciter() async {
    _currentReciterId = await ReciterStorageManager.getSelectedReciterId();
  }

  /// 🎛️ Listen to Control Center / Notification Drawer Actions
  void _setupControlCenterListener() {
    _nativeService.onControlCenterAction = (action) {
      print('📱 [AudioCubit] Control Center Action: $action');

      switch (action) {
        case 'play':
          // User pressed play in notification drawer or control center
          if (_playbackType == AudioPlaybackType.surah ||
              _playbackType == AudioPlaybackType.radio) {
            if (state is AudioPaused) {
              final current = state as AudioPaused;
              if (!isClosed) {
                emit(AudioPlaying(
                  currentPosition: current.currentPosition,
                  totalDuration: current.totalDuration,
                  currentSurahId: _currentSurahId,
                ));
              }
            }
          }
          break;
        case 'pause':
          // User pressed pause in notification drawer or control center
          if (_playbackType == AudioPlaybackType.surah ||
              _playbackType == AudioPlaybackType.radio) {
            if (state is AudioPlaying) {
              final current = state as AudioPlaying;
              if (!isClosed) {
                emit(AudioPaused(
                  currentPosition: current.currentPosition,
                  totalDuration: current.totalDuration,
                  currentSurahId: _currentSurahId,
                  currentAyahNumber: null,
                ));
              }
            }
          }
          break;
        case 'stop':
          // Native service stopped playback (e.g. from notification Stop button)
          // Only react to native service stop if we are actually in a native playback mode!
          if (_playbackType == AudioPlaybackType.surah ||
              _playbackType == AudioPlaybackType.radio) {
            _localPlayer.stop().catchError((_) {});
            _resetCurrentPlayback();
            if (!isClosed) emit(AudioInitial());
          }
          break;
      }
    };
  }

  void _initializeLocalPlayer() {
    // 🎧 Listen to currentIndex for ConcatenatingAudioSource (e.g. Al-Fatihah -> Al-Baqarah)
    _currentIndexSubscription = _localPlayer.currentIndexStream.listen((index) {
      if (isClosed || index == null) return;
      if (_activeSurahQueue != null &&
          index >= 0 &&
          index < _activeSurahQueue!.length) {
        _currentSurahQueueIndex = index;
        _currentSurahId = _activeSurahQueue![index];
        _currentAyahNumber = null;
        if (!isClosed && (state is AudioPlaying || state is AudioPaused)) {
          emit(
            AudioPlaying(
              currentPosition: _localPlayer.position,
              totalDuration: _localPlayer.duration ?? Duration.zero,
              currentSurahId: _currentSurahId,
            ),
          );
        }
      }
    });

    _playerStateSubscription = _localPlayer.playerStateStream.listen((
      playerState,
    ) {
      if (playerState.processingState == ProcessingState.completed) {
        if (_isHandlingCompletion) return;

        if (_activeSurahQueue != null) {
          // When using ConcatenatingAudioSource, ProcessingState.completed
          // is reached only when the entire playlist has finished.
          _isHandlingCompletion = true;
          if (!isClosed) {
            emit(
              AudioCompleted(
                currentSurahId: _currentSurahId,
                currentAyahNumber: null,
              ),
            );
          }
          _resetCurrentPlayback();
          return;
        } else if (_activeQueue != null &&
            _currentQueueIndex + 1 < _activeQueue!.length) {
          _isHandlingCompletion = true;
          _currentQueueIndex++;
          _playCurrentQueueItem().then((_) {
            _isHandlingCompletion = false;
          }).catchError((_) {
            _isHandlingCompletion = false;
          });
          return;
        } else if (_currentSurahId != null && _currentAyahNumber != null) {
          _isHandlingCompletion = true;
          final completedAyah = _currentAyahNumber!;
          final maxVerses = _currentSurahTotalVerses ??
              getTotalVersesForSurah(_currentSurahId!);

          // Stop local player cleanly
          _localPlayer.stop().catchError((_) {});

          if (completedAyah < maxVerses) {
            // Ayah completed. Keep _currentAyahNumber as completedAyah.
            // When resume() is tapped, it plays completedAyah + 1.
            if (!isClosed) {
              emit(
                AudioCompleted(
                  currentSurahId: _currentSurahId,
                  currentAyahNumber: completedAyah,
                ),
              );
            }
          } else {
            // Surah finished (reached end of verses)
            _currentAyahNumber = null;
            if (!isClosed) {
              emit(
                AudioCompleted(
                  currentSurahId: _currentSurahId,
                  currentAyahNumber: completedAyah,
                ),
              );
            }
            _resetCurrentPlayback();
          }
          return;
        }

        if (!isClosed) {
          emit(
            AudioCompleted(
              currentSurahId: _currentSurahId,
              currentAyahNumber: _currentAyahNumber,
            ),
          );
        }
        _resetCurrentPlayback();
      } else if (playerState.processingState != ProcessingState.completed) {
        _isHandlingCompletion = false;
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
          } else if (state is AudioPlaying) {
            final currentState = state as AudioPlaying;
            emit(
              AudioPlaying(
                currentPosition: position,
                totalDuration: _localPlayer.duration ?? currentState.totalDuration,
                currentSurahId: _currentSurahId,
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
      } else if (state is AudioPlaying) {
        emit(
          AudioPlaying(
            currentPosition: _localPlayer.position,
            totalDuration: duration,
            currentSurahId: _currentSurahId,
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
  // 🟢 PLAY SURAH (Uses Native Service)
  // ===========================================================================
  Future<void> playSurah(
    int surahId, {
    int? reciterId,
    String? title,
    String? desc,
  }) async {
    try {
      // 1. STOP Local Player (In case an Ayah was playing)
      await _localPlayer.stop();

      // 2. Setup state
      _playbackType = AudioPlaybackType.surah;
      if (reciterId == null) {
        _currentReciterId = await ReciterStorageManager.getSelectedReciterId();
      } else {
        _currentReciterId = reciterId;
      }
      _currentSurahId = surahId;
      _currentAyahNumber = null; // Important: Null means it's a Surah
      _currentSurahTotalVerses = getTotalVersesForSurah(surahId);
      _activeSurahQueue = null;
      _activeQueue = null;
      _activeQueueTitle = null;
      _sectionRangeDescription = null;

      // 3. التحقق إذا كانت السورة محملة مسبقاً للعمل بدون إنترنت
      final downloadService = SurahAudioDownloadService();
      final isDownloaded = await downloadService.isSurahDownloaded(
        _currentReciterId!,
        surahId,
      );

      String audioUrl;
      if (isDownloaded) {
        audioUrl = await downloadService.getLocalFilePath(
          _currentReciterId!,
          surahId,
        );
        debugPrint('🎧 تشغيل السورة $surahId بدون إنترنت من الملف المحلي: $audioUrl');
      } else {
        final hasInternet = await _checkInternetConnection();
        if (!hasInternet) {
          if (!isClosed) {
            emit(
              AudioError(
                message:
                    'لا يوجد اتصال بالإنترنت. يمكنك تحميل صوت السورة مسبقاً للاستماع بدون نت.',
                targetSurahId: surahId,
              ),
            );
          }
          return;
        }

        audioUrl = await audioRepository.getAudioUrl(
          _currentReciterId!,
          surahId,
        );
      }

      final reciter = await audioRepository.getReciterById(_currentReciterId!);
      final displayTitle = title ?? "سورة $surahId";
      final displayDesc = desc ?? reciter.arabicName;

      // 4. ▶️ CALL NATIVE SERVICE (Triggers foreground notification)
      await _nativeService.play(
        url: audioUrl,
        title: displayTitle,
        desc: displayDesc,
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
  Future<void> playAyah(
    int surahId,
    int ayahNumber, {
    int? reciterId,
    List<VerseModel>? surahVerses,
    int? totalVerses,
  }) async {
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

      // If surahVerses is provided, set up continuous playback queue
      if (surahVerses != null && surahVerses.isNotEmpty) {
        _activeQueue = surahVerses;
        _currentQueueIndex = surahVerses.indexWhere((v) => v.id == ayahNumber);
        if (_currentQueueIndex < 0) _currentQueueIndex = 0;
      }

      // Stop Native Service if Surah or Radio was playing
      if (_playbackType == AudioPlaybackType.surah ||
          _playbackType == AudioPlaybackType.radio) {
        try {
          await _nativeService.stop();
        } catch (_) {}
      }

      await _localPlayer.stop();
      _isHandlingCompletion = false;

      _playbackType = AudioPlaybackType.ayah;
      _currentSurahId = surahId;
      _currentAyahNumber = ayahNumber;
      _currentSurahTotalVerses =
          totalVerses ?? _currentSurahTotalVerses ?? getTotalVersesForSurah(surahId);
      _activeSurahQueue = null;
      _sectionRangeDescription = null;

      if (reciterId == null) {
        _currentReciterId = await ReciterStorageManager.getSelectedReciterId();
      } else {
        _currentReciterId = reciterId;
      }

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
  // 🟢 PLAY VERSE QUEUE (For continuous Juz & Hizb playback)
  // ===========================================================================
  Future<void> playVerseQueue(
    List<VerseModel> verses, {
    int startIndex = 0,
    String? title,
    int? reciterId,
  }) async {
    if (verses.isEmpty) return;

    _activeQueue = verses;
    _currentQueueIndex = startIndex.clamp(0, verses.length - 1);
    _activeQueueTitle = title;

    await _playCurrentQueueItem(reciterId: reciterId);
  }

  Future<void> _playCurrentQueueItem({int? reciterId}) async {
    if (_activeQueue == null || _currentQueueIndex >= _activeQueue!.length) {
      _resetCurrentPlayback();
      return;
    }

    final verse = _activeQueue![_currentQueueIndex];
    final surahId = verse.surahId ?? 1;
    final ayahNumber = verse.id;

    await playAyah(surahId, ayahNumber, reciterId: reciterId);
  }

  bool isSectionPlaying(String title) {
    return _activeQueueTitle == title && isPlaying;
  }

  bool isSectionPaused(String title) {
    return _activeQueueTitle == title && isPaused;
  }

  // ===========================================================================
  // 🟢 PLAY SECTION SURAH AUDIO (Alafasy continuous surahs for Khatmah / Juz)
  // ===========================================================================
  Future<void> playSectionSurahAudio({
    required List<int> surahIds,
    required String title,
    String? rangeDescription,
    int? firstAyah,
    int? lastAyah,
    int? reciterId,
  }) async {
    if (surahIds.isEmpty) return;

    final hasInternet = await _checkInternetConnection();
    if (!hasInternet) {
      if (!isClosed) emit(AudioError(message: "no_internet".tr()));
      return;
    }

    // Stop any existing playback
    await _localPlayer.stop();
    if (_playbackType == AudioPlaybackType.surah ||
        _playbackType == AudioPlaybackType.radio) {
      try {
        await _nativeService.stop();
      } catch (_) {}
    }

    _playbackType = AudioPlaybackType.section;
    _activeSurahQueue = List<int>.from(surahIds);
    _currentSurahQueueIndex = 0;
    _activeQueueTitle = title;
    _sectionRangeDescription = rangeDescription;
    _activeQueue = null;
    _currentAyahNumber = null;
    _currentSurahId = surahIds.first;
    _currentSurahTotalVerses = getTotalVersesForSurah(_currentSurahId!);
    _isHandlingCompletion = false;

    if (reciterId == null) {
      _currentReciterId = await ReciterStorageManager.getSelectedReciterId();
    } else {
      _currentReciterId = reciterId;
    }

    try {
      final reciter = await audioRepository.getReciterById(_currentReciterId!);

      final playlist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: surahIds.map((sId) {
          final surahUrl = reciter.getAudioUrl(sId);
          return AudioSource.uri(
            Uri.parse(surahUrl),
            tag: sId,
          );
        }).toList(),
      );

      await _localPlayer.setAudioSource(
        playlist,
        initialIndex: 0,
        initialPosition: Duration.zero,
      );

      if (!isClosed) {
        emit(
          AudioPlaying(
            currentPosition: Duration.zero,
            totalDuration: _localPlayer.duration ?? Duration.zero,
            currentSurahId: _currentSurahId,
          ),
        );
      }

      await _localPlayer.play();
    } catch (e) {
      if (!isClosed) {
        emit(
          AudioError(
            message: 'فشل تشغيل الصوت: ${e.toString()}',
            targetSurahId: _currentSurahId,
          ),
        );
      }
      _resetCurrentPlayback();
    }
  }

  Future<void> nextSectionSurah() async {
    if (_activeSurahQueue != null && _localPlayer.hasNext) {
      await _localPlayer.seekToNext();
    }
  }

  Future<void> previousSectionSurah() async {
    if (_activeSurahQueue != null && _localPlayer.hasPrevious) {
      await _localPlayer.seekToPrevious();
    }
  }


  // ===========================================================================
  // 🟢 ROBUST PAUSE (Isolates Local Player vs Native Service)
  // ===========================================================================
  Future<void> pause() async {
    print("🔻 AudioCubit: Pause Called - Type: $_playbackType, State: ${state.runtimeType}");

    if (_playbackType == AudioPlaybackType.ayah ||
        _playbackType == AudioPlaybackType.section) {
      // AYAH or SECTION: ONLY pause local player.
      // NEVER touch _nativeService!
      if (_localPlayer.playing) {
        await _localPlayer.pause();
      }
    } else if (_playbackType == AudioPlaybackType.surah ||
        _playbackType == AudioPlaybackType.radio) {
      // SURAH or RADIO: ONLY pause native service.
      await _nativeService.pause();
    } else {
      if (_localPlayer.playing) {
        await _localPlayer.pause();
      }
    }

    if (!isClosed) {
      if (state is AudioPlayingAyah) {
        final current = state as AudioPlayingAyah;
        emit(
          AudioPaused(
            currentPosition: _localPlayer.position,
            totalDuration: current.totalDuration,
            currentSurahId: _currentSurahId,
            currentAyahNumber: _currentAyahNumber,
          ),
        );
      } else if (state is AudioPlaying) {
        final current = state as AudioPlaying;
        emit(
          AudioPaused(
            currentPosition: current.currentPosition,
            totalDuration: current.totalDuration,
            currentSurahId: _currentSurahId,
            currentAyahNumber: null,
          ),
        );
      } else if (state is AudioPlayingRadio) {
        emit(
          AudioPaused(
            currentPosition: Duration.zero,
            totalDuration: Duration.zero,
            currentSurahId: null,
            currentAyahNumber: null,
          ),
        );
      }
    }
  }

  // ===========================================================================
  // 🟢 RESUME (Handles Ayah Progression & Prevents Echo)
  // ===========================================================================
  Future<void> resume() async {
    print(
      "▶️ AudioCubit: Resume Called - Type: $_playbackType, State: ${state.runtimeType}, Ayah: $_currentAyahNumber",
    );

    if (_playbackType == AudioPlaybackType.ayah ||
        (_currentSurahId != null && _currentAyahNumber != null)) {
      // Case 1: Audio was paused mid-verse -> continue this SAME verse
      if (state is AudioPaused) {
        final paused = state as AudioPaused;
        final savedDuration = paused.totalDuration;
        await _localPlayer.play();
        if (!isClosed && (state is AudioPaused || state is AudioPlayingAyah)) {
          emit(
            AudioPlayingAyah(
              currentPosition: _localPlayer.position,
              totalDuration: _localPlayer.duration ?? savedDuration,
              currentSurahId: _currentSurahId,
              currentAyahNumber: _currentAyahNumber,
            ),
          );
        }
        return;
      }

      // Case 2: Audio completed -> play the NEXT ayah (+1 only!)
      if (state is AudioCompleted) {
        final completedAyah = _currentAyahNumber ?? 1;
        final maxVerses = _currentSurahTotalVerses ??
            getTotalVersesForSurah(_currentSurahId!);
        final nextAyah = completedAyah + 1;

        if (nextAyah <= maxVerses) {
          await playAyah(
            _currentSurahId!,
            nextAyah,
            reciterId: _currentReciterId,
            totalVerses: _currentSurahTotalVerses,
          );
        } else {
          // Reached end of surah
          await stop();
        }
        return;
      }

      // Case 3: Any other state with current ayah -> play current ayah
      await playAyah(
        _currentSurahId!,
        _currentAyahNumber!,
        reciterId: _currentReciterId,
        totalVerses: _currentSurahTotalVerses,
      );
      return;
    } else if (_playbackType == AudioPlaybackType.section) {
      if (state is AudioPaused) {
        final paused = state as AudioPaused;
        await _localPlayer.play();
        if (!isClosed) {
          emit(
            AudioPlaying(
              currentPosition: _localPlayer.position,
              totalDuration: paused.totalDuration,
              currentSurahId: _currentSurahId,
            ),
          );
        }
      } else {
        await _localPlayer.play();
      }
    } else if (_playbackType == AudioPlaybackType.surah ||
        _playbackType == AudioPlaybackType.radio) {
      // Surah or radio: Resume native service ONLY. Never touch _localPlayer!
      try {
        await _nativeService.resume();
      } catch (_) {}
      if (!isClosed && state is AudioPaused) {
        final current = state as AudioPaused;
        emit(
          AudioPlaying(
            currentPosition: current.currentPosition,
            totalDuration: current.totalDuration,
            currentSurahId: _currentSurahId,
          ),
        );
      }
    } else {
      // Fallback
      if (_currentAyahNumber != null && _currentSurahId != null) {
        await playAyah(
          _currentSurahId!,
          _currentAyahNumber!,
          reciterId: _currentReciterId,
          totalVerses: _currentSurahTotalVerses,
        );
      } else {
        try {
          await _nativeService.resume();
        } catch (_) {}
      }
    }
  }

  // ===========================================================================
  // 🟢 STOP (Stops Everything)
  // ===========================================================================
  Future<void> stop() async {
    try {
      await _localPlayer.stop(); // Stop Local
    } catch (_) {}
    try {
      await _nativeService.stop(); // Stop Native Background Service
    } catch (_) {}

    _resetCurrentPlayback();
    if (!isClosed) emit(AudioInitial());
  }

  Future<void> seek(Duration position) async {
    try {
      await _localPlayer.seek(position);
    } catch (_) {}
  }

  Future<void> setVolume(double volume) async {
    await _localPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  // ===========================================================================
  // 🟢 PLAY RADIO (Plays stream via native background service with local fallback)
  // ===========================================================================
  Future<void> playRadio(String url, {String stationName = "Radio"}) async {
    try {
      await _localPlayer.stop();
      try {
        await _nativeService.stop();
      } catch (_) {}

      _playbackType = AudioPlaybackType.radio;
      _currentSurahId = null;
      _currentAyahNumber = null;
      _currentSurahTotalVerses = null;
      _activeSurahQueue = null;
      _activeQueue = null;
      _activeQueueTitle = null;
      _sectionRangeDescription = null;

      // Play via native background service (ExoPlayer foreground on Android, AVPlayer on iOS)
      bool playedNatively = false;
      try {
        await _nativeService.play(
          url: url,
          title: stationName,
          desc: "بث مباشر",
        );
        playedNatively = true;
      } catch (_) {
        // Native radio service unavailable on this platform
      }

      // Fallback to local player if native service was unavailable
      if (!playedNatively) {
        await _localPlayer.setUrl(url);
        await _localPlayer.play();
      }

      if (!isClosed) emit(AudioPlayingRadio(url: url));
    } catch (e) {
      if (!isClosed) {
        emit(AudioError(message: 'خطأ في تشغيل الإذاعة: $e', targetRadioUrl: url));
      }
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

      if (_currentSurahId != null && isPlaying) {
        if (_currentAyahNumber != null) {
          // Replay Ayah (Local)
          await playAyah(
            _currentSurahId!,
            _currentAyahNumber!,
            reciterId: reciterId,
            totalVerses: _currentSurahTotalVerses,
          );
        } else if (_activeSurahQueue != null) {
          await playSectionSurahAudio(
            surahIds: _activeSurahQueue!,
            title: _activeQueueTitle ?? '',
            rangeDescription: _sectionRangeDescription,
            reciterId: reciterId,
          );
        } else {
          // Replay Surah (Native)
          await playSurah(_currentSurahId!, reciterId: reciterId);
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(AudioError(message: 'Failed to change reciter: ${e.toString()}'));
      }
    }
  }

  Future<int> getCurrentReciterId() async {
    return _currentReciterId ??
        await ReciterStorageManager.getSelectedReciterId();
  }

  void _resetCurrentPlayback() {
    _playbackType = AudioPlaybackType.none;
    _currentSurahId = null;
    _currentAyahNumber = null;
    _currentSurahTotalVerses = null;
    _lastPositionEmit = null;
    _activeQueue = null;
    _activeQueueTitle = null;
    _activeSurahQueue = null;
    _currentSurahQueueIndex = 0;
    _sectionRangeDescription = null;
    _isHandlingCompletion = false;
  }

  bool get isPlaying =>
      state is AudioPlaying ||
      state is AudioPlayingAyah ||
      state is AudioPlayingRadio;
  bool get isPaused => state is AudioPaused;
  int? get currentSurahId => _currentSurahId;
  int? get currentAyahNumber => _currentAyahNumber;
  List<VerseModel>? get activeQueue => _activeQueue;
  int get currentQueueIndex => _currentQueueIndex;
  String? get activeQueueTitle => _activeQueueTitle;
  List<int>? get activeSurahQueue => _activeSurahQueue;
  int get currentSurahQueueIndex => _currentSurahQueueIndex;
  String? get sectionRangeDescription => _sectionRangeDescription;

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _currentIndexSubscription?.cancel();
    _localPlayer.dispose();
    _nativeService.stop();
    return super.close();
  }
}

