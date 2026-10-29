import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/assets.dart';
import 'package:islamic_app/core/routes/app_routes.dart';
import 'package:islamic_app/features/notification/data/services/notifications_feed_service.dart';

class HomeHeaderWidget extends StatefulWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSettingsTap;

  const HomeHeaderWidget({
    super.key,
    this.onNotificationTap,
    this.onSettingsTap,
  });

  @override
  State<HomeHeaderWidget> createState() => _HomeHeaderWidgetState();
}

class _HomeHeaderWidgetState extends State<HomeHeaderWidget> {
  int _alertsCount = 6;

  @override
  void initState() {
    super.initState();
    _loadAlertsCount();
    NotificationsFeedService.alertsCountNotifier.addListener(_onAlertsChanged);
  }

  void _onAlertsChanged() {
    if (mounted) {
      setState(() {
        _alertsCount = NotificationsFeedService.alertsCountNotifier.value;
      });
    }
  }

  @override
  void dispose() {
    NotificationsFeedService.alertsCountNotifier.removeListener(_onAlertsChanged);
    super.dispose();
  }

  Future<void> _loadAlertsCount() async {
    final count = await NotificationsFeedService.getAlertsCount();
    if (mounted) {
      setState(() => _alertsCount = count);
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final topPadding = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        // الخلفية الفنية للمساجد والمآذن مع تدرج يندمج بسلاسة
        Positioned.fill(
          child: ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: isDark ? 0.35 : 0.65),
                  Colors.white.withValues(alpha: isDark ? 0.15 : 0.35),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.6, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: Image.asset(
              AssetsData.headerMosqueBg,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),

        // المحتوى الرئيسي للهيدر
        Padding(
          padding: EdgeInsets.only(
            top: topPadding + 6.h,
            left: 18.w,
            right: 18.w,
            bottom: 8.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الصف العلوي: زر الإعدادات وزر الإشعارات (الجرس) بجانب بعضهما
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSettingsButton(context, isDark),
                    SizedBox(width: 8.w),
                    _buildNotificationButton(context, isDark),
                  ],
                ),
              ),

              SizedBox(height: 4.h),

              // نصوص الترحيب واسم التطبيق
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'السلام عليكم',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFC7B7A6)
                          : const Color(0xFF8C7765),
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      isDark ? AssetsData.logoDark : AssetsData.logo,
                      height: 52.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'رفيقك في رحلتك الروحية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFC7B7A6)
                          : const Color(0xFF8C7765),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsButton(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            widget.onSettingsTap ??
            () => GoRouter.of(context).push(AppRoutes.settings),
        borderRadius: BorderRadius.circular(50.r),
        child: Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF282C32) : const Color(0xFFF7EFE4),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.settings_outlined,
              size: 22.sp,
              color: isDark ? Colors.white : const Color(0xFF38291D),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onNotificationTap ??
            () async {
              await context.push(AppRoutes.notifications);
              _loadAlertsCount();
            },
        borderRadius: BorderRadius.circular(50.r),
        child: Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF282C32) : const Color(0xFFF7EFE4),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_rounded,
                size: 22.sp,
                color: isDark ? Colors.white : const Color(0xFF38291D),
              ),
              if (_alertsCount > 0)
                Positioned(
                  top: -2.h,
                  right: -2.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
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
                            ? const Color(0xFF2C2520)
                            : const Color(0xFFF7EFE4),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _toArabicDigits(_alertsCount),
                        style: TextStyle(
                          fontSize: 9.sp,
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
        ),
      ),
    );
  }
}
