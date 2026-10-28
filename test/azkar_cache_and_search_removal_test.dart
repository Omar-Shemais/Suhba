import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/theme/dark_theme.dart';
import 'package:islamic_app/core/theme/light_theme.dart';
import 'package:islamic_app/features/azkar/data/repositories/azkar_repo.dart';
import 'package:islamic_app/features/duaa/presentation/pages/duaa_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CircularProgressIndicator Theme Color Tests', () {
    test('Light theme progressIndicatorTheme has distinctive Islamic forest green', () {
      expect(lightTheme.progressIndicatorTheme.color, const Color(0xFF143427));
      expect(lightTheme.progressIndicatorTheme.circularTrackColor, const Color(0xFFEADBCE));
    });

    test('Dark theme progressIndicatorTheme has distinctive warm sand gold', () {
      expect(darkTheme.progressIndicatorTheme.color, const Color(0xFFC7A87A));
      expect(darkTheme.progressIndicatorTheme.circularTrackColor, const Color(0xFF2A2A2A));
    });
  });

  group('Azkar Offline-First Caching Tests', () {
    test('AzkarRepo loads bundled assets offline without error', () async {
      final morningRes = await AzkarRepo.getMorningAzkar();
      expect(morningRes.isRight(), isTrue);
      morningRes.fold(
        (_) => fail('Morning azkar failed'),
        (azkar) {
          expect(azkar.azkar.isNotEmpty, isTrue);
          expect(AzkarRepo.cachedMorning, isNotNull);
        },
      );

      final eveningRes = await AzkarRepo.getEveningAzkar();
      expect(eveningRes.isRight(), isTrue);
      eveningRes.fold(
        (_) => fail('Evening azkar failed'),
        (azkar) {
          expect(azkar.azkar.isNotEmpty, isTrue);
          expect(AzkarRepo.cachedEvening, isNotNull);
        },
      );

      final postPrayerRes = await AzkarRepo.getAfterPrayerAzkar();
      expect(postPrayerRes.isRight(), isTrue);
      postPrayerRes.fold(
        (_) => fail('After prayer azkar failed'),
        (azkar) {
          expect(azkar.azkar.isNotEmpty, isTrue);
          expect(AzkarRepo.cachedAfterPrayer, isNotNull);
        },
      );
    });
  });

  group('Duaa Screen Search Removal Tests', () {
    testWidgets('DuaaScreen does not contain a search text field', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: DuaaScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure no search TextField exists
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(DuaaScreen), findsOneWidget);
    });
  });
}
