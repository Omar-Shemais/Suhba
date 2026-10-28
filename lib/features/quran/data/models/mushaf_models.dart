class MushafPage {
  final int pageNumber;
  final List<MushafVerse> verses;

  MushafPage({required this.pageNumber, required this.verses});
}

class MushafVerse {
  final int surahId;
  final String surahName;
  final String surahNameArabic;
  final int verseId;
  final String textArabic;
  final String textEnglish;
  final bool isNewSurah;
  final int? pageNumber;

  MushafVerse({
    required this.surahId,
    required this.surahName,
    required this.surahNameArabic,
    required this.verseId,
    required this.textArabic,
    required this.textEnglish,
    this.isNewSurah = false,
    this.pageNumber,
  });
}

