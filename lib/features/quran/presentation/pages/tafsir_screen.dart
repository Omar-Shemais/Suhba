import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/tafsir_model.dart';
import '../../data/repositories/tafsir_repository.dart';

class TafsirScreen extends StatefulWidget {
  final int surahId;
  final int ayahNumber;
  final String surahName;
  final String? initialArabicText;
  final int? totalVerses;

  const TafsirScreen({
    super.key,
    required this.surahId,
    required this.ayahNumber,
    required this.surahName,
    this.initialArabicText,
    this.totalVerses,
  });

  @override
  State<TafsirScreen> createState() => _TafsirScreenState();
}

class _TafsirScreenState extends State<TafsirScreen> {
  final TafsirRepository _repository = TafsirRepository();

  late int _currentAyah;
  late int _totalVerses;
  String _selectedTafsirKey = 'arabic_moyassar';
  double _fontSize = 18.0;

  bool _isLoading = true;
  String? _errorMessage;
  AyahTafsirModel? _tafsirData;
  List<AyahTafsirModel> _surahTafsirs = [];

  @override
  void initState() {
    super.initState();
    _currentAyah = widget.ayahNumber;
    _totalVerses = widget.totalVerses ?? 286;
    _loadAyahTafsir();
    _loadSurahTafsirInBackground();
  }

  String _toArabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => int.tryParse(d) != null ? arabicDigits[int.parse(d)] : d)
        .join('');
  }

  Future<void> _loadAyahTafsir() async {
    if (_surahTafsirs.isNotEmpty) {
      final cached = _surahTafsirs.where((t) => t.aya == _currentAyah).firstOrNull;
      if (cached != null) {
        setState(() {
          _tafsirData = cached;
          _isLoading = false;
          _errorMessage = null;
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _repository.getAyahTafsir(
        suraNumber: widget.surahId,
        ayaNumber: _currentAyah,
        tafsirKey: _selectedTafsirKey,
      );

      if (mounted) {
        setState(() {
          _tafsirData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'تعذر تحميل التفسير. يرجى التحقق من اتصال الإنترنت.';
        });
      }
    }
  }

  Future<void> _loadSurahTafsirInBackground() async {
    try {
      final list = await _repository.getSurahTafsir(
        suraNumber: widget.surahId,
        tafsirKey: _selectedTafsirKey,
      );
      if (mounted) {
        setState(() {
          _surahTafsirs = list;
          if (widget.totalVerses == null && list.isNotEmpty) {
            _totalVerses = list.length;
          }
        });
      }
    } catch (_) {}
  }

  void _onTafsirEditionChanged(String newKey) {
    if (_selectedTafsirKey == newKey) return;
    setState(() {
      _selectedTafsirKey = newKey;
      _surahTafsirs = [];
    });
    _loadAyahTafsir();
    _loadSurahTafsirInBackground();
  }

  void _goToPreviousAyah() {
    if (_currentAyah > 1) {
      setState(() {
        _currentAyah--;
      });
      _loadAyahTafsir();
    }
  }

  void _goToNextAyah() {
    if (_currentAyah < _totalVerses) {
      setState(() {
        _currentAyah++;
      });
      _loadAyahTafsir();
    }
  }

  void _shareTafsir() {
    if (_tafsirData == null) return;
    final textToShare =
        '﴿ ${_tafsirData!.arabicText.isNotEmpty ? _tafsirData!.arabicText : (widget.initialArabicText ?? "")} ﴾ [${widget.surahName}: ${_toArabicNumber(_currentAyah)}]\n\n'
        'تفسير الآية (${_selectedTafsirKey == "arabic_moyassar" ? "التفسير الميسر" : "المختصر في التفسير"}):\n'
        '${_tafsirData!.tafsirText}\n\n'
        'تمت المشاركة من تطبيق صُحبة 🌿';

    Share.share(textToShare);
  }

  void _showAyahPickerSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF282C32) : const Color(0xFFFAF5ED),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'الانتقال إلى آية في ${widget.surahName}',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF38291D),
                  ),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _totalVerses,
                    itemBuilder: (context, index) {
                      final ayahNum = index + 1;
                      final isSelected = ayahNum == _currentAyah;
                      return InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          if (ayahNum != _currentAyah) {
                            setState(() {
                              _currentAyah = ayahNum;
                            });
                            _loadAyahTafsir();
                          }
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF143427)
                                : (isDark
                                    ? const Color(0xFF1E2125)
                                    : Colors.white),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF143427)
                                  : (isDark
                                      ? const Color(0xFF383E46)
                                      : const Color(0xFFEADBCE)),
                              width: 1.2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _toArabicNumber(ayahNum),
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 16.sp,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? Colors.white70
                                      : const Color(0xFF38291D)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final arabicVerse = _tafsirData?.arabicText.isNotEmpty == true
        ? _tafsirData!.arabicText
        : (widget.initialArabicText ?? '');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF1E2125) : const Color(0xFFFAF5ED),
        appBar: AppBar(
          backgroundColor:
              isDark ? const Color(0xFF1E2125) : const Color(0xFFFAF5ED),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20.sp,
              color: isDark ? Colors.white : const Color(0xFF38291D),
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          centerTitle: true,
          title: Text(
            'تفسير ${widget.surahName}',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF38291D),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.share_rounded,
                size: 20.sp,
                color: isDark ? Colors.white70 : const Color(0xFF38291D),
              ),
              tooltip: 'مشاركة التفسير',
              onPressed: _shareTafsir,
            ),
          ],
        ),
        body: Column(
          children: [
            // شريط اختيار مصدر التفسير والتحكم في الخط
            _buildSourceAndFontBar(isDark),

            // المحتوى الرئيسي
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF143427),
                      ),
                    )
                  : _errorMessage != null
                      ? _buildErrorView(isDark)
                      : ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          children: [
                            // 1. بطاقة نص الآية الكريمة
                            _buildAyahCard(isDark, arabicVerse),
                            SizedBox(height: 16.h),

                            // 2. بطاقة التفسير
                            _buildTafsirCard(isDark),
                            SizedBox(height: 20.h),
                          ],
                        ),
            ),

            // شريط التنقل السفلي بين الآيات
            _buildBottomNavigationBar(isDark),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // شريط التحكم بالخط ومصدر التفسير
  // ==============================================================
  Widget _buildSourceAndFontBar(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // اختيار كتاب التفسير
          PopupMenuButton<String>(
            initialValue: _selectedTafsirKey,
            onSelected: _onTafsirEditionChanged,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            color: isDark ? const Color(0xFF282C32) : Colors.white,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  size: 18.sp,
                  color: AppColors.goldenPrimary,
                ),
                SizedBox(width: 8.w),
                Text(
                  _selectedTafsirKey == 'arabic_moyassar'
                      ? 'التفسير الميسر'
                      : 'المختصر في التفسير',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF143427),
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18.sp,
                  color: isDark ? Colors.white70 : const Color(0xFF8C7A6B),
                ),
              ],
            ),
            itemBuilder: (context) => [
              for (final edition in TafsirEdition.availableEditions)
                PopupMenuItem(
                  value: edition.key,
                  child: Row(
                    children: [
                      Icon(
                        _selectedTafsirKey == edition.key
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: _selectedTafsirKey == edition.key
                            ? const Color(0xFF143427)
                            : Colors.grey,
                        size: 18.sp,
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            edition.name,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            edition.description,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // التحكم بحجم خط التفسير
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.text_decrease_rounded,
                  size: 20.sp,
                  color: isDark ? Colors.white70 : const Color(0xFF736152),
                ),
                onPressed: () {
                  if (_fontSize > 14) {
                    setState(() => _fontSize -= 1.5);
                  }
                },
              ),
              Text(
                '${_fontSize.toInt()}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : const Color(0xFF736152),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.text_increase_rounded,
                  size: 20.sp,
                  color: isDark ? Colors.white70 : const Color(0xFF736152),
                ),
                onPressed: () {
                  if (_fontSize < 30) {
                    setState(() => _fontSize += 1.5);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // بطاقة الآية الكريمة
  // ==============================================================
  Widget _buildAyahCard(bool isDark, String arabicVerse) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // رأس الكارت: رقم الآية واسم السورة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E382B)
                      : const Color(0xFFE8F1EC),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '${widget.surahName} • الآية ${_toArabicNumber(_currentAyah)}',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF143427),
                  ),
                ),
              ),
              Icon(
                Icons.format_quote_rounded,
                color: AppColors.goldenPrimary,
                size: 22.sp,
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // نص الآية الكريمة
          SelectableText(
            '$arabicVerse ﴿${_toArabicNumber(_currentAyah)}﴾',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22.sp,
              height: 2.0,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF231B15),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // بطاقة نص التفسير
  // ==============================================================
  Widget _buildTafsirCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 18.sp,
                color: const Color(0xFF143427),
              ),
              SizedBox(width: 8.w),
              Text(
                'بيان المعاني والتفسير',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF143427),
                ),
              ),
            ],
          ),
          const Divider(height: 22, thickness: 0.8),
          SelectableText(
            _tafsirData?.tafsirText ?? '',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: _fontSize.sp,
              height: 2.1,
              color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF38291D),
            ),
          ),
          if (_tafsirData?.footnotes != null &&
              _tafsirData!.footnotes!.trim().isNotEmpty) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFF7F3EC),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark ? Colors.white24 : const Color(0xFFE5DDD0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'هوامش وفائدة:',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldenPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  SelectableText(
                    _tafsirData!.footnotes!,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: (_fontSize - 3).sp,
                      height: 1.8,
                      color: isDark ? Colors.white70 : const Color(0xFF736152),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==============================================================
  // واجهة الخطأ مع زر إعادة المحاولة
  // ==============================================================
  Widget _buildErrorView(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 48.sp,
              color: const Color(0xFF8C7A6B),
            ),
            SizedBox(height: 14.h),
            Text(
              _errorMessage ?? 'حدث خطأ في تحميل التفسير',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 16.sp,
                color: isDark ? Colors.white70 : const Color(0xFF38291D),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: _loadAyahTafsir,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF143427),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 10.h,
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // شريط التنقل السفلي بين الآيات
  // ==============================================================
  Widget _buildBottomNavigationBar(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : const Color(0xFFFAF5ED),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // زر الآية التالية (يمين في صفحة RTL)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _currentAyah > 1 ? _goToPreviousAyah : null,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  side: BorderSide(
                    color: _currentAyah > 1
                        ? (isDark ? Colors.white30 : const Color(0xFFEADBCE))
                        : Colors.transparent,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                label: const Text('الآية السابقة'),
              ),
            ),

            SizedBox(width: 12.w),

            // زر استعراض فهرس آيات السورة
            InkWell(
              onTap: () => _showAyahPickerSheet(isDark),
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2125)
                      : const Color(0xFFEADBCE).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_toArabicNumber(_currentAyah)} / ${_toArabicNumber(_totalVerses)}',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF143427),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.format_list_bulleted_rounded,
                      size: 16.sp,
                      color: const Color(0xFF143427),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // زر الآية التالية (يسار في صفحة RTL)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _currentAyah < _totalVerses ? _goToNextAyah : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF143427),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: isDark ? Colors.white10 : Colors.black12,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                label: const Text('الآية التالية'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
