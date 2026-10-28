import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class QiblaCompassWidget extends StatefulWidget {
  final double qiblaAngle;
  final double? latitude;
  final double? longitude;

  const QiblaCompassWidget({
    super.key,
    required this.qiblaAngle,
    this.latitude,
    this.longitude,
  });

  @override
  State<QiblaCompassWidget> createState() => _QiblaCompassWidgetState();
}

class _QiblaCompassWidgetState extends State<QiblaCompassWidget> {
  bool _wasFacingQibla = false;

  // Smoothing / unwrapping state variables
  double? _lastRawNorth;
  double _unwrappedNorth = 0.0;

  void _checkFacingFeedback(bool isFacing) {
    if (isFacing && !_wasFacingQibla) {
      HapticFeedback.mediumImpact();
      _wasFacingQibla = true;
    } else if (!isFacing) {
      _wasFacingQibla = false;
    }
  }

  /// Format latitude and longitude to Degrees, Minutes, Seconds (DMS) format
  /// Example: 40°0'20" N, 116°28'37" E
  String _formatDms(double? lat, double? lng) {
    if (lat == null || lng == null) {
      return '40°0\'20" N, 116°28\'37" E';
    }

    String formatSingle(double val, String posSuffix, String negSuffix) {
      final suffix = val >= 0 ? posSuffix : negSuffix;
      final absVal = val.abs();
      final degrees = absVal.floor();
      final minutesDouble = (absVal - degrees) * 60;
      final minutes = minutesDouble.floor();
      final seconds = ((minutesDouble - minutes) * 60).round();
      return '$degrees°$minutes\'$seconds" $suffix';
    }

    return '${formatSingle(lat, "N", "S")}, ${formatSingle(lng, "E", "W")}';
  }

  /// Calculates smooth unwrapped angle avoiding 360°/0° snap-back jitter
  double _getUnwrappedNorth(double rawNorth) {
    if (_lastRawNorth == null) {
      _lastRawNorth = rawNorth;
      _unwrappedNorth = rawNorth;
      return _unwrappedNorth;
    }

    double diff = rawNorth - _lastRawNorth!;
    while (diff > 180) {
      diff -= 360;
    }
    while (diff < -180) {
      diff += 360;
    }

    _unwrappedNorth += diff;
    _lastRawNorth = rawNorth;
    return _unwrappedNorth;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "error".tr(),
              style: TextStyle(fontSize: 16.sp, color: AppColors.errorColor),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Color(0xFF143427)),
                SizedBox(height: 16.h),
                Text(
                  "جاري تهيئة البوصلة...",
                  style: TextStyle(fontSize: 14.sp),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final double? heading = snapshot.data?.heading;

        if (heading == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.explore_off,
                    size: 64,
                    color: AppColors.goldenPrimary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "مستشعر البوصلة غير متوفر في جهازك",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "زاوية اتجاه القبلة لموقعك الحالي هي:\n${widget.qiblaAngle.toStringAsFixed(1)}° بالنسبة للشمال",
                    style: TextStyle(fontSize: 16.sp, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Normalize heading to [0, 360)
        final double rawNorth = (heading + 360) % 360;
        final double smoothNorth = _getUnwrappedNorth(rawNorth);

        // Calculate angular difference between current heading and Qibla
        double difference = (widget.qiblaAngle - rawNorth).abs() % 360;
        if (difference > 180) {
          difference = 360 - difference;
        }

        // User is facing Qibla if within ±5 degrees
        final bool isFacingQibla = difference <= 5;
        _checkFacingFeedback(isFacingQibla);

        // Rotation angles in radians:
        // 1) Dial rotation keeps 'N' pointing to physical North
        final double targetDialAngle = -smoothNorth * (pi / 180);

        // 2) Red Arrow rotation dynamically points directly towards the Holy Kaaba in Makkah!
        final double targetQiblaArrowAngle =
            (widget.qiblaAngle - smoothNorth) * (pi / 180);

        final double compassSize = 310.w;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1) كارت الإحداثيات العلوي بتنسيق DMS كما في الصورة
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 22.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: const Color(0xFFD32F2F),
                        size: 22.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _formatDms(widget.latitude, widget.longitude),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brownPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 36.h),

                // 2) قرص البوصلة والسهم الأحمر المتفاعل مع الحركة
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: targetDialAngle),
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedDialAngle, child) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: targetQiblaArrowAngle),
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedQiblaAngle, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // أ) الإطار الخارجي ثلاثي الأبعاد مع الظلال
                            Container(
                              width: compassSize,
                              height: compassSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  colors: [
                                    Color(0xFFFFFFFF),
                                    Color(0xFFF2F4F7),
                                    Color(0xFFD8DDE3),
                                    Color(0xFFCCD2D9),
                                  ],
                                  stops: [0.82, 0.90, 0.96, 1.0],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isFacingQibla
                                        ? Colors.green.withValues(alpha: 0.28)
                                        : Colors.black.withValues(alpha: 0.12),
                                    blurRadius: isFacingQibla ? 32 : 24,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    blurRadius: 8,
                                    offset: const Offset(0, -3),
                                  ),
                                ],
                                border: Border.all(
                                  color: isFacingQibla
                                      ? Colors.green.withValues(alpha: 0.6)
                                      : const Color(0xFFD1D5DB),
                                  width: 2.w,
                                ),
                              ),
                            ),

                            // ب) قرص البوصلة الداخلي (يدور مع الشمال الحقيقي)
                            Transform.rotate(
                              angle: animatedDialAngle,
                              child: SizedBox(
                                width: compassSize * 0.92,
                                height: compassSize * 0.92,
                                child: CustomPaint(
                                  painter: RealisticCompassDialPainter(),
                                ),
                              ),
                            ),

                            // ج) السهم الأحمر الموجه للقبلة (يدور بسلاسة دائماً نحو مكة المكرمة)
                            Transform.rotate(
                              angle: animatedQiblaAngle,
                              child: SizedBox(
                                width: compassSize * 0.92,
                                height: compassSize * 0.92,
                                child: CustomPaint(
                                  painter: QiblaRedNeedlePainter(
                                    isFacingQibla: isFacingQibla,
                                  ),
                                ),
                              ),
                            ),

                            // د) مؤشر الكعبة المشرفة في المنتصف
                            _KaabaCenterEmblem(
                              size: compassSize * 0.22,
                              isFacingQibla: isFacingQibla,
                            ),

                            // هـ) مؤشر المحاذاة العلوي الثابت عند الساعة 12
                            Positioned(
                              top: 2.h,
                              child: _TopAlignmentGuide(
                                isFacingQibla: isFacingQibla,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 40.h),

                // 3) كارت الحالة السفلي بتصميم أنيق ومحكم
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: isFacingQibla
                        ? const Color(0xFFE8F5E9)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: isFacingQibla
                        ? Border.all(color: AppColors.successColor, width: 1.5)
                        : Border.all(color: const Color(0xFFEEEEEE), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFacingQibla
                            ? Icons.check_circle_rounded
                            : Icons.explore_rounded,
                        color: isFacingQibla
                            ? AppColors.successColor
                            : AppColors.goldenPrimary,
                        size: 22.sp,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        isFacingQibla
                            ? 'أنت باتجاه القبلة الآن (مكة المكرمة)'
                            : 'زاوية القبلة: ${widget.qiblaAngle.toStringAsFixed(0)}°  |  الاتجاه: ${rawNorth.toStringAsFixed(0)}°',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: isFacingQibla
                              ? AppColors.successColor
                              : AppColors.brownPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// مؤشر المحاذاة العلوي في أعلى البوصلة (عند الساعة 12)
class _TopAlignmentGuide extends StatelessWidget {
  final bool isFacingQibla;

  const _TopAlignmentGuide({required this.isFacingQibla});

  @override
  Widget build(BuildContext context) {
    if (isFacingQibla) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: AppColors.successColor,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.45),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 13.sp),
            SizedBox(width: 4.w),
            Text(
              "مكة المكرمة",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // علامة محاذاة رقيقة عند عدم المواجهة
    return Container(
      width: 4.w,
      height: 10.h,
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F),
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}

/// السهم الأحمر المتحرك ثلاثي الأبعاد الموجه دائماً نحو القبلة
class QiblaRedNeedlePainter extends CustomPainter {
  final bool isFacingQibla;

  QiblaRedNeedlePainter({required this.isFacingQibla});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);

    // ألوان السهم: يتحول لأخضر زاهي عند مواجهة القبلة، وأحمر مميز عند البحث
    final darkColor =
        isFacingQibla ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C);
    final lightColor =
        isFacingQibla ? const Color(0xFF4CAF50) : const Color(0xFFEF5350);

    // تأثير توهج خلف رأس السهم
    if (isFacingQibla) {
      final glowPaint = Paint()
        ..color = Colors.green.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset(0, -radius * 0.76), 20, glowPaint);
    }

    // 1) ساق الإبرة ثلاثية الأبعاد (Tapered Shaft)
    final double shaftStart = radius * 0.16;
    final double shaftEnd = radius * 0.64;

    // النصف الأيسر من الساق (أغمق)
    final leftShaft = Path()
      ..moveTo(-4, -shaftStart)
      ..lineTo(0, -shaftStart)
      ..lineTo(0, -shaftEnd)
      ..lineTo(-2, -shaftEnd)
      ..close();
    canvas.drawPath(leftShaft, Paint()..color = darkColor);

    // النصف الأيمن من الساق (أفتح)
    final rightShaft = Path()
      ..moveTo(0, -shaftStart)
      ..lineTo(4, -shaftStart)
      ..lineTo(2, -shaftEnd)
      ..lineTo(0, -shaftEnd)
      ..close();
    canvas.drawPath(rightShaft, Paint()..color = lightColor);

    // 2) رأس السهم الأحمر الحاد (Arrowhead) المتجه للقبلة
    final double tipY = -radius * 0.86; // الرأس الحاد
    final double baseLeftX = -15.0;
    final double baseRightX = 15.0;
    final double baseY = -radius * 0.62;
    final double notchY = -radius * 0.67;

    // النصف الأيسر من رأس السهم (مظلل)
    final leftHead = Path()
      ..moveTo(0, tipY)
      ..lineTo(baseLeftX, baseY)
      ..lineTo(0, notchY)
      ..close();
    canvas.drawPath(leftHead, Paint()..color = darkColor);

    // النصف الأيمن من رأس السهم (فاتح)
    final rightHead = Path()
      ..moveTo(0, tipY)
      ..lineTo(baseRightX, baseY)
      ..lineTo(0, notchY)
      ..close();
    canvas.drawPath(rightHead, Paint()..color = lightColor);

    // إطار دقيق محيط بالسهم
    final outlinePath = Path()
      ..moveTo(0, tipY)
      ..lineTo(baseLeftX, baseY)
      ..lineTo(0, notchY)
      ..lineTo(baseRightX, baseY)
      ..close();

    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(outlinePath, outlinePaint);

    // رسم علامة مكة / القبلة داخل رأس السهم
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, -radius * 0.75), 3, dotPaint);

    // 3) الثقل الموازن الخلفي (Counter-weight Tail)
    final double tailLen = radius * 0.22;
    final tailPath = Path()
      ..moveTo(0, 0)
      ..lineTo(-3, tailLen * 0.6)
      ..lineTo(0, tailLen)
      ..lineTo(3, tailLen * 0.6)
      ..close();
    canvas.drawPath(
      tailPath,
      Paint()..color = const Color(0xFF616161),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant QiblaRedNeedlePainter oldDelegate) {
    return oldDelegate.isFacingQibla != isFacingQibla;
  }
}

/// قرص البوصلة الكلاسيكي ثلاثي الأبعاد (الدرجات، النجمة الثمانية، والاتجاهات)
class RealisticCompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final dialRadius = radius - 4;

    // 1) خلفية القرص الدائري
    final dialPaint = Paint()
      ..color = const Color(0xFFFAF9F6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, dialRadius, dialPaint);

    // حافة القرص الداخلية
    final innerRimPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, dialRadius - 2, innerRimPaint);

    // 2) النجمة الثمانية (Compass Rose) بتظليل ثلاثي الأبعاد
    _drawCompassRoseStar(canvas, center, dialRadius);

    // 3) شرطات التدريج (Ticks) حول المحيط
    _drawTicks(canvas, center, dialRadius);

    // 4) أرقام الدرجات الدائرية (0, 15, 30 ... 345)
    _drawDegreeNumbers(canvas, center, dialRadius);

    // 5) علامات الاتجاهات (N, E, S, W و NE, SE, SW, NW)
    _drawDirections(canvas, center, dialRadius);
  }

  /// رسم النجمة الثمانية (Compass Rose) بالتظليل ثلاثي الأبعاد
  void _drawCompassRoseStar(Canvas canvas, Offset center, double dialRadius) {
    final double majorLen = dialRadius * 0.58;
    final double minorLen = dialRadius * 0.42;
    final double innerRadius = dialRadius * 0.18;

    final shadedPaint = Paint()
      ..color = AppColors.primaryLightColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final lightPaint = Paint()
      ..color = const Color(0xFFFFFDF9)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFFE2D6C5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < 8; i++) {
      final double rayAngle = (i * 45 - 90) * (pi / 180);
      final bool isMajor = (i % 2 == 0);
      final double rayLen = isMajor ? majorLen : minorLen;

      final double tipX = center.dx + rayLen * cos(rayAngle);
      final double tipY = center.dy + rayLen * sin(rayAngle);

      final double leftAngle = rayAngle - (22.5 * pi / 180);
      final double rightAngle = rayAngle + (22.5 * pi / 180);

      final double leftX = center.dx + innerRadius * cos(leftAngle);
      final double leftY = center.dy + innerRadius * sin(leftAngle);

      final double rightX = center.dx + innerRadius * cos(rightAngle);
      final double rightY = center.dy + innerRadius * sin(rightAngle);

      // النصف الأيسر (المظلل)
      final leftPath = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(leftX, leftY)
        ..lineTo(tipX, tipY)
        ..close();
      canvas.drawPath(leftPath, shadedPaint);
      canvas.drawPath(leftPath, borderPaint);

      // النصف الأيمن (الفاتح)
      final rightPath = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(tipX, tipY)
        ..lineTo(rightX, rightY)
        ..close();
      canvas.drawPath(rightPath, lightPaint);
      canvas.drawPath(rightPath, borderPaint);
    }
  }

  /// رسم شرطات التدريج (Ticks)
  void _drawTicks(Canvas canvas, Offset center, double dialRadius) {
    final majorTickPaint = Paint()
      ..color = const Color(0xFF8B6B47)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final medTickPaint = Paint()
      ..color = const Color(0xFFBDBDBD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final minorTickPaint = Paint()
      ..color = const Color(0xFFE2E4E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    for (int deg = 0; deg < 360; deg++) {
      final double rad = (deg - 90) * (pi / 180);

      double tickLen;
      Paint paintToUse;

      if (deg % 15 == 0) {
        tickLen = 7.0;
        paintToUse = majorTickPaint;
      } else if (deg % 5 == 0) {
        tickLen = 4.5;
        paintToUse = medTickPaint;
      } else {
        tickLen = 2.5;
        paintToUse = minorTickPaint;
      }

      final double outerX = center.dx + dialRadius * cos(rad);
      final double outerY = center.dy + dialRadius * sin(rad);
      final double innerX = center.dx + (dialRadius - tickLen) * cos(rad);
      final double innerY = center.dy + (dialRadius - tickLen) * sin(rad);

      canvas.drawLine(Offset(innerX, innerY), Offset(outerX, outerY), paintToUse);
    }
  }

  /// رسم أرقام الدرجات الموزعة دائرياً
  void _drawDegreeNumbers(Canvas canvas, Offset center, double dialRadius) {
    final double numRadius = dialRadius - 16;

    for (int deg = 0; deg < 360; deg += 15) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(deg * (pi / 180));

      final textSpan = TextSpan(
        text: '$deg',
        style: const TextStyle(
          color: Color(0xFF757575),
          fontSize: 8.5,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -numRadius - textPainter.height / 2),
      );

      canvas.restore();
    }
  }

  /// رسم الاتجاهات الأساسية (N, E, S, W) والفرعية (NE, SE, SW, NW)
  void _drawDirections(Canvas canvas, Offset center, double dialRadius) {
    // 1) علامة الشمال (N) على القرص
    final double nRadius = dialRadius * 0.70;
    _drawText(
      canvas,
      'N',
      Offset(center.dx, center.dy - nRadius),
      const TextStyle(
        color: Color(0xFFD32F2F),
        fontWeight: FontWeight.w900,
        fontSize: 16,
        fontFamily: 'Poppins',
      ),
    );

    // 2) الحروف الرئيسية: E, S, W
    final double cardinalRadius = dialRadius * 0.70;

    _drawText(
      canvas,
      'E',
      Offset(center.dx + cardinalRadius, center.dy),
      const TextStyle(
        color: AppColors.brownPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 15,
        fontFamily: 'Poppins',
      ),
    );

    _drawText(
      canvas,
      'S',
      Offset(center.dx, center.dy + cardinalRadius),
      const TextStyle(
        color: AppColors.brownPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 15,
        fontFamily: 'Poppins',
      ),
    );

    _drawText(
      canvas,
      'W',
      Offset(center.dx - cardinalRadius, center.dy),
      const TextStyle(
        color: AppColors.brownPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 15,
        fontFamily: 'Poppins',
      ),
    );

    // 3) الاتجاهات الفرعية (NE, SE, SW, NW)
    final double ordinalRadius = dialRadius * 0.68;
    final ordinalStyle = TextStyle(
      color: AppColors.brownSecondary.withValues(alpha: 0.5),
      fontWeight: FontWeight.w600,
      fontSize: 12,
      fontFamily: 'Poppins',
    );

    final ordinals = [
      {'text': 'NE', 'deg': 45},
      {'text': 'SE', 'deg': 135},
      {'text': 'SW', 'deg': 225},
      {'text': 'NW', 'deg': 315},
    ];

    for (final item in ordinals) {
      final double rad = ((item['deg'] as int) - 90) * (pi / 180);
      final Offset pos = Offset(
        center.dx + ordinalRadius * cos(rad),
        center.dy + ordinalRadius * sin(rad),
      );
      _drawText(canvas, item['text'] as String, pos, ordinalStyle);
    }
  }

  void _drawText(Canvas canvas, String text, Offset center, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// أيقونة الكعبة المشرفة في منتصف البوصلة
class _KaabaCenterEmblem extends StatelessWidget {
  final double size;
  final bool isFacingQibla;

  const _KaabaCenterEmblem({
    required this.size,
    required this.isFacingQibla,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F6),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isFacingQibla
              ? AppColors.successColor
              : AppColors.goldenPrimary.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.72,
          height: size * 0.72,
          child: CustomPaint(
            painter: _KaabaIconPainter(),
          ),
        ),
      ),
    );
  }
}

/// رسم مجسم الكعبة المشرفة بدقة هندسية عالية
class _KaabaIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1) جسم الكعبة الأسود الأساسي
    final cubePath = Path()
      ..moveTo(w * 0.20, h * 0.12)
      ..lineTo(w * 0.80, h * 0.12)
      ..lineTo(w * 0.92, h * 0.76)
      ..lineTo(w * 0.50, h * 0.92)
      ..lineTo(w * 0.08, h * 0.76)
      ..close();

    final bodyPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;
    canvas.drawPath(cubePath, bodyPaint);

    // 2) الحزام الذهبي العلوي (كسوة الكعبة)
    final goldBandPath = Path()
      ..moveTo(w * 0.16, h * 0.28)
      ..lineTo(w * 0.84, h * 0.28)
      ..lineTo(w * 0.86, h * 0.40)
      ..lineTo(w * 0.50, h * 0.46)
      ..lineTo(w * 0.14, h * 0.40)
      ..close();

    final goldPaint = Paint()
      ..color = AppColors.goldenPrimary
      ..style = PaintingStyle.fill;
    canvas.drawPath(goldBandPath, goldPaint);

    // تفاصيل ذهبية إضافية داخل الحزام
    final goldLinePaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(w * 0.15, h * 0.34),
      Offset(w * 0.85, h * 0.34),
      goldLinePaint,
    );

    // 3) الزخرفة البيضاء للستارة أسفل الحزام
    final drapePath = Path();
    drapePath.moveTo(w * 0.15, h * 0.42);

    const int spikes = 5;
    final double step = (w * 0.70) / spikes;
    for (int i = 0; i < spikes; i++) {
      final double sx = w * 0.15 + i * step;
      drapePath.lineTo(sx + step / 2, h * 0.58);
      drapePath.lineTo(sx + step, h * 0.42);
    }

    final drapePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(drapePath, drapePaint);

    // 4) قاعدة الشاذروان الرخامية البيضاء
    final basePaint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(w * 0.08, h * 0.76),
      Offset(w * 0.50, h * 0.92),
      basePaint,
    );
    canvas.drawLine(
      Offset(w * 0.50, h * 0.92),
      Offset(w * 0.92, h * 0.76),
      basePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
