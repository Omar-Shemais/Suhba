import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import '../../data/helpers/reciter_storage_manager.dart';
import '../../data/models/audio_model.dart';
import '../../data/repositories/audio_repo.dart';
import '../../data/services/surah_audio_download_service.dart';
import '../cubit/audio_cubit.dart';

class SurahDownloadBottomSheet extends StatefulWidget {
  final int surahId;
  final String surahName;

  const SurahDownloadBottomSheet({
    super.key,
    required this.surahId,
    required this.surahName,
  });

  static Future<void> show(
    BuildContext context, {
    required int surahId,
    required String surahName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SurahDownloadBottomSheet(
        surahId: surahId,
        surahName: surahName,
      ),
    );
  }

  @override
  State<SurahDownloadBottomSheet> createState() =>
      _SurahDownloadBottomSheetState();
}

class _SurahDownloadBottomSheetState extends State<SurahDownloadBottomSheet> {
  final SurahAudioDownloadService _downloadService =
      SurahAudioDownloadService();
  final AudioRepository _audioRepository = AudioRepositoryImpl();

  int _selectedReciterId = 1;
  ReciterModel? _currentReciter;
  bool _isLoading = true;
  bool _isDownloaded = false;
  int? _fileSizeBytes;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _downloadService.statusNotifier.addListener(_onStatusChanged);
  }

  @override
  void dispose() {
    _downloadService.statusNotifier.removeListener(_onStatusChanged);
    super.dispose();
  }

  void _onStatusChanged() {
    if (mounted) {
      _checkDownloadStatus();
    }
  }

  Future<void> _loadInitialData() async {
    final reciterId = await ReciterStorageManager.getSelectedReciterId();
    _selectedReciterId = reciterId;
    try {
      final reciter = await _audioRepository.getReciterById(reciterId);
      _currentReciter = reciter;
    } catch (_) {}

    await _checkDownloadStatus();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkDownloadStatus() async {
    final downloaded = await _downloadService.isSurahDownloaded(
      _selectedReciterId,
      widget.surahId,
    );
    int? size;
    if (downloaded) {
      size = await _downloadService.getFileSize(
        _selectedReciterId,
        widget.surahId,
      );
    }
    if (mounted) {
      setState(() {
        _isDownloaded = downloaded;
        _fileSizeBytes = size;
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} ك.ب';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} ميجابايت';
  }

  String _toArabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => int.tryParse(d) != null ? arabicDigits[int.parse(d)] : d)
        .join('');
  }

  Future<void> _startDownload() async {
    try {
      await _downloadService.downloadSurah(
        reciterId: _selectedReciterId,
        surahId: widget.surahId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('اكتمل تحميل ${widget.surahName} للعمل بدون نت 🌿'),
            backgroundColor: const Color(0xFF143427),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('فشل التحميل، يرجى التحقق من اتصال الإنترنت'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteDownload() async {
    await _downloadService.deleteSurahAudio(
      _selectedReciterId,
      widget.surahId,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف ملف ${widget.surahName} لتوفير المساحة'),
          backgroundColor: const Color(0xFF38291D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF282C32) : const Color(0xFFFAF5ED),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(
            color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // شريط السحب
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 16.h),

              // العنوان
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: _isDownloaded
                              ? const Color(0xFF1E382B)
                              : (isDark
                                  ? const Color(0xFF1E382B)
                                  : const Color(0xFFE8F1EC)),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isDownloaded
                              ? Icons.check_circle_rounded
                              : Icons.download_for_offline_rounded,
                          color: _isDownloaded
                              ? const Color(0xFF2E7D5E)
                              : const Color(0xFF143427),
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تحميل ${widget.surahName}',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF38291D),
                            ),
                          ),
                          Text(
                            'الاستماع بدون اتصال بالإنترنت',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: isDark
                                  ? Colors.white54
                                  : const Color(0xFF8C7A6B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white70 : const Color(0xFF38291D),
                      size: 20.sp,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const Divider(height: 24, thickness: 0.8),

              if (_isLoading)
                Padding(
                  padding: EdgeInsets.all(24.h),
                  child: const CircularProgressIndicator(
                    color: Color(0xFF143427),
                  ),
                )
              else ...[
                // معلومات القارئ الحالي
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2125)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF383E46)
                          : const Color(0xFFEADBCE),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.record_voice_over_rounded,
                        color: AppColors.goldenPrimary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'القارئ المختار:',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                            ),
                            Text(
                              _currentReciter?.arabicName ?? 'مشاري راشد العفاسي',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF143427),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // حالة التنزيل والتقدم
                ValueListenableBuilder<Map<String, double>>(
                  valueListenable: _downloadService.progressNotifier,
                  builder: (context, progressMap, _) {
                    final key = '$_selectedReciterId-${widget.surahId}';
                    final isCurrentlyDownloading =
                        progressMap.containsKey(key);
                    final progress = progressMap[key] ?? 0.0;

                    if (isCurrentlyDownloading) {
                      final percentage = (progress * 100).toInt();
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'جارٍ تحميل السورة...',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF143427),
                                ),
                              ),
                              Text(
                                '${_toArabicNumber(percentage)} ٪',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.goldenPrimary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: LinearProgressIndicator(
                              value: progress > 0 ? progress : null,
                              minHeight: 8.h,
                              backgroundColor: isDark
                                  ? Colors.white12
                                  : const Color(0xFFEADBCE),
                              color: const Color(0xFF143427),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          OutlinedButton.icon(
                            onPressed: () {
                              _downloadService.cancelDownload(
                                _selectedReciterId,
                                widget.surahId,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            icon: Icon(
                              Icons.cancel_rounded,
                              color: Colors.red.shade700,
                              size: 16.sp,
                            ),
                            label: Text(
                              'إلغاء التحميل',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    if (_isDownloaded) {
                      return Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E382B)
                                  : const Color(0xFFE8F1EC),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: const Color(0xFF2E7D5E),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF2E7D5E),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'السورة محملة وجاهزة للاستماع بدون نت'
                                    '${_fileSizeBytes != null ? " (${_formatFileSize(_fileSizeBytes!)})" : ""}',
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF143427),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context.read<AudioCubit>().playSurah(
                                          widget.surahId,
                                          title: widget.surahName,
                                        );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF143427),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 11.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  icon: const Icon(Icons.play_arrow_rounded),
                                  label: const Text('تشغيل السورة الآن'),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              OutlinedButton.icon(
                                onPressed: _deleteDownload,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.red.shade300),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 11.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red.shade700,
                                  size: 18.sp,
                                ),
                                label: Text(
                                  'حذف',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    // غير محملة بعد
                    return Column(
                      children: [
                        Text(
                          'يمكنك تحميل الملف الصوتي الكامل للسورة لتشغيله في أي وقت دون الحاجة لشبكة الإنترنت.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            height: 1.5,
                            color: isDark ? Colors.white70 : const Color(0xFF736152),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _startDownload,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF143427),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.cloud_download_rounded),
                            label: Text(
                              'تحميل السورة الآن للعمل بدون نت',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
