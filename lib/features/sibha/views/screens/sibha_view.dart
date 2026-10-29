import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/utils/service_locator.dart';

import '../../bussiness_logic/sibha_cubit/sibha_cubit.dart';
import '../../bussiness_logic/sibha_cubit/sibha_state.dart';
import '../widgets/bead_string_painter.dart';
import '../widgets/bead_widget.dart';
import '../widgets/counter_selector_bottom_sheet.dart';
import '../widgets/dhikr_selector_bottom_sheet.dart';
import '../widgets/rounds_selector_bottom_sheet.dart';
import '../widgets/sibha_bottom_buttons.dart';
import '../widgets/sibha_counter_display.dart';

class SibhaView extends StatefulWidget {
  const SibhaView({super.key});

  @override
  State<SibhaView> createState() => _SibhaViewState();
}

class _SibhaViewState extends State<SibhaView> with TickerProviderStateMixin {
  static const double _arcRadius = 350.0;
  static const double _arcCenterOffset = 250.0;
  static const double _beadRadius = 25.0;

  int _totalBeads = 33;
  int _currentCount = 1;
  int _currentRound = 1;
  int _maxRounds = 3;
  bool _showPlusOne = false;
  int _currentDhikrIndex = 0;

  late final PageController _pageController;
  late AnimationController _beadAnimationController;
  late Animation<double> _beadAnimation;
  late AnimationController _plusOneAnimationController;
  late Animation<double> _plusOneAnimation;
  late final SibhaCubit _sibhaCubit;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _sibhaCubit = getIt<SibhaCubit>()..getSibhaData();

    _beadAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _beadAnimation = CurvedAnimation(
      parent: _beadAnimationController,
      curve: Curves.easeInOut,
    );

    _plusOneAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _plusOneAnimation = CurvedAnimation(
      parent: _plusOneAnimationController,
      curve: Curves.easeOut,
    );

    _plusOneAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showPlusOne = false;
        });
        _plusOneAnimationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _beadAnimationController.dispose();
    _plusOneAnimationController.dispose();
    _sibhaCubit.close();
    super.dispose();
  }

  void _showCounterSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CounterSelectorBottomSheet(
        currentValue: _totalBeads,
        onApply: (value) {
          setState(() {
            _totalBeads = value;
            _currentCount = 1;
            _currentRound = 1;
          });
        },
      ),
    );
  }

  void _showRoundsSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => RoundsSelectorBottomSheet(
        currentValue: _maxRounds,
        onApply: (value) {
          setState(() {
            _maxRounds = value;
          });
        },
      ),
    );
  }

  void _incrementCounter() {
    HapticFeedback.lightImpact();

    setState(() {
      _beadAnimationController.forward(from: 0);
      _showPlusOne = true;
      _plusOneAnimationController.forward(from: 0);

      if (_currentCount < _totalBeads) {
        _currentCount++;
        // Check if this tap completes the entire goal on the last bead of the last round!
        if (_currentCount == _totalBeads && _currentRound >= _maxRounds) {
          HapticFeedback.heavyImpact();
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _showGoalCompletedDialog();
          });
        }
      } else {
        HapticFeedback.mediumImpact();
        _currentCount = 1;
        _currentRound++;
      }
    });
  }

  void _showGoalCompletedDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final totalCount = _maxRounds * _totalBeads;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
              width: 1.2,
            ),
          ),
          elevation: 10,
          backgroundColor: isDark ? const Color(0xFF282C32) : const Color(0xFFFAF5ED),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.goldenGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldenPrimary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'ما شاء الله! 🎉',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.brownPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'تم إتمام ورد التسبيح بنجاح',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.goldenPrimary : AppColors.brownSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'أنجزت $_maxRounds دورات بإجمالي $totalCount تسبيحة\nتقبّل الله طاعتكم 🌿',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: isDark ? Colors.white70 : AppColors.brownSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _currentCount = 1;
                            _currentRound++;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: const BorderSide(color: AppColors.goldenPrimary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'متابعة',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldenPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.goldenGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.goldenPrimary.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _resetCounter();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'من جديد',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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

  void _resetCounter() {
    setState(() {
      _currentCount = 1;
      _currentRound = 1;
      _showPlusOne = false;
    });
    _beadAnimationController.reset();
    _plusOneAnimationController.reset();
  }

  Path _createCurvedPath(Size size) {
    return Path()
      ..addArc(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2 + _arcCenterOffset),
          radius: _arcRadius,
        ),
        -2.8,
        2.0,
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E2125) : const Color(0xFFFAF5ED),
      body: GestureDetector(
        onTap: _incrementCounter,
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            _incrementCounter();
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _SibhaBackgroundPainter(isDark: isDark),
              ),
            ),

            // Counter Display at Top Left
            SibhaCounterDisplay(
              currentCount: _currentCount,
              totalBeads: _totalBeads,
              currentRound: _currentRound,
              maxRounds: _maxRounds,
            ),

            // Back Button (Points correctly towards previous screen with app theme)
            Positioned(
              top: 50,
              right: 20,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF282C32)
                          : AppColors.containerColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF383E46)
                            : const Color(0xFFEADBCE),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDark
                          ? Colors.white
                          : AppColors.brownPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

            // 1. زر اختيار الذكر والتسبيح
            Positioned(
              left: 20,
              right: 20,
              top: 145,
              child: Center(
                child: BlocBuilder<SibhaCubit, SibhaState>(
                  bloc: _sibhaCubit,
                  builder: (context, state) {
                    if (state is! SibhaLoaded) return const SizedBox.shrink();

                    return InkWell(
                      onTap: () {
                        DhikrSelectorBottomSheet.show(
                          context,
                          items: state.sibhas,
                          selectedIndex: _currentDhikrIndex,
                          onSelect: (index) {
                            setState(() {
                              _currentDhikrIndex = index;
                              _currentCount = 1;
                              _currentRound = 1;
                            });
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                            );
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF282C32)
                              : const Color(0xFFFCFAF7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF383E46)
                                : const Color(0xFFEADBCE),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: isDark ? 0.3 : 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 16,
                              color: AppColors.goldenPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'اختيار الذكر والتسبيح',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF143427),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF8C7A6B),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 2. حاوية نص الذكر التفاعلية مع أسهم التنقل
            Positioned(
              left: 12,
              right: 12,
              top: 200,
              child: SizedBox(
                height: 200,
                child: BlocBuilder<SibhaCubit, SibhaState>(
                  bloc: _sibhaCubit,
                  builder: (context, state) {
                    if (state is SibhaLoaded) {
                      return Directionality(
                        textDirection: TextDirection.ltr,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              scrollDirection: Axis.horizontal,
                              itemCount: state.sibhas.length,
                              physics: const BouncingScrollPhysics(),
                              onPageChanged: (index) {
                                setState(() {
                                  _currentDhikrIndex = index;
                                  _currentCount = 1;
                                  _currentRound = 1;
                                });
                              },
                              itemBuilder: (context, index) {
                                final item = state.sibhas[index];
                                final isLong = item.nameAr.length > 25;
                                final isMedium = item.nameAr.length > 15;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: SingleChildScrollView(
                                    physics: const NeverScrollableScrollPhysics(),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.nameAr,
                                          textAlign: TextAlign.center,
                                          textDirection: TextDirection.rtl,
                                          style: TextStyle(
                                            color: isDark
                                                ? const Color(0xFFFFF7E6)
                                                : AppColors.brownPrimary,
                                            fontSize: isLong
                                                ? 26
                                                : (isMedium ? 32 : 44),
                                            height: 1.25,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'amiri',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item.nameEn,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.goldenPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.meaningEn,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white70
                                                : AppColors.brownSecondary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            // سهم التنقل للذكر التالي (اليمين >)
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: Icon(
                                  Icons.chevron_right_rounded,
                                  color: isDark
                                      ? Colors.white54
                                      : const Color(0xFF8C7A6B),
                                  size: 30,
                                ),
                                onPressed: () {
                                  final next =
                                      (_currentDhikrIndex + 1) % state.sibhas.length;
                                  _pageController.animateToPage(
                                    next,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                            ),

                            // سهم التنقل للذكر السابق (اليسار <)
                            Positioned(
                              left: 0,
                              child: IconButton(
                                icon: Icon(
                                  Icons.chevron_left_rounded,
                                  color: isDark
                                      ? Colors.white54
                                      : const Color(0xFF8C7A6B),
                                  size: 30,
                                ),
                                onPressed: () {
                                  final prev = (_currentDhikrIndex -
                                          1 +
                                          state.sibhas.length) %
                                      state.sibhas.length;
                                  _pageController.animateToPage(
                                    prev,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is SibhaError) {
                      return const SizedBox.shrink();
                    }

                    return const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Tasbih Beads in Center - Curved Golden String with Gap
            Positioned(
              left: 16,
              right: 16,
              top: 400,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 400,
                child: Stack(
                  children: [
                    // Draw the golden cord/string path
                    CustomPaint(
                      size: Size(MediaQuery.of(context).size.width, 400),
                      painter: BeadStringPainter(
                        currentCount: _currentCount,
                        isDark: isDark,
                      ),
                    ),
                    // Draw beads with animation
                    ...List.generate(
                        6, (index) => _buildBead(_currentCount - 1 - index, isDark)),
                  ],
                ),
              ),
            ),

            // "+1" indicator that appears when tapping
            if (_showPlusOne)
              Positioned(
                top: MediaQuery.of(context).size.height / 2 - 50,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _plusOneAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -30 * _plusOneAnimation.value),
                      child: Opacity(
                        opacity: 1.0 - _plusOneAnimation.value,
                        child: Center(
                          child: Text(
                            '+1',
                            style: TextStyle(
                              color: AppColors.goldenPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: AppColors.brownPrimary.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Bottom buttons
            SibhaBottomButtons(
              maxRounds: _maxRounds,
              totalBeads: _totalBeads,
              onRoundsTap: _showRoundsSelector,
              onResetTap: _resetCounter,
              onCounterTap: _showCounterSelector,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBead(int index, bool isDark) {
    final size = Size(MediaQuery.of(context).size.width, 400);

    final path = _createCurvedPath(size);
    final pathMetrics = path.computeMetrics().toList();

    if (pathMetrics.isEmpty) {
      return const SizedBox.shrink();
    }

    final metric = pathMetrics.first;
    final totalLength = metric.length;

    final beadAge = _currentCount - 1 - index;
    if (beadAge < -1 || beadAge > 4) return const SizedBox.shrink();

    final isNewBead = beadAge == -1;
    final isMovingToRight = beadAge == 0;
    final isFadingOut = beadAge == 4;

    Offset getPositionForSlot(int slot) {
      final position = slot == -1
          ? 0.05
          : slot == 0
              ? 0.15
              : 0.65 + (slot - 1) * 0.075;
      final tangent = metric.getTangentForOffset(totalLength * position);
      return tangent?.position ?? Offset.zero;
    }

    final currentSlot = beadAge;
    final nextSlot = beadAge + 1;
    final currentPos = getPositionForSlot(currentSlot);

    return AnimatedBuilder(
      animation: _beadAnimation,
      builder: (context, child) {
        final animationValue = _beadAnimation.value;

        Offset position;
        if (beadAge >= -1 && beadAge <= 3) {
          final fromPos = currentSlot == -1
              ? 0.05
              : currentSlot == 0
                  ? 0.15
                  : 0.65 + (currentSlot - 1) * 0.075;
          final toPos = nextSlot == -1
              ? 0.05
              : nextSlot == 0
                  ? 0.15
                  : 0.65 + (nextSlot - 1) * 0.075;
          final pathPosition = fromPos + (toPos - fromPos) * animationValue;
          final tangent =
              metric.getTangentForOffset(totalLength * pathPosition);
          position = tangent?.position ?? currentPos;
        } else {
          position = currentPos;
        }

        final opacity = isFadingOut
            ? 1.0 - animationValue
            : isNewBead
                ? animationValue
                : 1.0;

        return Positioned(
          left: position.dx - _beadRadius,
          top: position.dy - _beadRadius,
          child: BeadWidget(
            opacity: opacity,
            scale: isMovingToRight ? 1.0 + (animationValue * 0.15) : 1.0,
            isDark: isDark,
          ),
        );
      },
    );
  }
}

class _SibhaBackgroundPainter extends CustomPainter {
  final bool isDark;

  _SibhaBackgroundPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? const [
                Color(0xFF282C32),
                Color(0xFF1E2125),
                Color(0xFF181A1D),
              ]
            : const [
                Color(0xFFFFFDF8),
                Color(0xFFFAF5ED),
                Color(0xFFF3E3CF),
              ],
      ).createShader(rect);
    canvas.drawRect(rect, gradientPaint);

    // Warm Islamic golden illumination glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, 0.2),
        radius: 0.85,
        colors: [
          AppColors.goldenPrimary.withValues(alpha: isDark ? 0.07 : 0.06),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _SibhaBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
