import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islamic_app/features/hadith/presentation/pages/hadith_screen.dart';
import 'package:islamic_app/features/hadith/presentation/pages/hadith_search_screen.dart';
import 'package:islamic_app/features/azkar/presentation/pages/azkar_screen.dart';
import 'package:islamic_app/features/qibla/presentation/pages/qibla_screen.dart';
import 'package:islamic_app/features/tasbeeh/presentation/pages/tasbeeh_screen.dart';
import 'package:islamic_app/features/quran/presentation/pages/mushaf_reader_screen.dart';
import 'package:islamic_app/features/quran/presentation/pages/radio_screen.dart';
import 'package:islamic_app/features/quran/presentation/surah_search_screen.dart';
import 'package:islamic_app/features/nearest_mosque/presentation/pages/nearest_masjed_screen.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/app/presentation/pages/splash_screen.dart';
import '../../features/app/presentation/pages/welcome_screen.dart';
import '../../features/app/presentation/pages/home_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/settings/presentation/pages/about_screen.dart';
import '../../features/settings/presentation/pages/privacy_policy_screen.dart';
import '../../features/settings/presentation/pages/help_support_screen.dart';
import '../../features/community/presentation/pages/premium_community_page.dart';
import '../../features/community/presentation/pages/premium_create_post_page.dart';
import '../../features/community/presentation/cubits/community/community_cubit.dart';
import '../../features/community/community_injector.dart' as community_di;
import 'app_routes.dart';

/// Router configuration for the app with auth guards
class AppRouter {
  final AuthCubit authCubit;

  AppRouter(this.authCubit);

  /// Get the router configuration
  GoRouter get router => GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: _handleRedirect,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    routes: [
      // Splash Route (initial route)
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Welcome Route (for unauthenticated users)
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

      // Home Route (main app screen)
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Auth Routes (Login & Register)
      GoRoute(
        path: AppRoutes.authLogin,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.authRegister,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Protected Routes (require authentication)
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      //Hadith search Route
      GoRoute(
        path: AppRoutes.hadithSearch,
        name: 'HadithSearch',
        builder: (context, state) => const HadithSearchScreen(),
      ),

      //Quran Search Route
      GoRoute(
        path: AppRoutes.quranSearch,
        name: 'quransearch',
        builder: (context, state) => const QuranSearchScreen(),
      ),
      //mushaf Route
      GoRoute(
        path: AppRoutes.mushaf,
        name: 'mushaf',
        builder: (context, state) => const MushafReaderScreen(),
      ),
      //radio Route
      GoRoute(
        path: AppRoutes.radio,
        name: 'radio',
        builder: (context, state) => const RadioScreen(),
      ),
      //hadith Route
      GoRoute(
        path: AppRoutes.hadith,
        name: 'Hadith',
        builder: (context, state) => const HadithScreen(),
      ),
      //qibla Route
      GoRoute(
        path: AppRoutes.qibla,
        name: 'qibla',
        builder: (context, state) => const QiblaScreen(),
      ),
      //nearst mosque Route
      GoRoute(
        path: AppRoutes.nearestMasjedScreen,
        name: 'nearestMasjedScreen',
        builder: (context, state) => const NearestMasjedScreen(),
      ),
      //azkar Route
      GoRoute(
        path: AppRoutes.azkar,
        name: 'azkar',
        builder: (context, state) => const AzkarScreen(),
      ),
      //tasbeh Route
      // GoRoute(
      //   path: AppRoutes.tasbeh,
      //   name: 'tasbeh',
      //   builder: (context, state) => const TasbihScreen(),
      // ),

      // Community Feature Routes
      GoRoute(
        path: AppRoutes.community,
        name: 'community',
        builder: (context, state) => BlocProvider.value(
          // Use singleton instance for caching
          value: community_di.sl<CommunityCubit>(),
          child: const PremiumCommunityPage(),
        ),
      ),
      GoRoute(
        path: '/community/create',
        name: 'community-create',
        builder: (context, state) => BlocProvider.value(
          // Use singleton instance for caching
          value: community_di.sl<CommunityCubit>(),
          child: const PremiumCreatePostPage(),
        ),
      ),

      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // About Route
      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),

      // Privacy Policy Route
      GoRoute(
        path: AppRoutes.privacyPolicy,
        name: 'privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),

      // Help & Support Route
      GoRoute(
        path: AppRoutes.helpSupport,
        name: 'help-support',
        builder: (context, state) => const HelpSupportScreen(),
      ),

      // Tasbeeh Route
      GoRoute(
        path: AppRoutes.tasbeeh,
        name: 'tasbeeh',
        builder: (context, state) => const TasbeehScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              'خطأ: الصفحة غير موجودة',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8.h),
            Text('${state.uri}'),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    ),
  );

  /// Handle route redirects based on auth state
  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final authState = authCubit.state;
    final isAuthenticated = authState is AuthAuthenticated;
    final isOnSplash = state.matchedLocation == AppRoutes.splash;
    final isOnWelcome = state.matchedLocation == AppRoutes.welcome;
    final isOnAuth =
        state.matchedLocation == AppRoutes.authLogin ||
        state.matchedLocation == AppRoutes.authRegister;
    final isOnProtectedRoute = _isProtectedRoute(state.matchedLocation);

    // Debug logging
    debugPrint('Router: path=${state.matchedLocation}, auth=$isAuthenticated');

    // Allow splash screen to handle initial routing
    if (isOnSplash) {
      return null;
    }

    // If user is authenticated
    if (isAuthenticated) {
      // Redirect from welcome/auth screens to home
      if (isOnWelcome || isOnAuth) {
        return AppRoutes.home;
      }
      // Allow access to all other routes
      return null;
    }

    // If user is not authenticated
    if (!isAuthenticated) {
      // Redirect protected routes to welcome
      if (isOnProtectedRoute) {
        return AppRoutes.welcome;
      }
      // Allow access to public routes (welcome, login, register, home)
      return null;
    }

    return null;
  }

  /// Check if a route requires authentication
  bool _isProtectedRoute(String path) {
    const protectedRoutes = [
      AppRoutes.profile,
      AppRoutes.community,
      // Add more protected routes here as needed
      // AppRoutes.quran,
      // AppRoutes.hadith,
      // etc.
    ];
    return protectedRoutes.contains(path);
  }
}

/// Stream that notifies GoRouter when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((AuthState _) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
