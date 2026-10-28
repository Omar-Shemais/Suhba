class JuzItem {
  final int number;
  final String name;
  final String startSurahName;
  final int startSurahId;
  final int startAyah;
  final String startAyahText;
  final List<int> surahIds;

  const JuzItem({
    required this.number,
    required this.name,
    required this.startSurahName,
    required this.startSurahId,
    required this.startAyah,
    required this.startAyahText,
    required this.surahIds,
  });

  static const List<JuzItem> ajza = [
    JuzItem(number: 1, name: 'الجزء الأول', startSurahName: 'الفاتحة', startSurahId: 1, startAyah: 1, startAyahText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', surahIds: [1, 2]),
    JuzItem(number: 2, name: 'الجزء الثاني', startSurahName: 'البقرة (١٤٢)', startSurahId: 2, startAyah: 142, startAyahText: '۞ سَيَقُولُ السُّفَهَاءُ مِنَ النَّاسِ', surahIds: [2]),
    JuzItem(number: 3, name: 'الجزء الثالث', startSurahName: 'البقرة (٢٥٣)', startSurahId: 2, startAyah: 253, startAyahText: '۞ تِلْكَ الرُّسُلُ فَضَّلْنَا بَعْضَهُمْ عَلَىٰ بَعْضٍ', surahIds: [2, 3]),
    JuzItem(number: 4, name: 'الجزء الرابع', startSurahName: 'آل عمران (٩٣)', startSurahId: 3, startAyah: 93, startAyahText: '۞ كُلُّ الطَّعَامِ كَانَ حِلًّا لِّبَنِي إِسْرَائِيلَ', surahIds: [3, 4]),
    JuzItem(number: 5, name: 'الجزء الخامس', startSurahName: 'النساء (٢٤)', startSurahId: 4, startAyah: 24, startAyahText: '۞ وَالْمُحْصَنَاتُ مِنَ النِّسَاءِ', surahIds: [4]),
    JuzItem(number: 6, name: 'الجزء السادس', startSurahName: 'النساء (١٤٨)', startSurahId: 4, startAyah: 148, startAyahText: '۞ لَّا يُحِبُّ اللَّهُ الْجَهْرَ بِالسُّوءِ', surahIds: [4, 5]),
    JuzItem(number: 7, name: 'الجزء السابع', startSurahName: 'المائدة (٨٢)', startSurahId: 5, startAyah: 82, startAyahText: '۞ وَإِذَا سَمِعُوا مَا أُنزِلَ إِلَى الرَّسُولِ', surahIds: [5, 6]),
    JuzItem(number: 8, name: 'الجزء الثامن', startSurahName: 'الأنعام (١١١)', startSurahId: 6, startAyah: 111, startAyahText: '۞ وَلَوْ أَنَّنَا نَزَّلْنَا إِلَيْهِمُ الْمَلَائِكَةَ', surahIds: [6, 7]),
    JuzItem(number: 9, name: 'الجزء التاسع', startSurahName: 'الأعراف (٨٨)', startSurahId: 7, startAyah: 88, startAyahText: '۞ قَالَ الْمَلَأُ الَّذِينَ اسْتَكْبَرُوا مِن قَوْمِهِ', surahIds: [7, 8]),
    JuzItem(number: 10, name: 'الجزء العاشر', startSurahName: 'الأنفال (٤١)', startSurahId: 8, startAyah: 41, startAyahText: '۞ وَاعْلَمُوا أَنَّمَا غَنِمْتُم مِّن شَيْءٍ', surahIds: [8, 9]),
    JuzItem(number: 11, name: 'الجزء الحادي عشر', startSurahName: 'التوبة (٩٣)', startSurahId: 9, startAyah: 93, startAyahText: '۞ يَعْتَذِرُونَ إِلَيْكُمْ إِذَا رَجَعْتُمْ إِلَيْهِمْ', surahIds: [9, 10, 11]),
    JuzItem(number: 12, name: 'الجزء الثاني عشر', startSurahName: 'هود (٦)', startSurahId: 11, startAyah: 6, startAyahText: '۞ وَمَا مِن دَابَّةٍ فِي الْأَرْضِ إِلَّا عَلَى اللَّهِ رِزْقُهَا', surahIds: [11, 12]),
    JuzItem(number: 13, name: 'الجزء الثالث عشر', startSurahName: 'يوسف (٥٣)', startSurahId: 12, startAyah: 53, startAyahText: '۞ وَمَا أُبَرِّئُ نَفْسِي ۚ إِنَّ النَّفْسَ لَأَمَّارَةٌ بِالسُّوءِ', surahIds: [12, 13, 14]),
    JuzItem(number: 14, name: 'الجزء الرابع عشر', startSurahName: 'الحجر (١)', startSurahId: 15, startAyah: 1, startAyahText: '۞ الر ۚ تِلْكَ آيَاتُ الْكِتَابِ وَقُرْآنٍ مُّبِينٍ', surahIds: [15, 16]),
    JuzItem(number: 15, name: 'الجزء الخامس عشر', startSurahName: 'الإسراء (١)', startSurahId: 17, startAyah: 1, startAyahText: '۞ سُبْحَانَ الَّذِي أَسْرَىٰ بِعَبْدِهِ لَيْلًا', surahIds: [17, 18]),
    JuzItem(number: 16, name: 'الجزء السادس عشر', startSurahName: 'الكهف (٧٥)', startSurahId: 18, startAyah: 75, startAyahText: '۞ قَالَ أَلَمْ أَقُل لَّكَ إِنَّكَ لَن تَسْتَطِيعَ مَعِيَ صَبْرًا', surahIds: [18, 19, 20]),
    JuzItem(number: 17, name: 'الجزء السابع عشر', startSurahName: 'الأنبياء (١)', startSurahId: 21, startAyah: 1, startAyahText: '۞ اقْتَرَبَ لِلنَّاسِ حِسَابُهُمْ وَهُمْ فِي غَفْلَةٍ', surahIds: [21, 22]),
    JuzItem(number: 18, name: 'الجزء الثامن عشر', startSurahName: 'المؤمنون (١)', startSurahId: 23, startAyah: 1, startAyahText: '۞ قَدْ أَفْلَحَ الْمُؤْمِنُونَ', surahIds: [23, 24, 25]),
    JuzItem(number: 19, name: 'الجزء التاسع عشر', startSurahName: 'الفرقان (٢١)', startSurahId: 25, startAyah: 21, startAyahText: '۞ وَقَالَ الَّذِينَ لَا يَرْجُونَ لِقَاءَنَا', surahIds: [25, 26, 27]),
    JuzItem(number: 20, name: 'الجزء العشرون', startSurahName: 'النمل (٥٦)', startSurahId: 27, startAyah: 56, startAyahText: '۞ أَمَّنْ خَلَقَ السَّمَاوَاتِ وَالْأَرْضَ', surahIds: [27, 28, 29]),
    JuzItem(number: 21, name: 'الجزء الحادي والعشرون', startSurahName: 'العنكبوت (٤٦)', startSurahId: 29, startAyah: 46, startAyahText: '۞ وَلَا تُجَادِلُوا أَهْلَ الْكِتَابِ إِلَّا بِالَّتِي هِيَ أَحْسَنُ', surahIds: [29, 30, 31, 32, 33]),
    JuzItem(number: 22, name: 'الجزء الثاني والعشرون', startSurahName: 'الأحزاب (٣١)', startSurahId: 33, startAyah: 31, startAyahText: '۞ وَمَن يَقْنُتْ مِنكُنَّ لِلَّهِ وَرَسُولِهِ', surahIds: [33, 34, 35, 36]),
    JuzItem(number: 23, name: 'الجزء الثالث والعشرون', startSurahName: 'يس (٢٨)', startSurahId: 36, startAyah: 28, startAyahText: '۞ وَمَا أَنزَلْنَا عَلَىٰ قَوْمِهِ مِن بَعْدِهِ مِن جُندٍ', surahIds: [36, 37, 38, 39]),
    JuzItem(number: 24, name: 'الجزء الرابع والعشرون', startSurahName: 'الزمر (٣٢)', startSurahId: 39, startAyah: 32, startAyahText: '۞ فَمَنْ أَظْلَمُ مِمَّن كَذَبَ عَلَى اللَّهِ', surahIds: [39, 40, 41]),
    JuzItem(number: 25, name: 'الجزء الخامس والعشرون', startSurahName: 'فصلت (٤٧)', startSurahId: 41, startAyah: 47, startAyahText: '۞ إِلَيْهِ يُرَدُّ عِلْمُ السَّاعَةِ', surahIds: [41, 42, 43, 44, 45]),
    JuzItem(number: 26, name: 'الجزء السادس والعشرون', startSurahName: 'الأحقاف (١)', startSurahId: 46, startAyah: 1, startAyahText: '۞ حم • تَنزِيلُ الْكِتَابِ مِنَ اللَّهِ الْعَزِيزِ الْحَكِيمِ', surahIds: [46, 47, 48, 49, 50, 51]),
    JuzItem(number: 27, name: 'الجزء السابع والعشرون', startSurahName: 'الذاريات (٣١)', startSurahId: 51, startAyah: 31, startAyahText: '۞ قَالَ فَمَا خَطْبُكُمْ أَيُّهَا الْمُرْسَلُونَ', surahIds: [51, 52, 53, 54, 55, 56, 57]),
    JuzItem(number: 28, name: 'الجزء الثامن والعشرون', startSurahName: 'المجادلة (١)', startSurahId: 58, startAyah: 1, startAyahText: '۞ قَدْ سَمِعَ اللَّهُ قَوْلَ الَّتِي تُجَادِلُكَ فِي زَوْجِهَا', surahIds: [58, 59, 60, 61, 62, 63, 64, 65, 66]),
    JuzItem(number: 29, name: 'الجزء التاسع والعشرون', startSurahName: 'الملك (١)', startSurahId: 67, startAyah: 1, startAyahText: '۞ تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ', surahIds: [67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77]),
    JuzItem(number: 30, name: 'الجزء الثلاثون', startSurahName: 'النبأ (١)', startSurahId: 78, startAyah: 1, startAyahText: '۞ عَمَّ يَتَسَاءَلُونَ • عَنِ النَّبَإِ الْعَظِيمِ', surahIds: [78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114]),
  ];
}
