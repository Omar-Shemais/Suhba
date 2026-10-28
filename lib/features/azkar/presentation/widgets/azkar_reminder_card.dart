import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../services/azkar_notification_service.dart';

class AzkarReminderCard extends StatefulWidget {
  const AzkarReminderCard({super.key});

  @override
  State<AzkarReminderCard> createState() => _AzkarReminderCardState();
}

class _AzkarReminderCardState extends State<AzkarReminderCard> {
  final AzkarNotificationService _service = AzkarNotificationService();

  bool _isAutoMode = true;
  bool _morningEnabled = true;
  int _morningHour = 6;
  int _morningMinute = 30;

  bool _eveningEnabled = true;
  int _eveningHour = 17;
  int _eveningMinute = 0;

  String? _fajrTime;
  String? _sunriseTime;
  String? _asrTime;
  String? _maghribTime;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _service.getSettings();
    if (mounted) {
      setState(() {
        _isAutoMode = settings.isAutoSolarMode;
        _morningEnabled = settings.morningEnabled;
        _morningHour = settings.morningHour;
        _morningMinute = settings.morningMinute;

        _eveningEnabled = settings.eveningEnabled;
        _eveningHour = settings.eveningHour;
        _eveningMinute = settings.eveningMinute;

        _fajrTime = settings.fajrTime;
        _sunriseTime = settings.sunriseTime;
        _asrTime = settings.asrTime;
        _maghribTime = settings.maghribTime;

        _isLoading = false;
      });
    }
  }

  String _formatTime(int hour, int minute) {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    return '$h:$m $period';
  }

  Future<void> _toggleAutoMode(bool val) async {
    HapticFeedback.mediumImpact();
    setState(() => _isAutoMode = val);
    await _service.setAutoSolarMode(val);
    await _loadSettings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                val ? Icons.wb_twilight_rounded : Icons.alarm_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  val
                      ? 'تم تفعيل التوقيت التلقائي حسب الشروق والغروب ومواقيت الصلاة ☀️'
                      : 'تم التحويل إلى التوقيت اليدوي الثابت ⏰',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.goldenPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  bool _isMorningDefault() =>
      _morningHour == AzkarNotificationService.defaultMorningHour &&
      _morningMinute == AzkarNotificationService.defaultMorningMinute;

  bool _isEveningDefault() =>
      _eveningHour == AzkarNotificationService.defaultEveningHour &&
      _eveningMinute == AzkarNotificationService.defaultEveningMinute;

  Future<void> _resetToDefault({required bool isMorning}) async {
    HapticFeedback.mediumImpact();
    final defH = isMorning
        ? AzkarNotificationService.defaultMorningHour
        : AzkarNotificationService.defaultEveningHour;
    final defM = isMorning
        ? AzkarNotificationService.defaultMorningMinute
        : AzkarNotificationService.defaultEveningMinute;

    if (isMorning) {
      setState(() {
        _morningHour = defH;
        _morningMinute = defM;
      });
      await _service.scheduleMorningAzkar(
        hour: defH,
        minute: defM,
        enabled: _morningEnabled,
      );
    } else {
      setState(() {
        _eveningHour = defH;
        _eveningMinute = defM;
      });
      await _service.scheduleEveningAzkar(
        hour: defH,
        minute: defM,
        enabled: _eveningEnabled,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.restore_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isMorning
                      ? 'تمت استعادة الموعد الافتراضي لأذكار الصباح (06:30 ص)'
                      : 'تمت استعادة الموعد الافتراضي لأذكار المساء (05:00 م)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF143427),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pickTime({required bool isMorning}) async {
    HapticFeedback.selectionClick();

    // If currently in auto mode, notify that picking manual time will switch to manual mode
    if (_isAutoMode) {
      final shouldSwitch = await showDialog<bool>(
        context: context,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final primaryColor = isDark ? const Color(0xFFC7A87A) : const Color(0xFF143427);
          return AlertDialog(
            backgroundColor:
                isDark ? AppColors.containerDarkColor : const Color(0xFFFAF5ED),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
              side: BorderSide(
                color: isDark ? primaryColor.withValues(alpha: 0.3) : const Color(0xFFEADBCE),
              ),
            ),
            title: Row(
              children: [
                Icon(Icons.edit_calendar_rounded, color: primaryColor, size: 24),
                SizedBox(width: 8.w),
                const Text('تحديد وقت يدوي ثابت'),
              ],
            ),
            content: Text(
              'أنت الآن في وضع الربط التلقائي بالشروق والغروب ومواقيت الصلاة.\n\nهل ترغب في تحديد ساعة ثابتة يدوياً؟ (سيتم إيقاف التحديث التلقائي اليومي ويمكنك العودة له بأي وقت).',
              style: TextStyle(
                fontSize: 13.5.sp,
                height: 1.5,
                color: isDark ? Colors.white70 : const Color(0xFF38291D),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'إلغاء',
                  style: TextStyle(color: isDark ? Colors.white60 : const Color(0xFF736152)),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: const Text('متابعة واختيار الوقت'),
              ),
            ],
          );
        },
      );

      if (shouldSwitch != true) return;
      await _service.setAutoSolarMode(false);
      setState(() => _isAutoMode = false);
    }

    if (!mounted) return;

    final defaultH = isMorning
        ? AzkarNotificationService.defaultMorningHour
        : AzkarNotificationService.defaultEveningHour;
    final defaultM = isMorning
        ? AzkarNotificationService.defaultMorningMinute
        : AzkarNotificationService.defaultEveningMinute;

    final picked = await showDialog<TimeOfDay>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _IslamicTimePickerDialog(
        isMorning: isMorning,
        initialHour: isMorning ? _morningHour : _eveningHour,
        initialMinute: isMorning ? _morningMinute : _eveningMinute,
        defaultHour: defaultH,
        defaultMinute: defaultM,
      ),
    );

    if (picked != null) {
      HapticFeedback.mediumImpact();
      if (isMorning) {
        setState(() {
          _morningHour = picked.hour;
          _morningMinute = picked.minute;
        });
        await _service.scheduleMorningAzkar(
          hour: picked.hour,
          minute: picked.minute,
          enabled: _morningEnabled,
        );
      } else {
        setState(() {
          _eveningHour = picked.hour;
          _eveningMinute = picked.minute;
        });
        await _service.scheduleEveningAzkar(
          hour: picked.hour,
          minute: picked.minute,
          enabled: _eveningEnabled,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isMorning
                        ? 'تم ضبط تنبيه أذكار الصباح على ${_formatTime(picked.hour, picked.minute)}'
                        : 'تم ضبط تنبيه أذكار المساء على ${_formatTime(picked.hour, picked.minute)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF143427),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _toggleMorning(bool value) async {
    HapticFeedback.lightImpact();
    setState(() => _morningEnabled = value);
    await _service.scheduleMorningAzkar(
      hour: _morningHour,
      minute: _morningMinute,
      enabled: value,
    );
  }

  Future<void> _toggleEvening(bool value) async {
    HapticFeedback.lightImpact();
    setState(() => _eveningEnabled = value);
    await _service.scheduleEveningAzkar(
      hour: _eveningHour,
      minute: _eveningMinute,
      enabled: value,
    );
  }

  Future<void> _sendTestNotification(bool isMorning) async {
    HapticFeedback.heavyImpact();
    await _service.sendTestNotification(isMorning: isMorning);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isMorning
                      ? 'تم إرسال إشعار تجريبي لأذكار الصباح 🌅'
                      : 'تم إرسال إشعار تجريبي لأذكار المساء 🌙',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.brownPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Container(
        height: 140.h,
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          color: isDark ? const Color(0xFFC7A87A) : const Color(0xFF143427),
          backgroundColor: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.containerDarkColor : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? AppColors.goldenPrimary.withValues(alpha: 0.25)
              : const Color(0xFFEADBCE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.goldenPrimary.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Bell & Title
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.goldenPrimary
                      : const Color(0xFF143427),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تنبيهات الأذكار الذكية',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF38291D),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'مربوطة فلكياً بحركة الشمس ومواقيت الصلاة',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : const Color(0xFF38291D).withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              // Test Notification Menu
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: isDark ? Colors.white70 : const Color(0xFF38291D),
                ),
                tooltip: 'خيارات التنبيه',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                onSelected: (val) {
                  if (val == 'test_morning') {
                    _sendTestNotification(true);
                  } else if (val == 'test_evening') {
                    _sendTestNotification(false);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'test_morning',
                    child: Row(
                      children: [
                        const Icon(Icons.wb_sunny_rounded, color: Colors.orange, size: 18),
                        SizedBox(width: 8.w),
                        const Text('تجربة إشعار الصباح'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'test_evening',
                    child: Row(
                      children: [
                        const Icon(Icons.nights_stay_rounded, color: Colors.indigo, size: 18),
                        SizedBox(width: 8.w),
                        const Text('تجربة إشعار المساء'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Auto Solar Mode Toggle Banner
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: _isAutoMode
                  ? (isDark
                      ? AppColors.goldenPrimary.withValues(alpha: 0.12)
                      : const Color(0xFF143427).withValues(alpha: 0.08))
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.withValues(alpha: 0.08)),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: _isAutoMode
                    ? (isDark
                        ? AppColors.goldenPrimary.withValues(alpha: 0.4)
                        : const Color(0xFF143427).withValues(alpha: 0.3))
                    : Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isAutoMode
                      ? Icons.wb_twilight_rounded
                      : Icons.alarm_rounded,
                  color: _isAutoMode
                      ? (isDark
                          ? AppColors.goldenPrimary
                          : const Color(0xFF143427))
                      : Colors.grey,
                  size: 22,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'التحديث التلقائي مع الشروق والغروب',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF38291D),
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: _isAutoMode
                                  ? (isDark
                                      ? AppColors.goldenPrimary
                                      : const Color(0xFF143427))
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              _isAutoMode ? 'مُفعّل' : 'يدوي',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _isAutoMode
                            ? 'يتغير الموعد يومياً تلقائياً مع تغير فصول السنة وموقعك'
                            : 'توقيت يدوي ثابت تختاره بنفسك',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isDark
                              ? Colors.white60
                              : const Color(0xFF38291D).withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _isAutoMode,
                  onChanged: _toggleAutoMode,
                  activeThumbColor: isDark
                      ? AppColors.goldenPrimary
                      : const Color(0xFF143427),
                  activeTrackColor: isDark
                      ? AppColors.goldenSecondary.withValues(alpha: 0.4)
                      : const Color(0xFF143427).withValues(alpha: 0.3),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),
          const Divider(height: 1, thickness: 0.6),
          SizedBox(height: 12.h),

          // Morning Azkar Row
          _buildAzkarReminderRow(
            context: context,
            isDark: isDark,
            isMorning: true,
            title: 'أذكار الصباح',
            subtitle: _isAutoMode
                ? 'تلقائي: بعد الفجر بـ 20 دقيقة${_fajrTime != null ? ' (الفجر $_fajrTime)' : (_sunriseTime != null ? ' (الشروق $_sunriseTime)' : '')}'
                : 'موعد يدوي ثابت',
            icon: Icons.wb_sunny_rounded,
            iconColor: const Color(0xFFE5A93C),
            timeStr: _formatTime(_morningHour, _morningMinute),
            enabled: _isAutoMode ? true : _morningEnabled,
            isLockedByAuto: _isAutoMode,
            isDefault: _isMorningDefault(),
            onToggle: _isAutoMode ? null : _toggleMorning,
            onTapTime: _isAutoMode ? null : () => _pickTime(isMorning: true),
            onResetToDefault: () => _resetToDefault(isMorning: true),
          ),

          SizedBox(height: 12.h),

          // Evening Azkar Row
          _buildAzkarReminderRow(
            context: context,
            isDark: isDark,
            isMorning: false,
            title: 'أذكار المساء',
            subtitle: _isAutoMode
                ? 'تلقائي: بعد العصر بـ 20 دقيقة${_asrTime != null ? ' (العصر $_asrTime)' : (_maghribTime != null ? ' (الغروب $_maghribTime)' : '')}'
                : 'موعد يدوي ثابت',
            icon: Icons.nights_stay_rounded,
            iconColor: const Color(0xFF6C63FF),
            timeStr: _formatTime(_eveningHour, _eveningMinute),
            enabled: _isAutoMode ? true : _eveningEnabled,
            isLockedByAuto: _isAutoMode,
            isDefault: _isEveningDefault(),
            onToggle: _isAutoMode ? null : _toggleEvening,
            onTapTime: _isAutoMode ? null : () => _pickTime(isMorning: false),
            onResetToDefault: () => _resetToDefault(isMorning: false),
          ),
        ],
      ),
    );
  }

  void _showAutoModeNotice() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.lock_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'أذكار الصباح والمساء مضبوطة تلقائياً مع الشروق والغروب ومواقيت الصلاة. للتحكم اليدوي، أوقف خيار التحديث التلقائي أولاً.',
                style: TextStyle(fontSize: 12.5),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF143427),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildAzkarReminderRow({
    required BuildContext context,
    required bool isDark,
    required bool isMorning,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String timeStr,
    required bool enabled,
    required bool isLockedByAuto,
    required bool isDefault,
    required ValueChanged<bool>? onToggle,
    required VoidCallback? onTapTime,
    required VoidCallback onResetToDefault,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : const Color(0xFFF7F3EB),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: enabled
              ? (isDark
                  ? AppColors.goldenPrimary.withValues(alpha: 0.3)
                  : const Color(0xFF143427).withValues(alpha: 0.25))
              : (isDark ? Colors.grey.withValues(alpha: 0.2) : const Color(0xFFEADBCE)),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(7.r),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF38291D),
                        ),
                      ),
                    ),
                    if (isLockedByAuto) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? AppColors.goldenPrimary
                                  : const Color(0xFF143427))
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              size: 10.sp,
                              color: isDark
                                  ? AppColors.goldenPrimary
                                  : const Color(0xFF143427),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'تلقائي',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.goldenPrimary
                                    : const Color(0xFF143427),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isDark
                        ? Colors.white54
                        : const Color(0xFF38291D).withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          // Time badge button
          InkWell(
            onTap: isLockedByAuto ? _showAutoModeNotice : onTapTime,
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: enabled
                    ? (isDark
                        ? AppColors.goldenPrimary.withValues(alpha: 0.15)
                        : const Color(0xFF143427).withValues(alpha: 0.1))
                    : Colors.grey.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isLockedByAuto
                      ? (isDark
                          ? AppColors.goldenPrimary.withValues(alpha: 0.35)
                          : const Color(0xFF143427).withValues(alpha: 0.25))
                      : (enabled
                          ? (isDark
                              ? AppColors.goldenPrimary.withValues(alpha: 0.5)
                              : const Color(0xFF143427).withValues(alpha: 0.35))
                          : Colors.grey.withValues(alpha: 0.3)),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isLockedByAuto ? Icons.lock_outline_rounded : Icons.access_time_rounded,
                    size: 13.sp,
                    color: enabled
                        ? (isDark
                            ? AppColors.goldenPrimary
                            : const Color(0xFF143427))
                        : Colors.grey,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                      color: enabled
                          ? (isDark
                              ? AppColors.goldenPrimary
                              : const Color(0xFF143427))
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // زر استعادة الافتراضي السريع على الكارد
          if (!_isAutoMode && !isDefault) ...[
            SizedBox(width: 5.w),
            InkWell(
              onTap: onResetToDefault,
              borderRadius: BorderRadius.circular(8.r),
              child: Tooltip(
                message: 'استعادة الموعد الافتراضي',
                child: Container(
                  padding: EdgeInsets.all(5.r),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: isDark ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(
                    Icons.restore_rounded,
                    size: 14.sp,
                    color: isDark ? Colors.orange.shade300 : Colors.orange.shade800,
                  ),
                ),
              ),
            ),
          ],
          SizedBox(width: 6.w),
          // Toggle switch
          Tooltip(
            message: isLockedByAuto
                ? 'مُفعّل تلقائياً مع الشروق والغروب (أوقف التحديث التلقائي للتحكم اليدوي)'
                : (enabled ? 'تعطيل التنبيه' : 'تفعيل التنبيه'),
            child: Switch.adaptive(
              value: isLockedByAuto ? true : enabled,
              onChanged: isLockedByAuto ? null : onToggle,
              activeThumbColor: isDark
                  ? AppColors.goldenPrimary
                  : const Color(0xFF143427),
              activeTrackColor: isDark
                  ? AppColors.goldenSecondary.withValues(alpha: 0.4)
                  : const Color(0xFF143427).withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

/// واجهة منتقي الوقت الإسلامي الحديثة مع استعادة الموعد الافتراضي
class _IslamicTimePickerDialog extends StatefulWidget {
  final bool isMorning;
  final int initialHour;
  final int initialMinute;
  final int defaultHour;
  final int defaultMinute;

  const _IslamicTimePickerDialog({
    required this.isMorning,
    required this.initialHour,
    required this.initialMinute,
    required this.defaultHour,
    required this.defaultMinute,
  });

  @override
  State<_IslamicTimePickerDialog> createState() =>
      _IslamicTimePickerDialogState();
}

class _IslamicTimePickerDialogState extends State<_IslamicTimePickerDialog> {
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialHour;
    _minute = widget.initialMinute;
  }

  bool get _isDefault =>
      _hour == widget.defaultHour && _minute == widget.defaultMinute;

  int get _display12Hour {
    final h = _hour % 12;
    return h == 0 ? 12 : h;
  }

  bool get _isAm => _hour < 12;

  void _setPeriod(bool am) {
    HapticFeedback.selectionClick();
    setState(() {
      final h12 = _display12Hour;
      if (am) {
        _hour = h12 == 12 ? 0 : h12;
      } else {
        _hour = h12 == 12 ? 12 : h12 + 12;
      }
    });
  }

  void _incrementHour() {
    HapticFeedback.selectionClick();
    setState(() {
      _hour = (_hour + 1) % 24;
    });
  }

  void _decrementHour() {
    HapticFeedback.selectionClick();
    setState(() {
      _hour = (_hour - 1 + 24) % 24;
    });
  }

  void _incrementMinute() {
    HapticFeedback.selectionClick();
    setState(() {
      _minute = ((_minute ~/ 5 + 1) * 5) % 60;
    });
  }

  void _decrementMinute() {
    HapticFeedback.selectionClick();
    setState(() {
      final step = (_minute ~/ 5) * 5;
      if (_minute != step) {
        _minute = step;
      } else {
        _minute = (_minute - 5 + 60) % 60;
      }
    });
  }

  void _resetToDefault() {
    HapticFeedback.mediumImpact();
    setState(() {
      _hour = widget.defaultHour;
      _minute = widget.defaultMinute;
    });
  }

  String _formatTime(int h, int m) {
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    final period = h >= 12 ? 'م' : 'ص';
    return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFC7A87A) : const Color(0xFF143427);
    final defaultStr = _formatTime(widget.defaultHour, widget.defaultMinute);

    final List<Map<String, dynamic>> presets = widget.isMorning
        ? [
            {'h': 5, 'm': 30, 'label': '05:30 ص'},
            {'h': 6, 'm': 0, 'label': '06:00 ص'},
            {'h': 6, 'm': 30, 'label': '06:30 ص (افتراضي)'},
            {'h': 7, 'm': 0, 'label': '07:00 ص'},
            {'h': 7, 'm': 30, 'label': '07:30 ص'},
          ]
        : [
            {'h': 16, 'm': 30, 'label': '04:30 م'},
            {'h': 17, 'm': 0, 'label': '05:00 م (افتراضي)'},
            {'h': 17, 'm': 30, 'label': '05:30 م'},
            {'h': 18, 'm': 0, 'label': '06:00 م'},
            {'h': 18, 'm': 30, 'label': '06:30 م'},
          ];

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1F1C18) : const Color(0xFFFAF5ED),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22.r),
        side: BorderSide(
          color: isDark ? primaryColor.withValues(alpha: 0.3) : const Color(0xFFEADBCE),
          width: 1.2,
        ),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // الهيدر
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: widget.isMorning
                        ? const Color(0xFFE5A93C).withValues(alpha: 0.15)
                        : const Color(0xFF6C63FF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    widget.isMorning ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                    color: widget.isMorning ? const Color(0xFFE5A93C) : const Color(0xFF6C63FF),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isMorning ? 'تحديد موعد أذكار الصباح' : 'تحديد موعد أذكار المساء',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF38291D),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'حدد التوقيت الثابت للتنبيه اليومي',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: isDark ? Colors.white60 : const Color(0xFF736152),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.all(4.r),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20.sp,
                      color: isDark ? Colors.white70 : const Color(0xFF736152),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            // زر استعادة الموعد الافتراضي
            InkWell(
              onTap: _isDefault ? null : _resetToDefault,
              borderRadius: BorderRadius.circular(12.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: _isDefault
                      ? (isDark
                          ? const Color(0xFF143427).withValues(alpha: 0.3)
                          : const Color(0xFF143427).withValues(alpha: 0.08))
                      : (isDark
                          ? Colors.orange.withValues(alpha: 0.2)
                          : Colors.orange.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _isDefault
                        ? (isDark ? primaryColor : const Color(0xFF143427).withValues(alpha: 0.3))
                        : Colors.orange.withValues(alpha: 0.4),
                    width: 0.9,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isDefault ? Icons.check_circle_rounded : Icons.restart_alt_rounded,
                      size: 16.sp,
                      color: _isDefault
                          ? (isDark ? primaryColor : const Color(0xFF143427))
                          : Colors.orange.shade800,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _isDefault
                            ? 'الموعد الافتراضي مفعل ($defaultStr)'
                            : 'استعادة الموعد الافتراضي ($defaultStr)',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.bold,
                          color: _isDefault
                              ? (isDark ? primaryColor : const Color(0xFF143427))
                              : Colors.orange.shade900,
                        ),
                      ),
                    ),
                    if (!_isDefault)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade700,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'اضغط للرجوع',
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // واجهة الساعة الإسلامية الرقمية الحديثة (Digital Clock)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark ? Colors.white12 : const Color(0xFFEADBCE),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // عمود الساعات
                  _buildTimeUnitColumn(
                    label: 'الساعة',
                    value: _display12Hour.toString().padLeft(2, '0'),
                    onIncrement: _incrementHour,
                    onDecrement: _decrementHour,
                    isDark: isDark,
                    primaryColor: primaryColor,
                  ),

                  // النقطتان
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Column(
                      children: [
                        Text(
                          ':',
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),

                  // عمود الدقائق
                  _buildTimeUnitColumn(
                    label: 'الدقيقة',
                    value: _minute.toString().padLeft(2, '0'),
                    onIncrement: _incrementMinute,
                    onDecrement: _decrementMinute,
                    isDark: isDark,
                    primaryColor: primaryColor,
                  ),

                  SizedBox(width: 14.w),

                  // تبديل صباحاً / مساءً
                  Column(
                    children: [
                      _buildPeriodButton(
                        label: 'ص',
                        sublabel: 'صباحاً',
                        isSelected: _isAm,
                        onTap: () => _setPeriod(true),
                        isDark: isDark,
                        primaryColor: primaryColor,
                      ),
                      SizedBox(height: 8.h),
                      _buildPeriodButton(
                        label: 'م',
                        sublabel: 'مساءً',
                        isSelected: !_isAm,
                        onTap: () => _setPeriod(false),
                        isDark: isDark,
                        primaryColor: primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 14.h),

            // قسم المقترحات السريعة
            Text(
              'مواعيد مقترحة سريعة:',
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : const Color(0xFF38291D),
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: presets.map((p) {
                final bool isSelected = _hour == p['h'] && _minute == p['m'];
                final bool isPresetDef = p['h'] == widget.defaultHour && p['m'] == widget.defaultMinute;
                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _hour = p['h'];
                      _minute = p['m'];
                    });
                  },
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? primaryColor : const Color(0xFF143427))
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.white),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isSelected
                            ? (isDark ? primaryColor : const Color(0xFF143427))
                            : (isPresetDef
                                ? Colors.orange.withValues(alpha: 0.5)
                                : (isDark ? Colors.white12 : const Color(0xFFEADBCE))),
                        width: isSelected || isPresetDef ? 1.2 : 0.8,
                      ),
                    ),
                    child: Text(
                      p['label'],
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : const Color(0xFF38291D)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 18.h),

            // أزرار الحفظ والإلغاء
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context, TimeOfDay(hour: _hour, minute: _minute));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? primaryColor : const Color(0xFF143427),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 11.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'تأكيد وحفظ الموعد',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark ? Colors.white24 : const Color(0xFFEADBCE),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.white70 : const Color(0xFF736152),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeUnitColumn({
    required String label,
    required String value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required bool isDark,
    required Color primaryColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // زر الزيادة
        InkWell(
          onTap: onIncrement,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFFAF5ED),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFFEADBCE),
              ),
            ),
            child: Icon(
              Icons.keyboard_arrow_up_rounded,
              size: 20.sp,
              color: primaryColor,
            ),
          ),
        ),

        SizedBox(height: 4.h),

        // خانة الرقم
        Container(
          width: 58.w,
          height: 50.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF26231E) : const Color(0xFFFAF5ED),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              fontFamily: 'monospace',
            ),
          ),
        ),

        SizedBox(height: 4.h),

        // زر النقصان
        InkWell(
          onTap: onDecrement,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFFAF5ED),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFFEADBCE),
              ),
            ),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20.sp,
              color: primaryColor,
            ),
          ),
        ),

        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: isDark ? Colors.white54 : const Color(0xFF736152),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodButton({
    required String label,
    required String sublabel,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 54.w,
        padding: EdgeInsets.symmetric(vertical: 5.h),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? primaryColor : const Color(0xFF143427))
              : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFFAF5ED)),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected
                ? (isDark ? primaryColor : const Color(0xFF143427))
                : (isDark ? Colors.white12 : const Color(0xFFEADBCE)),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF38291D)),
              ),
            ),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 8.sp,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.85)
                    : (isDark ? Colors.white38 : const Color(0xFF736152)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

