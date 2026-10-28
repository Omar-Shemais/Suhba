import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/quran/data/models/audio_model.dart';
import 'package:islamic_app/features/quran/presentation/cubit/audio_cubit.dart';
import 'package:islamic_app/features/quran/presentation/cubit/audio_state.dart';
import 'package:islamic_app/features/quran/presentation/widgets/radio_station_card.dart';
import 'package:islamic_app/features/quran/presentation/widgets/radio_view_body.dart';

class FakeAudioCubit extends Cubit<AudioState> implements AudioCubit {
  FakeAudioCubit() : super(AudioInitial());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('RadioStationCard renders in light and dark mode',
      (WidgetTester tester) async {
    final cubit = FakeAudioCubit();

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => BlocProvider<AudioCubit>.value(
          value: cubit,
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  RadioStationCard(
                    station: RadioStationModel(
                      id: 1,
                      name: 'إذاعة القرآن الكريم',
                      arabicName: 'إذاعة القرآن الكريم',
                      url: 'https://example.com/radio1.mp3',
                    ),
                    index: 0,
                  ),
                  RadioStationCard(
                    station: RadioStationModel(
                      id: 2,
                      name: 'إذاعة الحديث الشريف',
                      arabicName: 'إذاعة الحديث الشريف',
                      url: 'https://example.com/radio2.mp3',
                    ),
                    index: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('إذاعة القرآن الكريم'), findsOneWidget);
    expect(find.text('إذاعة الحديث الشريف'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsNWidgets(2));
  });

  testWidgets('RadioViewBody renders without errors',
      (WidgetTester tester) async {
    final cubit = FakeAudioCubit();

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => BlocProvider<AudioCubit>.value(
          value: cubit,
          child: const MaterialApp(
            home: Scaffold(
              body: RadioViewBody(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('الراديو'), findsOneWidget);
    expect(find.text('القرآن الكريم'), findsWidgets);
    expect(find.text('الأحاديث النبوية'), findsOneWidget);
    expect(find.text('ابحث في هذا القسم...'), findsWidgets);
  });
}
