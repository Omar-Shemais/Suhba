import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/quran/data/models/audio_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Reciter URLs & CDN Tests', () {
    final reciters = [
      ReciterModel(
        id: 1,
        name: 'Mishary Rashid Alafasy',
        arabicName: 'مشاري بن راشد العفاسي',
        baseUrl: 'https://cdn.mp3quran.net/audio',
        subfolder: 'mishary-alafasy/r1',
        bitrate: 128,
        availableSurahs: ['001', '002', '114'],
      ),
      ReciterModel(
        id: 2,
        name: 'Abdul Basit Abdul Samad',
        arabicName: 'عبد الباسط عبد الصمد',
        baseUrl: 'https://cdn.mp3quran.net/audio',
        subfolder: 'abdulbasit-abdulsamad/r3',
        bitrate: 128,
        availableSurahs: ['001', '002', '114'],
      ),
      ReciterModel(
        id: 3,
        name: 'Saad Al-Ghamdi',
        arabicName: 'سعد الغامدي',
        baseUrl: 'https://cdn.mp3quran.net/audio',
        subfolder: 'saad-ghamdi/r1',
        bitrate: 128,
        availableSurahs: ['001', '002', '114'],
      ),
      ReciterModel(
        id: 4,
        name: 'Maher Al Muaiqly',
        arabicName: 'ماهر المعيقلي',
        baseUrl: 'https://cdn.mp3quran.net/audio',
        subfolder: 'maher-muaiqly/r1',
        bitrate: 128,
        availableSurahs: ['001', '002', '114'],
      ),
      ReciterModel(
        id: 5,
        name: 'Ahmed Al Ajmy',
        arabicName: 'أحمد بن علي العجمي',
        baseUrl: 'https://cdn.mp3quran.net/audio',
        subfolder: 'ahmad-ajmi/r1',
        bitrate: 128,
        availableSurahs: ['001', '002', '114'],
      ),
    ];

    test('Each reciter generates valid Surah URL without connection aborting legacy servers', () {
      expect(
        reciters[0].getAudioUrl(1),
        'https://cdn.mp3quran.net/audio/mishary-alafasy/r1/001.mp3',
      );
      expect(
        reciters[1].getAudioUrl(1),
        'https://cdn.mp3quran.net/audio/abdulbasit-abdulsamad/r3/001.mp3',
      );
      expect(
        reciters[2].getAudioUrl(1),
        'https://cdn.mp3quran.net/audio/saad-ghamdi/r1/001.mp3',
      );
      expect(
        reciters[3].getAudioUrl(1),
        'https://cdn.mp3quran.net/audio/maher-muaiqly/r1/001.mp3',
      );
      expect(
        reciters[4].getAudioUrl(1),
        'https://cdn.mp3quran.net/audio/ahmad-ajmi/r1/001.mp3',
      );
    });

    test('Each reciter generates true distinct EveryAyah audio URL without defaulting to Alafasy', () {
      final alafasyAyah = reciters[0].getAyahAudioUrl(1, 1);
      final abdulbasitAyah = reciters[1].getAyahAudioUrl(1, 1);
      final saadAyah = reciters[2].getAyahAudioUrl(1, 1);
      final maherAyah = reciters[3].getAyahAudioUrl(1, 1);
      final ajmyAyah = reciters[4].getAyahAudioUrl(1, 1);

      expect(alafasyAyah, 'https://everyayah.com/data/Alafasy_128kbps/001001.mp3');
      expect(abdulbasitAyah, 'https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/001001.mp3');
      expect(saadAyah, 'https://everyayah.com/data/Ghamadi_40kbps/001001.mp3');
      expect(maherAyah, 'https://everyayah.com/data/MaherAlMuaiqly128kbps/001001.mp3');
      expect(ajmyAyah, 'https://everyayah.com/data/Ahmed_ibn_Ali_al-Ajamy_128kbps_ketaballah.net/001001.mp3');

      // Verify all 5 are distinct
      final set = {alafasyAyah, abdulbasitAyah, saadAyah, maherAyah, ajmyAyah};
      expect(set.length, 5);
    });
  });
}
