// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import '../../data/helpers/quran_reading_mode_helper.dart';

class QuranAutoScrollSidebar extends StatefulWidget {
  final ScrollController scrollController;
  final ValueChanged<bool>? onPlayStateChanged;

  const QuranAutoScrollSidebar({
    super.key,
    required this.scrollController,
    this.onPlayStateChanged,
  });

  @override
  State<QuranAutoScrollSidebar> createState() => _QuranAutoScrollSidebarState();
}

class _QuranAutoScrollSidebarState extends State<QuranAutoScrollSidebar>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  double _speed = 1.0; // 0.5x to 5.0x
  bool _isExpanded = false;
  Timer? _scrollTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _loadSpeed();
  }

  Future<void> _loadSpeed() async {
    final speed = await QuranReadingModeHelper.getAutoScrollSpeed();
    if (mounted) {
      setState(() => _speed = speed.clamp(0.5, 5.0));
    }
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pulseController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _scrollTimer?.cancel();
    setState(() => _isPlaying = true);
    widget.onPlayStateChanged?.call(true);

    // سرعة السكرول: كل 25 ميلي ثانية نزيد مسافة محسوبة بناءً على السرعة
    const tickInterval = Duration(milliseconds: 25);
    _scrollTimer = Timer.periodic(tickInterval, (_) {
      if (!widget.scrollController.hasClients) return;

      final controller = widget.scrollController;
      final maxOffset = controller.position.maxScrollExtent;
      final currentOffset = controller.offset;

      if (currentOffset >= maxOffset) {
        _stopAutoScroll();
        return;
      }

      // حساب الخطوة: السرعة 1.0 تعادل تقريباً 35-40 بكسل في الثانية
      final step = 0.9 * _speed;
      final newOffset = (currentOffset + step).clamp(0.0, maxOffset);
      controller.jumpTo(newOffset);
    });
  }

  void _stopAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
    if (_isPlaying && mounted) {
      setState(() => _isPlaying = false);
      widget.onPlayStateChanged?.call(false);
    }
  }

  void _toggleAutoScroll() {
    if (_isPlaying) {
      _stopAutoScroll();
    } else {
      _startAutoScroll();
    }
  }

  void _adjustSpeed(double delta) {
    setState(() {
      _speed = (_speed + delta).clamp(0.5, 5.0);
    });
    QuranReadingModeHelper.saveAutoScrollSpeed(_speed);
    if (_isPlaying) {
      _startAutoScroll(); // تحديث السرعة أثناء التشغيل
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      left: 12.w, // على جانب الشاشة
      bottom: 90.h,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xE61F1F1F)
              : const Color(0xF2FFFFFF),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: _isPlaying
                ? AppColors.goldenPrimary
                : (isDark ? Colors.white12 : Colors.black12),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isPlaying
                  ? AppColors.goldenPrimary.withOpacity(0.3)
                  : Colors.black.withOpacity(0.18),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _isExpanded ? _buildExpandedPanel(isDark) : _buildCollapsedPill(isDark),
      ),
    );
  }

  // وضع الشريط المصغر (Floating Pill)
  Widget _buildCollapsedPill(bool isDark) {
    return InkWell(
      onTap: () => setState(() => _isExpanded = true),
      borderRadius: BorderRadius.circular(24.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // زر التشغيل السريع
            GestureDetector(
              onTap: _toggleAutoScroll,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.goldenPrimary, AppColors.goldenSecondary],
                      ),
                      boxShadow: _isPlaying
                          ? [
                              BoxShadow(
                                color: AppColors.goldenPrimary
                                    .withOpacity(0.4 + 0.3 * _pulseController.value),
                                blurRadius: 8 + 4 * _pulseController.value,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isPlaying ? 'تمرير ذكي' : 'تمرير تلقائي',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.brownPrimary,
                  ),
                ),
                Text(
                  '${_speed.toStringAsFixed(1)}x',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldenPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white60 : Colors.black45,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  // وضع لوحة التحكم الكاملة للشريط الجانبي
  Widget _buildExpandedPanel(bool isDark) {
    return Container(
      width: 140.w,
      padding: EdgeInsets.all(12.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // رأس الشريط مع زر الإغلاق
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التحكم بالسكرول',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.brownPrimary,
                ),
              ),
              InkWell(
                onTap: () => setState(() => _isExpanded = false),
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.all(2.r),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18.sp,
                    color: isDark ? Colors.white60 : Colors.black45,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 16, thickness: 0.6),

          // زر التشغيل والإيقاف الكبير
          GestureDetector(
            onTap: _toggleAutoScroll,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.goldenPrimary, AppColors.goldenSecondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldenPrimary.withOpacity(
                          _isPlaying ? 0.4 + 0.3 * _pulseController.value : 0.2,
                        ),
                        blurRadius: _isPlaying ? 12 : 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _isPlaying ? 'إيقاف مؤقت' : 'بدء التمرير',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: _isPlaying ? AppColors.goldenPrimary : (isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          SizedBox(height: 12.h),

          // التحكم بالسرعة
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // زر إبطاء
                _buildSpeedButton(
                  icon: Icons.remove_rounded,
                  onTap: () => _adjustSpeed(-0.5),
                  enabled: _speed > 0.5,
                  isDark: isDark,
                ),

                // عرض السرعة
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_speed.toStringAsFixed(1)}x',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldenPrimary,
                      ),
                    ),
                    Text(
                      'السرعة',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),

                // زر تسريع
                _buildSpeedButton(
                  icon: Icons.add_rounded,
                  onTap: () => _adjustSpeed(0.5),
                  enabled: _speed < 5.0,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          // أزرار القفز السريع للأعلى والأسفل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildJumpButton(
                icon: Icons.vertical_align_top_rounded,
                tooltip: 'للبداية',
                onTap: () {
                  if (widget.scrollController.hasClients) {
                    widget.scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                    );
                  }
                },
                isDark: isDark,
              ),
              _buildJumpButton(
                icon: Icons.vertical_align_bottom_rounded,
                tooltip: 'للنهاية',
                onTap: () {
                  if (widget.scrollController.hasClients) {
                    widget.scrollController.animateTo(
                      widget.scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                    );
                  }
                },
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
    required bool isDark,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: enabled
              ? (isDark ? Colors.white10 : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: enabled
              ? (isDark ? Colors.white : Colors.black87)
              : Colors.grey.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildJumpButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            size: 18.sp,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
    );
  }
}
