import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/features/quran/presentation/cubit/audio_cubit.dart';
import '../theme/light_theme.dart';
import '../theme/dark_theme.dart';
import '../theme/app_scroll_behavior.dart';
import '../theme/cubit/theme_cubit.dart';
import '../theme/cubit/theme_state.dart';
import '../routes/app_router.dart';
import '../routes/app_routes.dart';
import '../utils/service_locator.dart';
import '../initialization/app_initializer.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/prayer_times/presentation/cubit/prayer_cubit.dart';
import '../../features/qibla/data/repositories/qibla_repo.dart';
import '../../features/qibla/presentation/cubit/qibla_cubit.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import 'app_error_widget.dart';

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;

  const MyApp({
    super.key,
    this.initialThemeMode = ThemeMode.light,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Lazy-loaded instances
  AuthCubit? _authCubit;
  AppRouter? _appRouter;
  bool _isReady = false;
  String? _initError;

  bool get _canShowApp => _isReady;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialize app services after widget is mounted
  Future<void> _initializeApp() async {
    // 1. Wait for AppInitializer (Notifications, Firebase, etc.)
    // 🛡️ TIMEOUT SAFEGUARD: Don't wait more than 7 seconds on splash
    try {
      await AppInitializer.initialize().timeout(const Duration(seconds: 7));
    } catch (e) {
      debugPrint('⚠️ [MyApp] Init timed out or failed: $e');
    }

    // 2. Initialize UI dependencies (Router, Cubits)
    if (mounted) {
      try {
        _authCubit = getIt<AuthCubit>();
        // Check auth status from cache before building router
        await _authCubit!.checkAuthStatus();
        _appRouter = AppRouter(_authCubit!, initialLocation: AppRoutes.splash);
        if (mounted) {
          setState(() {
            _isReady = true; // App is now ready to switch to Router
          });
        }
      } catch (e) {
        debugPrint('❌ [MyApp] Critical UI Dep Failure: $e');
        if (mounted) {
          setState(() {
            _initError = e.toString();
            _isReady = false; // Not ready
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _authCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔴 ERROR STATE: Show Fatal Error Screen
    if (_initError != null) {
      return AppErrorWidget(
        message: _initError!,
        onRetry: () {
          setState(() {
            _initError = null;
            _isReady = false;
          });
          _initializeApp();
        },
      );
    }

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        // 🟢 LOADING STATE: Clean themed placeholder while dependencies prepare
        if (!_canShowApp) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: widget.initialThemeMode,
            scrollBehavior: const AppScrollBehavior(),
            home: Scaffold(
              backgroundColor: widget.initialThemeMode == ThemeMode.dark
                  ? const Color(0xFF1E2125)
                  : const Color(0xFFFAF5ED),
            ),
          );
        }

        // 🟢 READY STATE: Show Full App with Router (Starting at the single SplashScreen)
        return _buildFullApp(context);
      },
    );
  }

  Widget _buildFullApp(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AudioCubit>()),
        BlocProvider(
          create: (context) =>
              ThemeCubit(initialTheme: widget.initialThemeMode),
        ),
        BlocProvider(create: (context) => QiblaCubit(QiblaRepository())),
        BlocProvider.value(value: _authCubit!),
        BlocProvider(
          create: (context) => getIt<PrayerCubit>()..loadPrayerTimes(),
        ),
        BlocProvider(
          create: (context) => getIt<SettingsCubit>()..loadSettings(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'app_name'.tr(),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeState.themeMode,
            routerConfig: _appRouter!.router,
            scrollBehavior: const AppScrollBehavior(),
          );
        },
      ),
    );
  }
}
