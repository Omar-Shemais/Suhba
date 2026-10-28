import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/duaa_item.dart';

class DuaaCategoryDetailScreen extends StatefulWidget {
  final DuaaCategory category;

  const DuaaCategoryDetailScreen({super.key, required this.category});

  @override
  State<DuaaCategoryDetailScreen> createState() =>
      _DuaaCategoryDetailScreenState();
}

class _DuaaCategoryDetailScreenState extends State<DuaaCategoryDetailScreen> {
  double _fontSize = 19.0;

  void _copyDuaa(DuaaItem item) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: '${item.arabic}\n\n${item.translation}'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.copy_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('تم نسخ الدعاء إلى الحافظة ✨'),
          ],
        ),
        backgroundColor: AppColors.goldenPrimary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  void _shareDuaa(DuaaItem item) {
    HapticFeedback.selectionClick();
    final text =
        '${item.arabic}\n\n${item.translation}\n\n— من تطبيق صُحبة';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final items = widget.category.items;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1E2125) : const Color(0xFFFAF5ED),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF282C32) : Colors.white,
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
            Icon(widget.category.icon, color: widget.category.accentColor, size: 22),
            SizedBox(width: 8.w),
            Text(
              widget.category.titleAr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.brownPrimary,
              ),
            ),
          ],
        ),
        actions: [
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
        ],
      ),
      body: Column(
        children: [
          // Header info bar & Search
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.category.descriptionAr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.white70 : AppColors.brownPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: widget.category.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '${widget.category.count} دعاء',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: widget.category.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List of Duas
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildDuaaCard(item, index + 1, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuaaCard(DuaaItem item, int displayIndex, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark
              ? const Color(0xFF383E46)
              : const Color(0xFFEADBCE),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldenPrimary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.goldenPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    'دعاء $displayIndex',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldenPrimary,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      tooltip: 'نسخ الدعاء',
                      color: isDark ? Colors.white60 : Colors.brown.shade400,
                      onPressed: () => _copyDuaa(item),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.all(6.r),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: const Icon(Icons.share_rounded, size: 18),
                      tooltip: 'مشاركة الدعاء',
                      color: isDark ? Colors.white60 : Colors.brown.shade400,
                      onPressed: () => _shareDuaa(item),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.all(6.r),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Arabic Duaa Text (Amiri font)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
            child: Text(
              item.arabic,
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

          // Translation if available
          if (item.translation.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 14.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF21252A)
                      : const Color(0xFFFFF9ED),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF383E46)
                        : const Color(0xFFEADBCE),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  item.translation,
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.45,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.75)
                        : AppColors.brownPrimary.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
