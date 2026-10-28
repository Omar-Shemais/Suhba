import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/theme/cubit/theme_cubit.dart';
import 'package:islamic_app/core/utils/service_locator.dart';
import 'package:islamic_app/features/prayer_times/data/repositories/prayer_repository.dart';
import 'package:islamic_app/features/prayer_times/presentation/cubit/prayer_cubit.dart';
import 'package:islamic_app/features/quran/data/repositories/audio_repo.dart';
import 'package:islamic_app/features/settings/presentation/pages/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'selected_reciter_arabic_name': 'عبد الباسط عبد الصمد',
      'prayer_calculation_method_name': 'الهيئة المصرية العامة للمساحة',
      'prayer_calculation_method_id': 5,
    });

    if (!getIt.isRegistered<AudioRepository>()) {
      getIt.registerLazySingleton<AudioRepository>(() => AudioRepositoryImpl());
    }
  });

  Widget createSettingsScreen({bool isDark = false}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => PrayerCubit(PrayerRepositoryImpl())),
        ],
        child: MaterialApp(
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const SettingsScreen(),
        ),
      ),
    );
  }

  testWidgets('SettingsScreen renders completely with theme and no auth/login cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(createSettingsScreen(isDark: false));
    await tester.pumpAndSettle();

    // 1. لا وجود لأي بطاقات تسجيل دخول أو زائر
    expect(find.text('تسجيل الدخول'), findsNothing);
    expect(find.text('تسجيل كزائر'), findsNothing);
    expect(find.text('تسجيل الخروج'), findsNothing);

    // 2. بطاقة الهوية والعنوان
    expect(find.text('الإعدادات'), findsOneWidget);
    expect(find.text('تطبيق صُحْبَة'), findsOneWidget);

    // 3. قسم القرآن والتلاوة
    expect(find.text('القرآن الكريم والتلاوة'), findsOneWidget);
    expect(find.text('القارئ المفضل لتلاوة القرآن'), findsOneWidget);
    expect(find.text('متابعة القراءة (آخر موضع)'), findsOneWidget);
    expect(find.text('حجم خط المصحف'), findsNothing);
    expect(find.text('نمط تصفح وقراءة المصحف'), findsNothing);

    // 4. سهم الرجوع المعتمد بحسب AGENTS.md
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

    // 5. قسم مواقيت الصلاة والتنبيهات
    await tester.scrollUntilVisible(
      find.text('إعدادات الأذان والتنبيهات'),
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('مواقيت الصلاة والتنبيهات'), findsOneWidget);
    expect(find.text('إعدادات الأذان والتنبيهات'), findsOneWidget);
    expect(find.text('طريقة حساب مواقيت الصلاة'), findsOneWidget);

    // 6. قسم المظهر
    await tester.scrollUntilVisible(
      find.text('الوضع الليلي (المظهر الداكن)'),
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('الوضع الليلي (المظهر الداكن)'), findsOneWidget);

    // 7. قسم المشاركة والدعم والختام
    await tester.scrollUntilVisible(
      find.text('صدقة جارية لوجه الله تعالى'),
      250.0,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('مشاركة التطبيق (صدقة جارية)'), findsOneWidget);
    expect(find.text('تقييم تطبيق صُحْبَة'), findsOneWidget);
    expect(find.text('عن تطبيق صُحْبَة'), findsOneWidget);
    expect(find.text('سياسة الخصوصية'), findsOneWidget);
    expect(find.text('المساعدة والإرشادات'), findsOneWidget);
    expect(find.text('صدقة جارية لوجه الله تعالى'), findsOneWidget);
  });

  testWidgets('SettingsScreen renders in dark mode without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(createSettingsScreen(isDark: true));
    await tester.pumpAndSettle();

    expect(find.text('الإعدادات'), findsOneWidget);
    expect(find.text('تطبيق صُحْبَة'), findsOneWidget);
    expect(find.text('القرآن الكريم والتلاوة'), findsOneWidget);
  });
}
