import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/quran/data/models/tafsir_model.dart';

void main() {
  group('Tafsir Model and Edition Tests', () {
    test('AyahTafsirModel fromJson parses correctly', () {
      final json = {
        'id': '1',
        'sura': '1',
        'aya': '1',
        'arabic_text': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        'translation': 'أبتدئ قراءة القرآن باسم الله...',
        'footnotes': 'هوامش توضيحية',
      };

      final model = AyahTafsirModel.fromJson(json);

      expect(model.id, 1);
      expect(model.sura, 1);
      expect(model.aya, 1);
      expect(model.arabicText, 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ');
      expect(model.tafsirText, 'أبتدئ قراءة القرآن باسم الله...');
      expect(model.footnotes, 'هوامش توضيحية');
    });

    test('TafsirEdition contains default editions', () {
      expect(TafsirEdition.availableEditions.length, 2);
      expect(TafsirEdition.availableEditions.first.key, 'arabic_moyassar');
      expect(TafsirEdition.availableEditions.last.key, 'arabic_mokhtasar');
    });
  });
}
