// ============================================================================
// APP WIDGET - Main application widget
// ============================================================================
// This is the root widget of the application.
// It manages the app state, initialization, and provides the router.
// ============================================================================

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

/// Root application widget
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

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialize app services after widget is mounted
  /// This happens AFTER the first frame is rendered
  Future<void> _initializeApp() async {
    // Wait for deferred initialization to complete
    await AppInitializer.initialize();

    // Now it's safe to access GetIt services
    if (mounted) {
      setState(() {
        _authCubit = getIt<AuthCubit>();
        _appRouter = AppRouter(_authCubit!);
        _isReady = true;
      });

      // Check auth status AFTER UI is ready (non-blocking)
      _authCubit?.checkAuthStatus();
    }
  }

  @override
  void dispose() {
    _authCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen immediately while initializing in background
    if (!_isReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: const SplashScreen(),
      );
    }

    // Full app: Services are ready, router will navigate from splash to home
    return _buildFullApp(context);
  }

  /// Build full app with all features
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
