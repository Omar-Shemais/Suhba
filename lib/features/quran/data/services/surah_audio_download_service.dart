import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../repositories/audio_repo.dart';

enum SurahDownloadState {
  notDownloaded,
  downloading,
  downloaded,
  error,
}

class SurahAudioDownloadService {
  static final SurahAudioDownloadService _instance =
      SurahAudioDownloadService._internal();
  factory SurahAudioDownloadService() => _instance;
  SurahAudioDownloadService._internal() {
    refreshDownloadedSurahs();
  }

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(minutes: 5),
    ),
  );

  final AudioRepository _audioRepository = AudioRepositoryImpl();
  final Map<String, CancelToken> _cancelTokens = {};

  final Set<int> _downloadedSurahIds = {};
  Set<int> get downloadedSurahIds => Set.unmodifiable(_downloadedSurahIds);

  /// Synchronous check if a surah is downloaded on disk
  bool isSurahLocallyDownloaded(int surahId) =>
      _downloadedSurahIds.contains(surahId);

  /// Progress per key "$reciterId-$surahId" (0.0 to 1.0)
  final ValueNotifier<Map<String, double>> progressNotifier =
      ValueNotifier<Map<String, double>>({});

  /// Notifier triggered when a file is downloaded or deleted
  final ValueNotifier<int> statusNotifier = ValueNotifier<int>(0);

  String _getKey(int reciterId, int surahId) => '$reciterId-$surahId';

  Future<String> _getStorageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDir.path}/surahs_audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir.path;
  }

  Future<void> refreshDownloadedSurahs() async {
    try {
      final dirPath = await _getStorageDirectory();
      final dir = Directory(dirPath);
      final Set<int> ids = {};
      if (await dir.exists()) {
        final files = dir.listSync();
        final regex = RegExp(r'reciter_\d+_surah_(\d+)\.mp3$');
        for (final f in files) {
          if (f is File) {
            final match = regex.firstMatch(f.path);
            if (match != null) {
              try {
                if (f.lengthSync() > 10240) {
                  ids.add(int.parse(match.group(1)!));
                }
              } catch (_) {}
            }
          }
        }
      }
      _downloadedSurahIds
        ..clear()
        ..addAll(ids);
      statusNotifier.value++;
    } catch (_) {}
  }

  Future<String> getLocalFilePath(int reciterId, int surahId) async {
    final dir = await _getStorageDirectory();
    return '$dir/reciter_${reciterId}_surah_$surahId.mp3';
  }

  Future<bool> isSurahDownloaded(int reciterId, int surahId) async {
    try {
      final path = await getLocalFilePath(reciterId, surahId);
      final file = File(path);
      if (await file.exists()) {
        final length = await file.length();
        return length > 10240; // أكبر من 10 كيلوبايت للتأكد من سلامة الملف
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  bool isDownloading(int reciterId, int surahId) {
    final key = _getKey(reciterId, surahId);
    return progressNotifier.value.containsKey(key);
  }

  double getProgress(int reciterId, int surahId) {
    final key = _getKey(reciterId, surahId);
    return progressNotifier.value[key] ?? 0.0;
  }

  Future<int?> getFileSize(int reciterId, int surahId) async {
    try {
      final path = await getLocalFilePath(reciterId, surahId);
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> downloadSurah({
    required int reciterId,
    required int surahId,
    Function(double progress, int received, int total)? onProgress,
  }) async {
    final key = _getKey(reciterId, surahId);
    if (_cancelTokens.containsKey(key)) {
      debugPrint('⚠️ السورة قيد التحميل بالفعل');
      return;
    }

    final cancelToken = CancelToken();
    _cancelTokens[key] = cancelToken;

    // Update progress state
    final currentMap = Map<String, double>.from(progressNotifier.value);
    currentMap[key] = 0.0;
    progressNotifier.value = currentMap;

    try {
      // 1. رابط الصوت الصادر من السيرفر
      final audioUrl = await _audioRepository.getAudioUrl(reciterId, surahId);
      final targetPath = await getLocalFilePath(reciterId, surahId);
      final tempPath = '$targetPath.tmp';

      debugPrint('📥 بدء تحميل السورة $surahId للقارئ $reciterId من $audioUrl');

      await _dio.download(
        audioUrl,
        tempPath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = (received / total).clamp(0.0, 1.0);
            final updated = Map<String, double>.from(progressNotifier.value);
            updated[key] = progress;
            progressNotifier.value = updated;
            onProgress?.call(progress, received, total);
          }
        },
      );

      // تم التحميل بنجاح، نقل الملف من المؤقت إلى النهائي
      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        final targetFile = File(targetPath);
        if (await targetFile.exists()) {
          await targetFile.delete();
        }
        await tempFile.rename(targetPath);
        _downloadedSurahIds.add(surahId);
      }

      debugPrint('✅ اكتمل تحميل السورة $surahId بنجاح إلى: $targetPath');
    } catch (e) {
      debugPrint('❌ فشل تحميل السورة: $e');
      // تنظيف الملف المؤقت إن وجد
      try {
        final targetPath = await getLocalFilePath(reciterId, surahId);
        final tempFile = File('$targetPath.tmp');
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {}
      rethrow;
    } finally {
      _cancelTokens.remove(key);
      final updated = Map<String, double>.from(progressNotifier.value);
      updated.remove(key);
      progressNotifier.value = updated;
      statusNotifier.value++;
    }
  }

  void cancelDownload(int reciterId, int surahId) {
    final key = _getKey(reciterId, surahId);
    if (_cancelTokens.containsKey(key)) {
      _cancelTokens[key]?.cancel('تم إلغاء التحميل من قبل المستخدم');
      _cancelTokens.remove(key);

      final updated = Map<String, double>.from(progressNotifier.value);
      updated.remove(key);
      progressNotifier.value = updated;
      statusNotifier.value++;
    }
  }

  Future<void> deleteSurahAudio(int reciterId, int surahId) async {
    try {
      final path = await getLocalFilePath(reciterId, surahId);
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ تم حذف السورة $surahId بنجاح');
      }
    } catch (e) {
      debugPrint('❌ خطأ في حذف السورة: $e');
    } finally {
      await refreshDownloadedSurahs();
    }
  }
}
