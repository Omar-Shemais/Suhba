import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/assets.dart';
import 'package:islamic_app/core/routes/app_routes.dart';
import '../widgets/golden_particles_painter.dart';

class SplashScreen extends StatefulWidget {
  final bool shouldNavigate;
  final VoidCallback? onAnimationComplete;

  const SplashScreen({
    super.key,
    this.shouldNavigate = true,
    this.onAnimationComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Coordinated Motion Controllers
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late AnimationController _particlesController;
  late AnimationController _indicatorController;

  // Background animation
  late Animation<double> _bgFadeAnimation;

  // Medallion animations
  late Animation<double> _medallionFadeAnimation;
  late Animation<double> _medallionScaleAnimation;
  late Animation<double> _pulseAnimation;

  // Tagline & Verse animations
  late Animation<double> _taglineFadeAnimation;
  late Animation<Offset> _taglineSlideAnimation;
  late Animation<double> _verseFadeAnimation;
  late Animation<Offset> _verseSlideAnimation;

  // Loading indicator animation
  late Animation<double> _indicatorFadeAnimation;
  late Animation<double> _indicatorRotation;

  // 16 procedurally seeded golden particles floating gently in the atmosphere
  static const List<GoldenParticle> _particles = [
    GoldenParticle(x: 0.12, y: 0.82, size: 2.2, speed: 0.40, maxOpacity: 0.50, swayPhase: 0.4, swaySpeed: 1.2),
    GoldenParticle(x: 0.22, y: 0.68, size: 1.6, speed: 0.32, maxOpacity: 0.42, swayPhase: 1.8, swaySpeed: 1.5),
    GoldenParticle(x: 0.35, y: 0.90, size: 2.8, speed: 0.48, maxOpacity: 0.58, swayPhase: 2.9, swaySpeed: 1.1),
    GoldenParticle(x: 0.48, y: 0.62, size: 1.8, speed: 0.38, maxOpacity: 0.48, swayPhase: 0.7, swaySpeed: 1.4),
    GoldenParticle(x: 0.62, y: 0.78, size: 2.4, speed: 0.45, maxOpacity: 0.55, swayPhase: 3.2, swaySpeed: 1.3),
    GoldenParticle(x: 0.74, y: 0.72, size: 1.5, speed: 0.35, maxOpacity: 0.40, swayPhase: 1.1, swaySpeed: 1.6),
    GoldenParticle(x: 0.86, y: 0.85, size: 2.6, speed: 0.50, maxOpacity: 0.60, swayPhase: 2.4, swaySpeed: 1.0),
    GoldenParticle(x: 0.18, y: 0.38, size: 2.0, speed: 0.40, maxOpacity: 0.45, swayPhase: 4.1, swaySpeed: 1.4),
    GoldenParticle(x: 0.28, y: 0.52, size: 1.4, speed: 0.34, maxOpacity: 0.38, swayPhase: 0.9, swaySpeed: 1.7),
    GoldenParticle(x: 0.55, y: 0.42, size: 2.2, speed: 0.42, maxOpacity: 0.50, swayPhase: 2.7, swaySpeed: 1.2),
    GoldenParticle(x: 0.70, y: 0.32, size: 1.7, speed: 0.38, maxOpacity: 0.42, swayPhase: 3.6, swaySpeed: 1.5),
    GoldenParticle(x: 0.82, y: 0.48, size: 2.5, speed: 0.44, maxOpacity: 0.52, swayPhase: 1.5, swaySpeed: 1.1),
    GoldenParticle(x: 0.40, y: 0.28, size: 1.9, speed: 0.36, maxOpacity: 0.44, swayPhase: 4.8, swaySpeed: 1.3),
    GoldenParticle(x: 0.65, y: 0.22, size: 2.1, speed: 0.40, maxOpacity: 0.48, swayPhase: 0.5, swaySpeed: 1.6),
    GoldenParticle(x: 0.15, y: 0.18, size: 1.6, speed: 0.32, maxOpacity: 0.36, swayPhase: 2.1, swaySpeed: 1.4),
    GoldenParticle(x: 0.88, y: 0.20, size: 2.0, speed: 0.38, maxOpacity: 0.44, swayPhase: 3.9, swaySpeed: 1.2),
  ];

  @override
  void initState() {
    super.initState();

    // Enable edge-to-edge system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // 1. Entrance timeline controller (1800ms)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // 2. Medallion golden breathing aura (2400ms looping)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // 3. Floating particles controller (4000ms looping)
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    // 4. Dual-color loading indicator rotation (1600ms looping)
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _initAnimations();

    _entranceController.forward();

    if (widget.shouldNavigate) {
      _navigateToNextScreen();
    }
  }

  void _initAnimations() {
    // Background fade (0.0 .. 0.40)
    _bgFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOut),
      ),
    );

    // Medallion entrance: scale 0.85 -> 1.0 with subtle overshoot
    _medallionFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.12, 0.55, curve: Curves.easeOut),
      ),
    );

    _medallionScaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.12, 0.65, curve: Curves.easeOutBack),
      ),
    );

    // Continuous breathing aura pulse
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Tagline (0.45 .. 0.75)
    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 0.75, curve: Curves.easeIn),
      ),
    );

    _taglineSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // Verse Card (0.60 .. 0.90)
    _verseFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.60, 0.90, curve: Curves.easeIn),
      ),
    );

    _verseSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.60, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    // Loading Indicator (0.75 .. 1.0)
    _indicatorFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );

    _indicatorRotation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _indicatorController,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _particlesController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    // Respect accessibility reduced-motion preference
    final disableAnimations =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    final waitDuration = disableAnimations
        ? const Duration(milliseconds: 500)
        : const Duration(milliseconds: 3000);

    await Future.delayed(waitDuration);

    if (!mounted) return;

    widget.onAnimationComplete?.call();

    try {
      context.go(AppRoutes.home);
    } catch (e) {
      debugPrint("ℹ️ [SplashScreen] Navigation skipped: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Strict Islamic Palette Tokens - Splash screen consistently uses the light ivory aesthetic
    const ivoryBg = Color(0xFFFAF5ED);
    const bgColor = ivoryBg;

    // System bars styling: transparent with contrast enforcement disabled for true edge-to-edge
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
    );

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Semantics(
        label: 'صحبة - رفيقك في رحلتك الروحية - واذكر ربك في نفسك تضرعا وخيفة',
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.fill,
            alignment: Alignment.center,
            child: SizedBox(
              width: 1080,
              height: 2284,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                        // 1. خلفية المساجد والكثبان الرملية والضباب والشروق وأغصان الزيتون (المكون الأصلي الصافي)
                        AnimatedBuilder(
                          animation: _bgFadeAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _bgFadeAnimation.value,
                              child: Image.asset(
                                AssetsData.splashBgClean,
                                width: 1080,
                                height: 2284,
                                fit: BoxFit.fill,
                              ),
                            );
                          },
                        ),


                        // 3. ذرات النور والبركة الذهبية العائمة برفق في الأجواء
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _particlesController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: GoldenParticlesPainter(
                                  progress: _particlesController.value,
                                  goldColor: const Color(0xFFC5A45D),
                                  particles: _particles,
                                ),
                              );
                            },
                          ),
                        ),

                        // 4. هالة ذهبية نورانية تتنفس بنعومة حول الميدالية الدائرية المركزية
                        // مركز الميدالية هندسياً: x = 540, y = 1093.5
                        Positioned(
                          left: 540 - 350,
                          top: 1093.5 - 350,
                          width: 700,
                          height: 700,
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: _MedallionAuraPainter(
                                  intensity: _pulseAnimation.value,
                                ),
                              );
                            },
                          ),
                        ),

                        // 5. مكون الميدالية الذهبية الوحيد والأصلي مع الشعار (The Single Medallion Component)
                        // يدخل بأنيميشن تكبير فخم 0.85 -> 1.0 وظهور ناعم
                        Positioned(
                          left: 540 - (660 / 2),
                          top: 1093.5 - (661 / 2),
                          width: 660,
                          height: 661,
                          child: AnimatedBuilder(
                            animation: _entranceController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _medallionScaleAnimation.value,
                                child: Opacity(
                                  opacity: _medallionFadeAnimation.value,
                                  child: Hero(
                                    tag: 'app_logo',
                                    child: Image.asset(
                                      AssetsData.splashMedallion,
                                      width: 660,
                                      height: 661,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // 6. مكون شعار التطبيق النصي "رفيقك في رحلتك الروحية" والزهرة الفاصلة
                        Positioned(
                          left: 540 - (484 / 2),
                          top: 1470,
                          width: 484,
                          height: 140,
                          child: AnimatedBuilder(
                            animation: _entranceController,
                            builder: (context, child) {
                              return SlideTransition(
                                position: _taglineSlideAnimation,
                                child: Opacity(
                                  opacity: _taglineFadeAnimation.value,
                                  child: Image.asset(
                                    AssetsData.splashTagline,
                                    width: 484,
                                    height: 140,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // 7. مكون بطاقة الآية القرآنية الكريمة سورة الأعراف 205
                        Positioned(
                          left: 540 - (907 / 2),
                          top: 1730,
                          width: 907,
                          height: 247,
                          child: AnimatedBuilder(
                            animation: _entranceController,
                            builder: (context, child) {
                              return SlideTransition(
                                position: _verseSlideAnimation,
                                child: Opacity(
                                  opacity: _verseFadeAnimation.value,
                                  child: Image.asset(
                                    AssetsData.splashVerseCard,
                                    width: 907,
                                    height: 247,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // 8. مؤشر التحميل الدائري الثنائي الألوان يدور بسلاسة في موضعه الدقيق
                        Positioned(
                          left: 540 - 36,
                          top: 2063 - 36,
                          width: 72,
                          height: 72,
                          child: AnimatedBuilder(
                            animation: _entranceController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _indicatorFadeAnimation.value,
                                child: AnimatedBuilder(
                                  animation: _indicatorRotation,
                                  builder: (context, child) {
                                    return CustomPaint(
                                      painter: _DualColorRingPainter(
                                        rotation: _indicatorRotation.value,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}

/// هالة نورانية ذهبية تتنفس برقة حول الميدالية الدائرية المركزية
class _MedallionAuraPainter extends CustomPainter {
  final double intensity;

  _MedallionAuraPainter({required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFC5A45D).withValues(alpha: 0.22 * intensity.clamp(0.0, 1.0)),
          const Color(0xFFE8D49E).withValues(alpha: 0.09 * intensity.clamp(0.0, 1.0)),
          const Color(0xFFFAF5ED).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

    canvas.drawCircle(center, maxRadius, paint);
  }

  @override
  bool shouldRepaint(covariant _MedallionAuraPainter oldDelegate) {
    return oldDelegate.intensity != intensity;
  }
}

/// مؤشر دائري ثنائي الألوان (أخضر غابي + ذهب عتيق) يدور بسلاسة متناغمة
class _DualColorRingPainter extends CustomPainter {
  final double rotation;

  _DualColorRingPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 6.0) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final greenPaint = Paint()
      ..color = const Color(0xFF064B3B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final goldPaint = Paint()
      ..color = const Color(0xFFC5A45D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    // نصف القوس بالأخضر الغابي العميق
    canvas.drawArc(rect, rotation, math.pi * 0.90, false, greenPaint);
    // النصف الآخر بالذهب العتيق
    canvas.drawArc(rect, rotation + math.pi, math.pi * 0.90, false, goldPaint);
  }

  @override
  bool shouldRepaint(covariant _DualColorRingPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}