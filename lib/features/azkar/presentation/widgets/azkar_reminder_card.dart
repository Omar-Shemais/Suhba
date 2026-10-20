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

  Future<void> _pickTime({required bool isMorning}) async {
    HapticFeedback.selectionClick();

    // If currently in auto mode, notify that picking manual time will switch to manual mode
    if (_isAutoMode) {
      final shouldSwitch = await showDialog<bool>(
        context: context,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor:
                isDark ? AppColors.containerDarkColor : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: Row(
              children: [
                Icon(Icons.edit_calendar_rounded, color: AppColors.goldenPrimary, size: 24),
                SizedBox(width: 8.w),
                const Text('تحديد وقت يدوي ثابت'),
              ],
            ),
            content: Text(
              'أنت الآن في وضع الربط التلقائي بالشروق والغروب ومواقيت الصلاة.\n\nهل ترغب في تحديد ساعة ثابتة يدوياً؟ (سيتم إيقاف التحديث التلقائي اليومي).',
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
                color: isDark ? Colors.white70 : AppColors.brownPrimary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldenPrimary,
                ),
                child: const Text('متابعة واختيار الوقت', style: TextStyle(color: Colors.white)),
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

    final initialTime = isMorning
        ? TimeOfDay(hour: _morningHour, minute: _morningMinute)
        : TimeOfDay(hour: _eveningHour, minute: _eveningMinute);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      confirmText: 'حفظ',
      cancelText: 'إلغاء',
      helpText: isMorning ? 'اختر وقت أذكار الصباح' : 'اختر وقت أذكار المساء',
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.goldenPrimary,
              onPrimary: Colors.white,
              surface: isDark ? AppColors.containerDarkColor : Colors.white,
              onSurface: isDark ? Colors.white : AppColors.brownPrimary,
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
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
            backgroundColor: AppColors.goldenPrimary,
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
        child: CircularProgressIndicator(color: AppColors.goldenPrimary),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.containerDarkColor : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.goldenPrimary.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldenPrimary.withValues(alpha: 0.08),
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
                  gradient: AppColors.goldenGradient,
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
                        color: isDark ? Colors.white : AppColors.brownPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'مربوطة فلكياً بحركة الشمس ومواقيت الصلاة',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : AppColors.brownPrimary.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              // Test Notification Menu
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: isDark ? Colors.white70 : AppColors.brownPrimary,
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
                  ? AppColors.goldenPrimary.withValues(alpha: 0.12)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.withValues(alpha: 0.08)),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: _isAutoMode
                    ? AppColors.goldenPrimary.withValues(alpha: 0.4)
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
                  color: _isAutoMode ? AppColors.goldenPrimary : Colors.grey,
                  size: 22,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'التحديث التلقائي مع الشروق والغروب',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.brownPrimary,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: _isAutoMode ? AppColors.goldenPrimary : Colors.grey,
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
                          color: isDark ? Colors.white60 : Colors.brown.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _isAutoMode,
                  onChanged: _toggleAutoMode,
                  activeThumbColor: AppColors.goldenPrimary,
                  activeTrackColor: AppColors.goldenSecondary.withValues(alpha: 0.4),
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
            enabled: _morningEnabled,
            onToggle: _toggleMorning,
            onTapTime: () => _pickTime(isMorning: true),
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
            enabled: _eveningEnabled,
            onToggle: _toggleEvening,
            onTapTime: () => _pickTime(isMorning: false),
          ),
        ],
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
    required ValueChanged<bool> onToggle,
    required VoidCallback onTapTime,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: enabled
              ? AppColors.goldenPrimary.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
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
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.brownPrimary,
                      ),
                    ),
                    if (_isAutoMode) ...[
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.auto_mode_rounded,
                        size: 13,
                        color: AppColors.goldenPrimary,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isDark
                        ? Colors.white54
                        : AppColors.brownPrimary.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          // Time badge button
          InkWell(
            onTap: onTapTime,
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: enabled
                    ? AppColors.goldenPrimary.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: enabled
                      ? AppColors.goldenPrimary.withValues(alpha: 0.5)
                      : Colors.grey.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isAutoMode ? Icons.wb_twilight_rounded : Icons.edit_calendar_rounded,
                    size: 14,
                    color: enabled ? AppColors.goldenPrimary : Colors.grey,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: enabled ? AppColors.goldenPrimary : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Toggle switch
          Switch.adaptive(
            value: enabled,
            onChanged: onToggle,
            activeThumbColor: AppColors.goldenPrimary,
            activeTrackColor: AppColors.goldenSecondary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
