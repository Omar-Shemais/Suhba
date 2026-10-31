import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/constants/assets.dart';
import 'package:islamic_app/features/app/presentation/pages/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders authentic components: clean bg, medallion, tagline, and verse card',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: SplashScreen(
            shouldNavigate: false,
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify background image is present
    final bgFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == AssetsData.splashBgClean,
    );
    expect(bgFinder, findsOneWidget);

    // Verify Hero app_logo widget exists
    final heroFinder = find.byWidgetPredicate(
      (widget) => widget is Hero && widget.tag == 'app_logo',
    );
    expect(heroFinder, findsOneWidget);

    // Verify medallion image is present
    final medallionFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == AssetsData.splashMedallion,
    );
    expect(medallionFinder, findsOneWidget);

    // Let animation run forward
    await tester.pump(const Duration(milliseconds: 1800));

    // Verify tagline component is present
    final taglineFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == AssetsData.splashTagline,
    );
    expect(taglineFinder, findsOneWidget);

    // Verify verse card component is present
    final verseFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == AssetsData.splashVerseCard,
    );
    expect(verseFinder, findsOneWidget);

    // Verify semantics label
    expect(
      find.bySemanticsLabel('صحبة - رفيقك في رحلتك الروحية - واذكر ربك في نفسك تضرعا وخيفة'),
      findsOneWidget,
    );
  });

  testWidgets('SplashScreen consistently renders authentic ivory theme across brightness modes',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          theme: ThemeData.dark(),
          home: const SplashScreen(
            shouldNavigate: false,
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 800));

    final scaffoldFinder = find.byType(Scaffold);
    expect(scaffoldFinder, findsOneWidget);
    final scaffold = tester.widget<Scaffold>(scaffoldFinder);
    expect(scaffold.backgroundColor, const Color(0xFFFAF5ED));

    final heroFinder = find.byWidgetPredicate(
      (widget) => widget is Hero && widget.tag == 'app_logo',
    );
    expect(heroFinder, findsOneWidget);
  });

  testWidgets('SplashScreen is fully responsive on small phone screens (320x568) without overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(320, 568),
        builder: (context, child) => const MaterialApp(
          home: SplashScreen(
            shouldNavigate: false,
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 800));

    // Ensure zero render flex overflow errors
    expect(tester.takeException(), isNull);
  });

  testWidgets('SplashScreen configures edge-to-edge transparent system bars with contrast enforcement disabled',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: SplashScreen(
            shouldNavigate: false,
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify SystemUiOverlayStyle set by SplashScreen
    final style = SystemChrome.latestStyle;
    expect(style, isNotNull);
    expect(style!.systemNavigationBarColor, equals(Colors.transparent));
    expect(style.systemNavigationBarDividerColor, equals(Colors.transparent));
    expect(style.systemNavigationBarContrastEnforced, isFalse);
    expect(style.statusBarColor, equals(Colors.transparent));
    expect(style.systemStatusBarContrastEnforced, isFalse);

    // Verify Scaffold configuration: extends body behind system bars with no SafeArea on background
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.extendBody, isTrue);
    expect(scaffold.extendBodyBehindAppBar, isTrue);
    expect(scaffold.resizeToAvoidBottomInset, isFalse);

    // Verify background image is NOT wrapped in a SafeArea
    final bgFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == AssetsData.splashBgClean,
    );
    expect(
      find.ancestor(of: bgFinder, matching: find.byType(SafeArea)),
      findsNothing,
      reason: 'Background image must not be wrapped in SafeArea so it extends edge-to-edge',
    );
  });
}

