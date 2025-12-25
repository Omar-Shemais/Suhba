import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/features/quran/presentation/cubit/audio_cubit.dart';
import '../theme/light_theme.dart';
import '../theme/dark_theme.dart';
import '../theme/cubit/theme_cubit.dart';
import '../theme/cubit/theme_state.dart';
import '../routes/app_router.dart';
import '../utils/service_locator.dart';
import '../initialization/app_initializer.dart';
import '../../features/app/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/prayer_times/presentation/cubit/prayer_cubit.dart';
import '../../features/qibla/data/repositories/qibla_repo.dart';
import '../../features/qibla/presentation/cubit/qibla_cubit.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import 'app_error_widget.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Lazy-loaded instances
  AuthCubit? _authCubit;
  AppRouter? _appRouter;
  bool _isReady = false;
  String? _initError;

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
      // If it's a timeout, we might chance it. If it's a critical crash, we might want to show error.
      // But Phase 2 (DI) is critical. If AppInitializer didn't finish, we assume it might be bad.
    }

    // 2. Initialize UI dependencies (Router, Cubits)
    if (mounted) {
      setState(() {
        // Wrap in try-catch in case GetIt failed completely
        try {
          _authCubit = getIt<AuthCubit>();
          _appRouter = AppRouter(_authCubit!);
          _isReady = true; // App is now ready to switch to Router
        } catch (e) {
          debugPrint('❌ [MyApp] Critical UI Dep Failure: $e');
          // Capture the error to show in UI
          _initError = e.toString();
          _isReady = false; // Not ready
        }
      });

      // Check auth status if we are ready
      if (_isReady) {
        _authCubit?.checkAuthStatus();
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
    // 🟢 LOADING STATE: Show Splash WITHOUT Navigation
    if (!_isReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: const SplashScreen(
          shouldNavigate: false,
        ), // Keeps app alive while loading
      );
    }

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

    // 🟢 READY STATE: Show Full App with Router
    return _buildFullApp(context);
  }

  Widget _buildFullApp(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AudioCubit>()),
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => QiblaCubit(QiblaRepository())),
        BlocProvider.value(value: _authCubit!),
        BlocProvider(
          create: (context) => getIt<PrayerCubit>()..loadPrayerTimes(),
        ),
        BlocProvider(
          create: (context) => getIt<SettingsCubit>()..loadSettings(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, ThemeState>(
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
              );
            },
          );
        },
      ),
    );
  }
}
