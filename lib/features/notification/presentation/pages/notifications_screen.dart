import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/assets.dart';
import 'package:islamic_app/core/routes/app_routes.dart';
import 'package:islamic_app/core/widgets/salawat_bottom_sheet.dart';
import '../../data/models/notification_item_model.dart';
import '../../data/services/notifications_feed_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItemModel> _notifications = [];
  int _alertsCount = 6;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await NotificationsFeedService.getNotifications();
    final count = await NotificationsFeedService.getAlertsCount();
    if (mounted) {
      setState(() {
        _notifications = list;
        _alertsCount = count;
        _isLoading = false;
      });
    }
  }

  String _toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => int.tryParse(d) != null ? arabicDigits[int.parse(d)] : d)
        .join('');
  }

  Color _getDotColor(NotificationDotColor dotColor) {
    switch (dotColor) {
      case NotificationDotColor.red:
        return const Color(0xFFD9483B);
      case NotificationDotColor.green:
        return const Color(0xFF2E8555);
      case NotificationDotColor.amber:
        return const Color(0xFFE67E22);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF1E2125) : const Color(0xFFFAF5ED),
        body: Stack(
          children: [
            // خلفية خيال المسجد العلوية مع تدريج ناعم
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 190.h,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: isDark ? 0.18 : 0.40),
                      Colors.transparent,
                    ],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  AssetsData.headerMosqueBg,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),

            // المحتوى الرئيسي
            SafeArea(
              child: Column(
                children: [
                  // شريط العنوان العلوي الفاخر
                  _buildTopBar(isDark),

                  SizedBox(height: 8.h),

                  // قائمة الإشعارات
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            color: const Color(0xFF143427),
                            backgroundColor: isDark
                                ? const Color(0xFF282C32)
                                : const Color(0xFFFAF5ED),
                            child: ListView(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 6.h,
                              ),
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              children: [
                                ..._notifications.map(
                                  (item) =>
                                      _buildNotificationCard(item, isDark),
                                ),

                                SizedBox(height: 14.h),

                                // زر الإجراء السفلي "كل إشعار .. خطوة نحو حياة أطيب"
                                _buildBottomActionButton(isDark),

                                SizedBox(height: 16.h),

                                // زخرفة أسفل القائمة
                                _buildBottomOrnament(isDark),

                                SizedBox(height: 10.h),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // شريط العنوان العلوي (مطابق للصورة بدقة)
  // ==============================================================
  Widget _buildTopBar(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الرجوع الدائري في أقصى اليمين (في الواجهة العربية)
          // يشير حصراً لليسار (<) وفق AGENTS.md
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF282C32) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18.sp,
                color: isDark ? Colors.white : const Color(0xFF38291D),
              ),
              tooltip: 'رجوع',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // العنوان والجرس والشارة في المنتصف
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة الجرس مع الشارة الحمراء لعدد التنبيهات
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_rounded,
                      size: 28.sp,
                      color: isDark ? Colors.white70 : const Color(0xFF143427),
                    ),
                    if (_alertsCount > 0)
                      Positioned(
                        top: -4.h,
                        right: -5.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.5.w,
                            vertical: 1.h,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16.w,
                            minHeight: 16.w,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9483B),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF14110E)
                                  : const Color(0xFFFAF5ED),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _toArabicDigits(_alertsCount),
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(width: 10.w),

                // نصوص العنوان والوصف
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'الإشعارات المهمة',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF143427),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'تنبيهاتك اليومية .. لرحلة أقرب إلى الله',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark ? Colors.white54 : const Color(0xFF736152),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // زر قراءة الكل أو مساحة فارغة لضبط التوسيط
          if (_alertsCount > 0)
            InkWell(
              onTap: () async {
                await NotificationsFeedService.markAllAsRead();
                if (mounted) {
                  _loadData();
                }
              },
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white12
                      : const Color(0xFF143427).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isDark
                        ? Colors.white24
                        : const Color(0xFF143427).withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.done_all_rounded,
                      size: 14.sp,
                      color: isDark
                          ? const Color(0xFFC7A87A)
                          : const Color(0xFF143427),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'قراءة الكل',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFC7A87A)
                            : const Color(0xFF143427),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(width: 42.w),
        ],
      ),
    );
  }

  // ==============================================================
  // بطاقة عنصر الإشعار المطابقة بدقة للصورة
  // ==============================================================
  Widget _buildNotificationCard(NotificationItemModel item, bool isDark) {
    final isGreen = item.iconStyle == NotificationIconStyle.green;
    final boxBg = isGreen
        ? (isDark ? Colors.white10 : const Color(0xFFE8F1EC))
        : (isDark ? Colors.white10 : const Color(0xFFF5EFE3));
    final iconColor = isGreen
        ? const Color(0xFF143427)
        : const Color(0xFF8C6D46);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: () async {
            // تحديث حالة القراءة والعدد فور الضغط
            if (!item.isRead) {
              await NotificationsFeedService.markAsRead(item.id);
              if (mounted) {
                final count = await NotificationsFeedService.getAlertsCount();
                setState(() {
                  _alertsCount = count;
                  final idx =
                      _notifications.indexWhere((n) => n.id == item.id);
                  if (idx != -1) {
                    _notifications[idx] =
                        _notifications[idx].copyWith(isRead: true);
                  }
                });
              }
            }

            if (!mounted) return;

            if (item.id == 'salawat') {
              _showSalawatBottomSheet(context, isDark);
            } else if (item.id == 'prayer_time') {
              // لا تنس الصلاة في وقتها: لا ينقل لأي شيء حسب طلب المستخدم
              return;
            } else if (item.id == 'istighfar') {
              context.push(AppRoutes.azkar);
            } else if (item.customAction != null) {
              item.customAction!();
            } else if (item.route != null) {
              context.push(item.route!);
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                // 1. أيقونة القسم في أقصى اليمين
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: boxBg,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Icon(
                      item.icon,
                      size: 22.sp,
                      color: iconColor,
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                // 2. النصوص في المنتصف (العنوان والوصف)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? (item.isRead
                                  ? Colors.white70
                                  : Colors.white)
                              : (item.isRead
                                  ? const Color(0xFF38291D)
                                  : const Color(0xFF143427)),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        item.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          height: 1.35,
                          color: isDark
                              ? Colors.white60
                              : const Color(0xFF736152),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                // 3. التوقيت والنقطة في أقصى اليسار
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // الوقت ونقطة التنبيه
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!item.isRead)
                          Container(
                            width: 6.5.w,
                            height: 6.5.w,
                            margin: EdgeInsets.only(left: 4.w),
                            decoration: BoxDecoration(
                              color: _getDotColor(item.dotColor),
                              shape: BoxShape.circle,
                            ),
                          ),
                        Text(
                          item.time,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            fontWeight: item.isRead
                                ? FontWeight.normal
                                : FontWeight.w500,
                            color: isDark
                                ? (item.isRead
                                    ? Colors.white38
                                    : Colors.white54)
                                : (item.isRead
                                    ? const Color(0xFFA8998D)
                                    : const Color(0xFF8C7A6B)),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // سهم الانتقال للتفاصيل يشير لليسار (<) وفق AGENTS.md
                    Icon(
                      Icons.chevron_left_rounded,
                      size: 19.sp,
                      color: isDark
                          ? Colors.white38
                          : const Color(0xFFBDB3A6),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // زر الإجراء السفلي "كل إشعار .. خطوة نحو حياة أطيب"
  // ==============================================================
  Widget _buildBottomActionButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: () {
          // الانتقال إلى شاشة إعدادات الإشعارات والتنبيهات
          context.push(AppRoutes.notificationSettings);
        },
        child: Container(
          height: 46.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B382B) : const Color(0xFFEFF6F2),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: const Color(0xFF143427).withValues(alpha: 0.18),
              width: 1.1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 22.w,
                height: 22.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF143427),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.add_rounded,
                    size: 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  'كل إشعار .. خطوة نحو حياة أطيب',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF143427),
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.favorite_border_rounded,
                size: 15.sp,
                color: isDark ? Colors.white70 : const Color(0xFF143427),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // زخرفة أسفل الصفحة
  // ==============================================================
  Widget _buildBottomOrnament(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40.w,
            height: 1.h,
            color: isDark ? Colors.white24 : const Color(0xFFC7B9A9),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.mosque_rounded,
            size: 18.sp,
            color: isDark ? Colors.white54 : const Color(0xFFB8782E),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 40.w,
            height: 1.h,
            color: isDark ? Colors.white24 : const Color(0xFFC7B9A9),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // الشيت السفلي للصلاة على النبي ﷺ
  // ==============================================================
  void _showSalawatBottomSheet(BuildContext context, bool isDark) {
    SalawatBottomSheet.show(context);
  }
}
