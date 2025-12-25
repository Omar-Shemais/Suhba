import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/assets.dart';
import 'package:islamic_app/core/routes/app_routes.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final bool shouldNavigate; // 🟢 Added flag

  const SplashScreen({
    super.key,
    this.shouldNavigate = true, // Default to true (normal behavior)
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    // 🟢 Only navigate if allowed
    if (widget.shouldNavigate) {
      _navigateToNextScreen();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait only for animation to complete
    await _animationController.forward();

    if (!mounted) return;

    // 🟢 Safety check: Try-Catch prevents crashes if Router is missing
    try {
      context.go(AppRoutes.home);
    } catch (e) {
      debugPrint("ℹ️ [SplashScreen] Navigation skipped (Router not ready yet).");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = context.locale.languageCode == "ar";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? null
              : const BoxDecoration(
                  gradient: AppColors.backgroundGradient,
                ).gradient,
          color: isDark ? theme.scaffoldBackgroundColor : null,
        ),
        child: Stack(
          children: [
            // Islamic Pattern Background - Top Right
            Positioned(
              top: -100,
              right: -100,
              child: Opacity(
                opacity: isDark ? 0.03 : 0.05,
                child: Icon(
                  Icons.mosque,
                  size: 300,
                  color: isDark
                      ? theme.colorScheme.onSurface
                      : AppColors.goldenPrimary,
                ),
              ),
            ),
            // Islamic Pattern Background - Bottom Left
            Positioned(
              bottom: -80,
              left: -80,
              child: Opacity(
                opacity: isDark ? 0.03 : 0.05,
                child: Icon(
                  Icons.mosque,
                  size: 250,
                  color: isDark
                      ? theme.colorScheme.onSurface
                      : AppColors.goldenSecondary,
                ),
              ),
            ),

            // Main Content
            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo with Glow Effect
                          Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.goldenPrimary.withValues(alpha: .2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isDark
                                    ? AppColors.goldenGradient
                                    : AppColors.secanderyGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? AppColors.goldenPrimary.withValues(
                                            alpha: .5,
                                          )
                                        : AppColors.secondaryColor.withValues(
                                            alpha: .5,
                                          ),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Image(
                                image: AssetImage(AssetsData.logo),
                                width: 100,
                                height: 100,
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // App Name
                          Text(
                            'app_name'.tr(),
                            style: TextStyle(
                              fontSize: 36,
                              fontFamily: isArabic ? 'Amiri' : 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: 1.2,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Subtitle
                          Text(
                            'app_subtitle'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: isArabic ? 'Amiri' : 'Poppins',
                              color: theme.colorScheme.onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 50),

                          // Loading Indicator
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.goldenPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}