import '../model/sibha_model.dart';

class SibhaLocalDataSource {
  static const List<Map<String, dynamic>> sibhaJsonData = [
    {
      'name_ar': 'سُبْحَانَ اللَّهِ',
      'name_en': 'Subhan Allah',
      'meaning_en': 'Glory be to Allah',
    },
    {
      'name_ar': 'الْحَمْدُ لِلَّهِ',
      'name_en': 'Alhamdulillah',
      'meaning_en': 'All praise is due to Allah',
    },
    {
      'name_ar': 'اللَّهُ أَكْبَرُ',
      'name_en': 'Allahu Akbar',
      'meaning_en': 'Allah is the Greatest',
    },
    {
      'name_ar': 'لَا إِلَهَ إِلَّا اللَّهُ',
      'name_en': 'La ilaha illa Allah',
      'meaning_en': 'There is no god but Allah',
    },
    {
      'name_ar': 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
      'name_en': "Allahumma salli wa sallim 'ala nabiyyina Muhammad",
      'meaning_en': 'O Allah, send blessings and peace upon our Prophet Muhammad',
    },
    {
      'name_ar': 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      'name_en': 'Astaghfirullah wa atubu ilayh',
      'meaning_en': 'I seek forgiveness from Allah and repent to Him',
    },
    {
      'name_ar': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'name_en': 'La hawla wa la quwwata illa billah',
      'meaning_en': 'There is no power nor strength except with Allah',
    },
    {
      'name_ar': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      'name_en': 'Subhan Allahi wa bihamdihi, Subhan Allahil Azeem',
      'meaning_en': 'Glory be to Allah and His praise, Glory be to Allah the Almighty',
    },
    {
      'name_ar': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      'name_en': 'Subhan Allahi wa bihamdihi',
      'meaning_en': 'Glory be to Allah and His is the praise',
    },
    {
      'name_ar': 'سُبْحَانَ اللَّهِ الْعَظِيمِ',
      'name_en': 'Subhan Allahil Azeem',
      'meaning_en': 'Glory be to Allah the Almighty',
    },
    {
      'name_ar': 'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      'name_en': 'La ilaha illa anta subhanaka inni kuntu minaz-zalimin',
      'meaning_en': 'There is no deity except You; exalted are You, indeed I was of the wrongdoers',
    },
    {
      'name_ar': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      'name_en': "Hasbunallahu wa ni'mal wakeel",
      'meaning_en': 'Allah is sufficient for us and He is the best Disposer of affairs',
    },
    {
      'name_ar': 'سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ',
      'name_en': 'Subhan Allah, walhamdulillah, wa la ilaha illa Allah, wallahu akbar',
      'meaning_en': 'Glory be to Allah, praise be to Allah, there is no god but Allah, and Allah is the Greatest',
    },
  ];

  List<SibhaModel> getSibhaData() => sibhaJsonData
      .map((item) => SibhaModel.fromJson(item))
      .toList();
}
