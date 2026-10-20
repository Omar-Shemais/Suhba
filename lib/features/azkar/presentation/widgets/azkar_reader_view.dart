import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/azkar_model.dart';
import '../cubit/azkar_cubit.dart';
import '../cubit/azkar_states.dart';

class AzkarReaderView extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final String azkarType; // 'morning', 'evening', 'after_prayer'

  const AzkarReaderView({
    super.key,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.azkarType,
  });

  @override
  State<AzkarReaderView> createState() => _AzkarReaderViewState();
}

class _AzkarReaderViewState extends State<AzkarReaderView> {
  // Map of item index to remaining repeat counts
  final Map<int, int> _remainingCounts = {};
  double _fontSize = 19.0;
  bool _initializedCounts = false;

  void _initCounts(List<ZekrItem> items) {
    if (_initializedCounts) return;
    for (int i = 0; i < items.length; i++) {
      _remainingCounts[i] = items[i].repeat;
    }
    _initializedCounts = true;
  }

  void _decrementCount(int index, List<ZekrItem> items) {
    final current = _remainingCounts[index] ?? items[index].repeat;
    if (current > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        _remainingCounts[index] = current - 1;
      });

      if (_remainingCounts[index] == 0) {
        HapticFeedback.mediumImpact();
        _checkIfAllCompleted(items);
      }
    }
  }

  void _resetSingle(int index, int repeat) {
    HapticFeedback.selectionClick();
    setState(() {
      _remainingCounts[index] = repeat;
    });
  }

  void _resetAll(List<ZekrItem> items) {
    HapticFeedback.mediumImpact();
    setState(() {
      for (int i = 0; i < items.length; i++) {
        _remainingCounts[i] = items[i].repeat;
      }
    });
  }

  int _getCompletedCount(List<ZekrItem> items) {
    int count = 0;
    for (int i = 0; i < items.length; i++) {
      if ((_remainingCounts[i] ?? items[i].repeat) == 0) {
        count++;
      }
    }
    return count;
  }

  void _checkIfAllCompleted(List<ZekrItem> items) {
    if (items.isEmpty) return;
    final completed = _getCompletedCount(items);
    if (completed == items.length) {
      HapticFeedback.heavyImpact();
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor:
              isDark ? AppColors.containerDarkColor : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
            side: BorderSide(
              color: AppColors.goldenPrimary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70.w,
                  height: 70.w,
                  decoration: BoxDecoration(
                    gradient: AppColors.goldenGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldenPrimary.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'تقبّل الله طاعتكم 🤍',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.brownPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),
                Text(
                  'أتممت قراءة ${widget.title} كاملة.. جعله الله في ميزان حسناتك وحفظك به طوال اليوم.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.5,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.75)
                        : AppColors.brownPrimary.withValues(alpha: 0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: BorderSide(
                            color: isDark ? Colors.white38 : Colors.grey.shade400,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'تم',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.brownPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          final state = context.read<AzkarCubit>().state;
                          List<ZekrItem> items = [];
                          if (state is MorningAzkarSuccess) items = state.azkarModel.azkar;
                          if (state is EveningAzkarSuccess) items = state.azkarModel.azkar;
                          if (state is AfterPrayerAzkarSuccess) items = state.azkarModel.azkar;
                          _resetAll(items);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldenPrimary,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'إعادة القراءة',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.copy_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('تم نسخ الذكر إلى الحافظة ✨'),
          ],
        ),
        backgroundColor: AppColors.goldenPrimary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  void _shareZekr(String text, String bless) {
    HapticFeedback.selectionClick();
    final content = bless.isNotEmpty
        ? '$text\n\nفضل الذكر:\n$bless\n\n— من تطبيق صُحبة'
        : '$text\n\n— من تطبيق صُحبة';
    Share.share(content);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<AzkarCubit, AzkarState>(
      listener: (context, state) {
        if (state is MorningAzkarSuccess) {
          _initCounts(state.azkarModel.azkar);
        } else if (state is EveningAzkarSuccess) {
          _initCounts(state.azkarModel.azkar);
        } else if (state is AfterPrayerAzkarSuccess) {
          _initCounts(state.azkarModel.azkar);
        }
      },
      builder: (context, state) {
        List<ZekrItem> items = [];
        bool isLoading = state is AzkarLoading;
        String? errorMessage;

        if (state is AzkarError) {
          errorMessage = state.message;
        } else if (state is MorningAzkarSuccess) {
          items = state.azkarModel.azkar;
          _initCounts(items);
        } else if (state is EveningAzkarSuccess) {
          items = state.azkarModel.azkar;
          _initCounts(items);
        } else if (state is AfterPrayerAzkarSuccess) {
          items = state.azkarModel.azkar;
          _initCounts(items);
        }

        final completedCount = _getCompletedCount(items);
        final progressRatio = items.isEmpty ? 0.0 : (completedCount / items.length);

        return Scaffold(
          backgroundColor:
              isDark ? AppColors.backgroundDark : const Color(0xFFFBF8F2),
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.containerDarkColor : Colors.white,
            elevation: 0.5,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : AppColors.brownPrimary,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: widget.accentColor, size: 22),
                SizedBox(width: 8.w),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.brownPrimary,
                  ),
                ),
              ],
            ),
            actions: [
              // Font size adjustment buttons
              IconButton(
                icon: const Icon(Icons.text_decrease_rounded, size: 20),
                tooltip: 'تصغير الخط',
                onPressed: () {
                  if (_fontSize > 15) setState(() => _fontSize -= 1.5);
                },
              ),
              IconButton(
                icon: const Icon(Icons.text_increase_rounded, size: 20),
                tooltip: 'تكبير الخط',
                onPressed: () {
                  if (_fontSize < 28) setState(() => _fontSize += 1.5);
                },
              ),
              if (items.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.restart_alt_rounded, size: 22),
                  tooltip: 'إعادة البدء',
                  onPressed: () => _resetAll(items),
                ),
            ],
          ),
          body: isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.goldenPrimary),
                      SizedBox(height: 14.h),
                      Text(
                        'جاري تحميل الأذكار المباركة...',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? Colors.white70 : AppColors.brownPrimary,
                        ),
                      ),
                    ],
                  ),
                )
              : errorMessage != null && items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_off_rounded,
                              size: 54,
                              color: Colors.orange.shade300,
                            ),
                            SizedBox(height: 14.h),
                            Text(
                              'تعذر تحميل الأذكار حالياً',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.brownPrimary,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              errorMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                            ),
                            SizedBox(height: 18.h),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (widget.azkarType == 'morning') {
                                  context.read<AzkarCubit>().getMorningAzkar();
                                } else if (widget.azkarType == 'evening') {
                                  context.read<AzkarCubit>().getEveningAzkar();
                                } else {
                                  context.read<AzkarCubit>().getAfterPrayerAzkar();
                                }
                              },
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                              label: const Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.goldenPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // Progress sticky bar at top
                        _buildProgressHeader(
                          isDark: isDark,
                          completed: completedCount,
                          total: items.length,
                          ratio: progressRatio,
                        ),

                        // Azkar list
                        Expanded(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 12.h,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final remaining =
                                  _remainingCounts[index] ?? item.repeat;
                              final isCompleted = remaining == 0;

                              return _buildZekrCard(
                                index: index,
                                item: item,
                                remaining: remaining,
                                isCompleted: isCompleted,
                                isDark: isDark,
                                onDecrement: () => _decrementCount(index, items),
                                onReset: () => _resetSingle(index, item.repeat),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }

  Widget _buildProgressHeader({
    required bool isDark,
    required int completed,
    required int total,
    required double ratio,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.containerDarkColor : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.goldenPrimary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.goldenPrimary,
                    size: 18,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'نسبة الإنجاز: $completed من $total ذكر',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.brownPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.goldenPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${(ratio * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldenPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6.h,
              backgroundColor: isDark
                  ? Colors.white12
                  : AppColors.goldenSecondary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                completed == total ? const Color(0xFF2E7D32) : AppColors.goldenPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZekrCard({
    required int index,
    required ZekrItem item,
    required int remaining,
    required bool isCompleted,
    required bool isDark,
    required VoidCallback onDecrement,
    required VoidCallback onReset,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: isDark
            ? (isCompleted
                ? const Color(0xFF1B2E1E)
                : AppColors.containerDarkColor)
            : (isCompleted
                ? const Color(0xFFF3F9F4)
                : Colors.white),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF4CAF50).withValues(alpha: 0.5)
              : AppColors.goldenPrimary.withValues(alpha: 0.25),
          width: isCompleted ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? const Color(0xFF4CAF50).withValues(alpha: 0.08)
                : AppColors.goldenPrimary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header of card: Item index + Actions
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Index badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.goldenPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    'الذكر ${index + 1}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldenPrimary,
                    ),
                  ),
                ),
                // Action icons: Copy & Share & Reset
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      tooltip: 'نسخ الذكر',
                      color: isDark ? Colors.white60 : Colors.brown.shade400,
                      onPressed: () => _copyToClipboard(item.zekr),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.all(6.r),
                    ),
                    SizedBox(width: 6.w),
                    IconButton(
                      icon: const Icon(Icons.share_rounded, size: 18),
                      tooltip: 'مشاركة الذكر',
                      color: isDark ? Colors.white60 : Colors.brown.shade400,
                      onPressed: () => _shareZekr(item.zekr, item.bless),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.all(6.r),
                    ),
                    if (isCompleted) ...[
                      SizedBox(width: 6.w),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        tooltip: 'إعادة هذا الذكر',
                        color: Colors.green,
                        onPressed: onReset,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.all(6.r),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Main Zekr Arabic Text (Amiri font)
          InkWell(
            onTap: onDecrement,
            borderRadius: BorderRadius.circular(14.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Text(
                item.zekr,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: _fontSize.sp,
                  height: 1.85,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF2C1810),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Bless / Virtue box if present
          if (item.bless.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 10.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFFFF9ED),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.goldenPrimary.withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.goldenPrimary,
                      size: 16,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        item.bless,
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.45,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.8)
                              : AppColors.brownPrimary.withValues(alpha: 0.85),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Interactive Counter Bottom Bar
          InkWell(
            onTap: onDecrement,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(17.r)),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                gradient: isCompleted
                    ? const LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
                      )
                    : AppColors.goldenGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(17.r)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.touch_app_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    isCompleted
                        ? 'تم الانتهاء ✓'
                        : 'المتبقي: $remaining / ${item.repeat}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
