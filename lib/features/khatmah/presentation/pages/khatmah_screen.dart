import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:go_router/go_router.dart';
import 'package:islamic_app/core/constants/assets.dart';
import 'package:islamic_app/core/routes/app_routes.dart';
import '../../../quran/presentation/pages/quran_section_detail_screen.dart';
import '../../data/helpers/khatmah_manager.dart';
import '../../data/models/khatmah_model.dart';

class KhatmahScreen extends StatefulWidget {
  const KhatmahScreen({super.key});

  @override
  State<KhatmahScreen> createState() => _KhatmahScreenState();
}

class _KhatmahScreenState extends State<KhatmahScreen> {
  KhatmahModel? _activeKhatmah;
  bool _isLoading = true;
  int _selectedJuz = 1;

  // إعدادات الختمة الجديدة
  final TextEditingController _titleController = TextEditingController(
    text: 'ختمتي المباركة',
  );
  int _selectedTargetDays = 30;
  final List<int> _presetDays = [7, 10, 15, 30, 60];

  // ✅ اللون الأساسي الإسلامي (أخضر زمردي راقٍ في الداكن وأخضر غابي في الفاتح بدون أي أصفر)
  Color get _primaryColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF2E7D5E) : const Color(0xFF143427);
  }

  // ✅ ألوان الوضع الليلي الرصاصي الغامق الفخم والأنيق
  Color _bgColor(bool isDark) =>
      isDark ? const Color(0xFF1E2125) : const Color(0xFFFAF5ED);
  Color _cardColor(bool isDark) =>
      isDark ? const Color(0xFF282C32) : const Color(0xFFFCFAF7);
  Color _cardNestedColor(bool isDark) =>
      isDark ? const Color(0xFF21252A) : const Color(0xFFF7F3ED);
  Color _borderColor(bool isDark) =>
      isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE);
  Color _textColor(bool isDark) =>
      isDark ? const Color(0xFFF0F2F5) : const Color(0xFF38291D);
  Color _subtextColor(bool isDark) =>
      isDark ? const Color(0xFFA6AFB8) : const Color(0xFF736152);

  // ✅ مساعد اللوكاليزيشن الآمن مع قيمة افتراضية
  String _t(String key, String fallback, {List<String>? args}) {
    try {
      final translated = key.tr(args: args);
      if (translated != key && translated.isNotEmpty) {
        return translated;
      }
    } catch (_) {}
    if (args != null && args.isNotEmpty) {
      var res = fallback;
      for (final arg in args) {
        res = res.replaceFirst('{}', arg);
      }
      return res;
    }
    return fallback;
  }

  @override
  void initState() {
    super.initState();
    _loadActiveKhatmah();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadActiveKhatmah() async {
    setState(() => _isLoading = true);
    final khatmah = await KhatmahManager.getActiveKhatmah();
    if (mounted) {
      setState(() {
        _activeKhatmah = khatmah;
        if (khatmah != null) {
          _selectedJuz = khatmah.targetJuzForToday;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _startNewKhatmah() async {
    final title = _titleController.text.trim().isEmpty
        ? _t('khatmah_default_title', 'ختمتي المباركة')
        : _titleController.text.trim();

    final newKhatmah = KhatmahModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      targetDays: _selectedTargetDays,
      startDate: DateTime.now(),
      completedJuz: [],
      currentJuz: 1,
    );

    await KhatmahManager.saveKhatmah(newKhatmah);
    await _loadActiveKhatmah();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'khatmah_started_success',
              '🌿 بارك الله فيك، تم بدء ختمة جديدة بنجاح! نسأل الله التيسير والقبول.',
            ),
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
          ),
          backgroundColor: _primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _selectJuz(int juzNumber) {
    setState(() {
      _selectedJuz = juzNumber;
    });
  }

  Future<void> _toggleSelectedJuzCompletion() async {
    final khatmah = _activeKhatmah;
    if (khatmah == null) return;

    final target = _selectedJuz.clamp(1, 30);
    final isDone = khatmah.completedJuz.contains(target);
    KhatmahModel? updated;

    if (isDone) {
      updated = await KhatmahManager.unmarkJuzDone(target);
      if (mounted && updated != null) {
        setState(() => _activeKhatmah = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t('khatmah_unmark_juz', 'تم إلغاء تحديد إكمال الجزء $target',
                  args: ['$target']),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF6B4423),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      updated = await KhatmahManager.markJuzDone(target);
      if (mounted && updated != null) {
        setState(() => _activeKhatmah = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                'khatmah_mark_juz_success',
                'تقبل الله طاعتك! تم تسجيل قراءة الجزء $target بنجاح ✅',
                args: ['$target'],
              ),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF2E7D5E),
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (updated.isCompleted) {
          _showCompletionDialog();
        }
      }
    }
  }

  void _showCompletionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardColor(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: _borderColor(isDark)),
        ),
        title: Row(
          children: [
            Icon(
              Icons.stars_rounded,
              color: isDark ? const Color(0xFF48BB78) : const Color(0xFF2E7D5E),
              size: 28.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                _t('khatmah_congrats_title', 'مبارك ختم القرآن الكريم!'),
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: _textColor(isDark),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          _t(
            'khatmah_congrats_desc',
            'هنيئاً لك ختم كتاب الله عز وجل، نسأل الله أن يجعله نوراً لك في الدنيا والآخرة وشفيعاً لك يوم القيامة.\n\nيمكنك الآن قراءة دعاء ختم القرآن.',
          ),
          style: TextStyle(
            fontSize: 13.5.sp,
            height: 1.6,
            color: _subtextColor(isDark),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              _t('khatmah_close', 'إغلاق'),
              style: TextStyle(color: _subtextColor(isDark)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _showDuaaKhatmSheet();
            },
            child: Text(_t('khatmah_duaa_title', 'دعاء ختم القرآن')),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteKhatmah() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardColor(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: _borderColor(isDark)),
        ),
        title: Text(
          _t('khatmah_reset_title', 'إعادة ضبط الختمة'),
          style: TextStyle(
            color: _textColor(isDark),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          _t(
            'khatmah_reset_confirm',
            'هل تريد بالتأكيد إنهاء هذه الختمة وبدء ختمة جديدة؟ ستفقد التقدم الحالي.',
          ),
          style: TextStyle(color: _subtextColor(isDark), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              _t('khatmah_cancel', 'إلغاء'),
              style: TextStyle(color: _subtextColor(isDark)),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await KhatmahManager.deleteKhatmah();
              await _loadActiveKhatmah();
            },
            child: Text(_t('khatmah_finish_btn', 'إنهاء الختمة')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bgColor(isDark),
        body: Stack(
          children: [
            // الخلفية الفنية للمساجد في الجزء العلوي مع تدرج اندماجي
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 220.h,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.22 : 0.65),
                      Colors.white.withValues(alpha: isDark ? 0.08 : 0.35),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.65, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  AssetsData.headerMosqueBg,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),

            // المحتوى مع شريط العنوان العلوي
            SafeArea(
              child: Column(
                children: [
                  _buildTopAppBar(isDark),
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: _primaryColor,
                            ),
                          )
                        : _activeKhatmah == null
                            ? _buildCreateKhatmahView(isDark)
                            : _buildActiveKhatmahView(isDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // شريط العنوان العلوي الأنيق المتوافق مع الهوية
  // ==============================================================
  Widget _buildTopAppBar(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الرجوع في أقصى اليمين (في الواجهة العربية) ويشير دائماً لليسار (<)
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? const Color(0xFFF0F2F5) : const Color(0xFF38291D),
              size: 20.sp,
            ),
            tooltip: 'رجوع',
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
          ),

          // العنوان في المنتصف مع الزخرفة الإسلامية (خط فاصل ومسجد)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _t('khatmah_screen_title', 'ختمة القرآن الكريم'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF0F2F5) : const Color(0xFF38291D),
                  ),
                ),
                SizedBox(height: 5.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32.w,
                      height: 1.h,
                      color: isDark ? const Color(0xFF383E46) : const Color(0xFFC7B9A9),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Icon(
                        Icons.mosque_outlined,
                        size: 13.sp,
                        color: _primaryColor,
                      ),
                    ),
                    Container(
                      width: 32.w,
                      height: 1.h,
                      color: isDark ? const Color(0xFF383E46) : const Color(0xFFC7B9A9),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // الجانب الأيسر: الإجراءات عند وجود ختمة جارية أو مساحة فارغة للتوسيط التام
          if (_activeKhatmah != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.menu_book_outlined,
                    color: isDark ? const Color(0xFFF0F2F5) : const Color(0xFF38291D),
                    size: 22.sp,
                  ),
                  tooltip: _t('khatmah_duaa_title', 'دعاء ختم القرآن'),
                  onPressed: _showDuaaKhatmSheet,
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: isDark ? const Color(0xFFF0F2F5) : const Color(0xFF38291D),
                    size: 22.sp,
                  ),
                  tooltip: _t('khatmah_reset_title', 'إعادة ضبط الختمة'),
                  onPressed: _confirmDeleteKhatmah,
                ),
              ],
            )
          else
            SizedBox(width: 48.w),
        ],
      ),
    );
  }

  // ==============================================================
  // 1. شاشة إنشاء خطة ختمة جديدة (مطابقة للتصميم بدقة)
  // ==============================================================
  Widget _buildCreateKhatmahView(bool isDark) {
    final partsPerDay = 30.0 / _selectedTargetDays;
    final ahzabPerDay = 60.0 / _selectedTargetDays;
    final pagesPerDay = (604.0 / _selectedTargetDays).ceil();
    final pagesPerPrayer = (pagesPerDay / 5.0).ceil();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // البطاقة الفاخرة لختم كتاب الله (Hero Card)
          _buildHeroCard(isDark),
          SizedBox(height: 18.h),

          // بطاقة عنوان الختمة
          _buildTitleInputCard(isDark),
          SizedBox(height: 20.h),

          // اختيار مدة الختمة بالأيام
          _buildDaysSelector(isDark),
          SizedBox(height: 22.h),

          // بطاقة خطة وردك اليومي المقترح
          _buildCalculationCard(
            isDark,
            partsPerDay: partsPerDay,
            ahzabPerDay: ahzabPerDay,
            pagesPerDay: pagesPerDay,
            pagesPerPrayer: pagesPerPrayer,
          ),
          SizedBox(height: 24.h),

          // زر بدء الختمة المباركة
          _buildStartButton(isDark),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  // البطاقة الترويجية الخضراء الفاخرة
  Widget _buildHeroCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E4636), const Color(0xFF16382B)]
              : [const Color(0xFF1F4838), const Color(0xFF143427)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark ? const Color(0xFF2E634E).withValues(alpha: 0.6) : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF143427).withValues(alpha: isDark ? 0.35 : 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            // زخرفة القوس الإسلامي الرقيقة خلف المصحف
            Positioned(
              left: 12.w,
              top: 10.h,
              bottom: 0,
              width: 120.w,
              child: CustomPaint(
                painter: _IslamicArchPainter(
                  strokeColor: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),

            // محتوى البطاقة الداخلي
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
              child: Row(
                children: [
                  // الجانب الأيمن: شارة ابدأ خطتك والنصوص
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // شارة "ابدأ خطتك"
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 4.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2E7D5E).withValues(alpha: 0.35)
                                : const Color(0xFFF5EFE3),
                            borderRadius: BorderRadius.circular(20.r),
                            border: isDark
                                ? Border.all(color: const Color(0xFF48BB78).withValues(alpha: 0.4))
                                : null,
                          ),
                          child: Text(
                            _t('khatmah_start_plan', 'ابدأ خطتك'),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF81E6D9) : const Color(0xFF143427),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // العنوان الرئيسي "لختم كتاب الله"
                        Text(
                          _t('khatmah_seal_quran', 'لختم كتاب الله'),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // النص التوضيحي
                        Text(
                          _t(
                            'khatmah_hero_desc',
                            'حدد المدة المناسبة لك وستحسب لك وردك اليومي بالصفحات والأجزاء والأحزاب.',
                          ),
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 14.w),

                  // الجانب الأيسر: مجسم المصحف الشريف ثلاثي الأبعاد
                  Container(
                    width: 105.w,
                    height: 98.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.asset(
                        AssetsData.quran3dBook,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بطاقة حقل عنوان الختمة
  Widget _buildTitleInputCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _cardColor(isDark),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: _borderColor(isDark),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _t('khatmah_plan_title', 'عنوان الختمة'),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.bold,
              color: _textColor(isDark),
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: _cardNestedColor(isDark),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: _borderColor(isDark),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: isDark ? const Color(0xFF717D8A) : const Color(0xFF7D6B5C),
                  size: 20.sp,
                ),
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: _textColor(isDark),
                    ),
                    decoration: InputDecoration(
                      hintText: _t('khatmah_title_hint', 'مثال: ختمة رمضان المبارك'),
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? const Color(0xFF717D8A) : const Color(0xFF8C7A6B),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 10.h,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_left_rounded,
                  color: isDark ? const Color(0xFF717D8A) : const Color(0xFF7D6B5C),
                  size: 22.sp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // قسم اختيار الأيام
  Widget _buildDaysSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _t('khatmah_choose_duration', 'في كم يوماً تريد ختم القرآن؟'),
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: _textColor(isDark),
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 10.h,
          children: _presetDays
              .map((days) => _buildDayPill(days, isDark))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDayPill(int days, bool isDark) {
    final isSelected = _selectedTargetDays == days;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedTargetDays = days),
        borderRadius: BorderRadius.circular(22.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF2E7D5E) : const Color(0xFF143427))
                : _cardColor(isDark),
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: isSelected
                  ? (isDark ? const Color(0xFF48BB78) : const Color(0xFF143427))
                  : _borderColor(isDark),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF143427).withValues(alpha: isDark ? 0.4 : 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.ltr,
            children: [
              Text(
                _t('khatmah_days_count', '$days يوماً', args: ['$days']),
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? const Color(0xFFD0D5DD) : const Color(0xFF38291D)),
                ),
              ),
              if (isSelected) ...[
                SizedBox(width: 6.w),
                Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // بطاقة خطة الورد اليومي المقترح
  Widget _buildCalculationCard(
    bool isDark, {
    required double partsPerDay,
    required double ahzabPerDay,
    required int pagesPerDay,
    required int pagesPerPrayer,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _cardColor(isDark),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: _borderColor(isDark),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate_outlined,
                color: isDark ? const Color(0xFF48BB78) : const Color(0xFF736152),
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _t('khatmah_plan_summary', 'خطة وردك اليومي المقترح:'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: _textColor(isDark),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // المقدار بالأجزاء
          _buildPlanMetricRow(
            icon: Icons.menu_book_rounded,
            title: _t('khatmah_parts_per_day', 'المقدار بالأجزاء:'),
            value: _t(
              'khatmah_juz_daily',
              partsPerDay >= 1
                  ? '${partsPerDay.toStringAsFixed(1)} جزء يومياً'
                  : '${partsPerDay.toStringAsFixed(2)} جزء يومياً',
              args: [
                partsPerDay >= 1
                    ? partsPerDay.toStringAsFixed(1)
                    : partsPerDay.toStringAsFixed(2),
              ],
            ),
            isDark: isDark,
          ),
          SizedBox(height: 10.h),

          // المقدار بالأحزاب
          _buildPlanMetricRow(
            icon: Icons.bookmark_rounded,
            title: _t('khatmah_ahzab_per_day', 'المقدار بالأحزاب:'),
            value: _t(
              'khatmah_hizb_daily',
              '${ahzabPerDay.toStringAsFixed(1)} حزب يومياً',
              args: [ahzabPerDay.toStringAsFixed(1)],
            ),
            isDark: isDark,
          ),
          SizedBox(height: 10.h),

          // المقدار بالصفحات
          _buildPlanMetricRow(
            icon: Icons.grid_view_rounded,
            title: _t('khatmah_pages_per_day', 'المقدار بالصفحات:'),
            value: _t(
              'khatmah_page_daily',
              '$pagesPerDay صفحة في اليوم',
              args: ['$pagesPerDay'],
            ),
            isDark: isDark,
          ),

          // فاصل
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(
              color: _borderColor(isDark),
              height: 1,
              thickness: 1,
            ),
          ),

          // نصيحة تيسير
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 19.sp,
                color: isDark ? const Color(0xFF48BB78) : const Color(0xFF736152),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _t(
                    'khatmah_tip',
                    'نصيحة تيسير: اقرأ $pagesPerPrayer صفحات بعد كل صلاة مفروضة وستختم بسهولة بإذن الله.',
                    args: ['$pagesPerPrayer'],
                  ),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _subtextColor(isDark),
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanMetricRow({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 19.sp,
                color: isDark ? const Color(0xFF48BB78) : const Color(0xFF736152),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    color: _subtextColor(isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.bold,
            color: _textColor(isDark),
          ),
        ),
      ],
    );
  }

  // زر بدء الختمة المباركة
  Widget _buildStartButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _startNewKhatmah,
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: _primaryColor,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
                SizedBox(width: 10.w),
                Flexible(
                  child: Text(
                    _t('khatmah_start_button', 'بدء الختمة المباركة'),
                    style: TextStyle(
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '🌿',
                  style: TextStyle(
                    fontSize: 17.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // 2. شاشة متابعة الختمة الجارية
  // ==============================================================
  Widget _buildActiveKhatmahView(bool isDark) {
    final khatmah = _activeKhatmah!;
    final currentSelectedJuz = _selectedJuz.clamp(1, 30);
    final juzMeta = KhatmahManager.getJuz(currentSelectedJuz);
    final isSelectedDone = khatmah.completedJuz.contains(currentSelectedJuz);
    final isTodayTarget = currentSelectedJuz == khatmah.targetJuzForToday;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🏆 Hero Progress Card
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E4636), const Color(0xFF16382B)]
                    : [const Color(0xFF1F4838), const Color(0xFF143427)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(
                color: isDark ? const Color(0xFF2E634E).withValues(alpha: 0.6) : Colors.transparent,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF143427).withValues(alpha: isDark ? 0.4 : 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        khatmah.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        _t(
                          'khatmah_days_plan',
                          'خطة ${khatmah.targetDays} يوماً',
                          args: ['${khatmah.targetDays}'],
                        ),
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),

                // Progress Bar & Percentage
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _t('khatmah_progress_percentage', 'نسبة الإنجاز'),
                      style: TextStyle(fontSize: 13.sp, color: Colors.white70),
                    ),
                    Text(
                      '${khatmah.percentage}%',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: khatmah.progress,
                    minHeight: 10.h,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF48BB78), // أخضر زمردي جميل ومشرق
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Counters Row
                Row(
                  children: [
                    Expanded(
                      child: _buildHeroStat(
                        title: _t('khatmah_days_passed', 'الأيام المنقضية'),
                        value: '${khatmah.daysPassed} / ${khatmah.targetDays}',
                      ),
                    ),
                    Container(width: 1, height: 26.h, color: Colors.white24),
                    Expanded(
                      child: _buildHeroStat(
                        title: _t('khatmah_completed_juz_stat', 'الأجزاء المكتملة'),
                        value: _t(
                          'khatmah_completed_of_30',
                          '${khatmah.completedJuz.length} من 30',
                          args: ['${khatmah.completedJuz.length}'],
                        ),
                      ),
                    ),
                    Container(width: 1, height: 26.h, color: Colors.white24),
                    Expanded(
                      child: _buildHeroStat(
                        title: _t('khatmah_days_remaining', 'الأيام المتبقية'),
                        value: _t(
                          'khatmah_days_remaining_val',
                          '${khatmah.daysRemaining} يوم',
                          args: ['${khatmah.daysRemaining}'],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),

          // 📖 Today's / Selected Portion Card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: _cardColor(isDark),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelectedDone
                    ? const Color(0xFF38A169)
                    : (isDark ? const Color(0xFF383E46) : _primaryColor.withValues(alpha: 0.4)),
                width: 1.5.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            isSelectedDone
                                ? Icons.check_circle_rounded
                                : (isTodayTarget
                                    ? Icons.calendar_today_rounded
                                    : Icons.menu_book_rounded),
                            color: isSelectedDone
                                ? const Color(0xFF38A169)
                                : _primaryColor,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              isTodayTarget
                                  ? _t(
                                      'khatmah_today_ward',
                                      'ورد اليوم (اليوم ${khatmah.daysPassed}) • الجزء $currentSelectedJuz',
                                      args: [
                                        '${khatmah.daysPassed}',
                                        '$currentSelectedJuz'
                                      ],
                                    )
                                  : _t(
                                      'khatmah_juz_portion',
                                      'الجزء $currentSelectedJuz من الختمة',
                                      args: ['$currentSelectedJuz'],
                                    ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.bold,
                                color: _textColor(isDark),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelectedDone
                            ? Colors.green.withValues(alpha: 0.15)
                            : _cardNestedColor(isDark),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isSelectedDone
                              ? Colors.green.withValues(alpha: 0.3)
                              : _borderColor(isDark),
                        ),
                      ),
                      child: Text(
                        isSelectedDone
                            ? _t('khatmah_read_done_badge', 'تمت القراءة ✅')
                            : _t('khatmah_in_progress_badge', 'قيد القراءة 📖'),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelectedDone
                              ? Colors.green.shade600
                              : _subtextColor(isDark),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  _t(
                    'khatmah_from_surah',
                    'الجزء $currentSelectedJuz: من سورة ${juzMeta.startSurah} (آية ${juzMeta.startAyah}) إلى سورة ${juzMeta.endSurah} (آية ${juzMeta.endAyah})',
                    args: [
                      '$currentSelectedJuz',
                      juzMeta.startSurah,
                      '${juzMeta.startAyah}',
                      juzMeta.endSurah,
                      '${juzMeta.endAyah}'
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF48BB78) : _primaryColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _t(
                    'khatmah_pages_range',
                    'الصفحات من ص ${juzMeta.startPage} إلى ص ${juzMeta.endPage} (${juzMeta.endPage - juzMeta.startPage + 1} صفحة)',
                    args: [
                      '${juzMeta.startPage}',
                      '${juzMeta.endPage}',
                      '${juzMeta.endPage - juzMeta.startPage + 1}'
                    ],
                  ),
                  style: TextStyle(fontSize: 12.sp, color: _subtextColor(isDark)),
                ),
                SizedBox(height: 14.h),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuranSectionDetailScreen.juz(
                                juzNumber: currentSelectedJuz,
                                customRangeDescription:
                                    'من سورة ${juzMeta.startSurah} (آية ${juzMeta.startAyah}) إلى سورة ${juzMeta.endSurah} (آية ${juzMeta.endAyah})',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.menu_book_rounded, size: 18),
                        label: Text(_t('khatmah_read_now', 'اقرأ الورد الآن')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _toggleSelectedJuzCompletion,
                        icon: Icon(
                          isSelectedDone
                              ? Icons.check
                              : Icons.done_all_rounded,
                          size: 18,
                        ),
                        label: Text(
                          isSelectedDone
                              ? _t('khatmah_completed_btn', 'تمت القراءة')
                              : _t('khatmah_complete_ward_btn', 'أكملت الورد'),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isSelectedDone
                              ? const Color(0xFF38A169)
                              : (isDark ? const Color(0xFF48BB78) : _primaryColor),
                          side: BorderSide(
                            color: isSelectedDone
                                ? const Color(0xFF38A169)
                                : (isDark ? const Color(0xFF48BB78) : _primaryColor),
                            width: 1.5,
                          ),
                          backgroundColor: isSelectedDone
                              ? (isDark ? const Color(0xFF1B3D2B) : Colors.green.withValues(alpha: 0.08))
                              : Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // 🗺️ 30 Juz Map Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _t('khatmah_map_title', 'خريطة أجزاء القرآن الكريم (30 جزءاً)'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: _textColor(isDark),
                  ),
                ),
              ),
              Text(
                _t('khatmah_map_hint', 'اضغط لعرض وقراءة الجزء'),
                style: TextStyle(fontSize: 11.5.sp, color: _subtextColor(isDark)),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 30,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final juzNum = index + 1;
              final isDone = khatmah.completedJuz.contains(juzNum);
              final isSelected = currentSelectedJuz == juzNum;
              final isToday = khatmah.targetJuzForToday == juzNum;

              return InkWell(
                onTap: () => _selectJuz(juzNum),
                borderRadius: BorderRadius.circular(12.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isDone
                        ? (isDark ? const Color(0xFF1B3D2B) : const Color(0xFFE8F5E9))
                        : (isSelected
                            ? (isDark
                                ? const Color(0xFF2E7D5E).withValues(alpha: 0.25)
                                : const Color(0xFF143427).withValues(alpha: 0.12))
                            : _cardColor(isDark)),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? (isDark ? const Color(0xFF48BB78) : const Color(0xFF143427))
                          : (isDone
                              ? (isDark ? const Color(0xFF2E7D5E) : Colors.green.shade600)
                              : _borderColor(isDark)),
                      width: isSelected ? 2.2.w : 1.w,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _t('khatmah_juz_short', 'جزء'),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: isDone
                                  ? (isDark ? const Color(0xFF48BB78) : Colors.green.shade800)
                                  : _subtextColor(isDark),
                            ),
                          ),
                          Text(
                            '$juzNum',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: isDone
                                  ? (isDark ? const Color(0xFF48BB78) : Colors.green.shade800)
                                  : (isSelected
                                      ? (isDark ? const Color(0xFF48BB78) : const Color(0xFF143427))
                                      : _textColor(isDark)),
                            ),
                          ),
                          if (isDone)
                            Icon(
                              Icons.check,
                              size: 14.sp,
                              color: isDark ? const Color(0xFF48BB78) : Colors.green.shade700,
                            )
                          else if (isToday)
                            Icon(
                              Icons.bookmark_rounded,
                              size: 14.sp,
                              color: _primaryColor,
                            )
                          else
                            SizedBox(height: 14.sp),
                        ],
                      ),
                      if (isSelected)
                        Positioned(
                          top: 4.h,
                          right: 4.w,
                          child: Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF48BB78) : const Color(0xFF143427),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24.h),

          // دعاء ختم القرآن
          ElevatedButton.icon(
            onPressed: _showDuaaKhatmSheet,
            icon: const Icon(Icons.menu_book_rounded),
            label: Text(_t('khatmah_duaa_button', 'قراءة دعاء ختم القرآن الكريم 🤲')),
            style: ElevatedButton.styleFrom(
              backgroundColor: _cardColor(isDark),
              foregroundColor: isDark ? const Color(0xFF48BB78) : _primaryColor,
              elevation: 0,
              side: isDark ? BorderSide(color: _borderColor(isDark)) : null,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildHeroStat({required String title, required String value}) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 11.sp, color: Colors.white70),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void _showDuaaKhatmSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF22262B) : const Color(0xFFFAF5ED),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: isDark ? Border.all(color: _borderColor(isDark)) : null,
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                _t('khatmah_duaa_title', 'دعاء ختم القرآن الكريم'),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF48BB78) : const Color(0xFF143427),
                ),
              ),
              Divider(
                height: 24,
                color: isDark ? _borderColor(isDark) : null,
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    'اللَّهُمَّ ارْحَمْنِي بالقُرْءَانِ وَاجْعَلهُ لِي إِمَاماً وَنُوراً وَهُدًى وَرَحْمَةً.\n\n'
                    'اللَّهُمَّ ذَكِّرْنِي مِنْهُ مَا نَسِيتُ وَعَلِّمْنِي مِنْهُ مَا جَهِلْتُ وَارْزُقْنِي تِلاَوَتَهُ آنَاءَ اللَّيْلِ وَأَطْرَافَ النَّهَارِ وَاجْعَلْهُ لِي حُجَّةً يَا رَبَّ العَالَمِينَ.\n\n'
                    'اللَّهُمَّ أَصْلِحْ لِي دِينِي الَّذِي هُوَ عِصْمَةُ أَمْرِي، وَأَصْلِحْ لِي دُنْيَايَ الَّتِي فِيهَا مَعَاشِي، وَأَصْلِحْ لِي آخِرَتِي الَّتِي فِيهَا مَعَادِي، وَاجْعَلِ الحَيَاةَ زِيَادَةً لِي فِي كُلِّ خَيْرٍ وَاجْعَلِ المَوْتَ رَاحَةً لِي مِنْ كُلِّ شَرٍّ.\n\n'
                    'اللَّهُمَّ اجْعَلْ خَيْرَ عُمْرِي آخِرَهُ وَخَيْرَ عَمَلِي خَوَاتِمهُ وَخَيْرَ أَيَّامِي يَوْمَ أَلْقَاكَ فِيهِ.\n\n'
                    'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِيشَةً هَنِيَّةً وَمِيتَةً سَوِيَّةً وَمَرَدّاً غَيْرَ مُخْزٍ وَلاَ فَاضِحٍ.\n\n'
                    'اللَّهُمَّ لاَ تَدَعْ لَنَا ذَنْباً إِلاَّ غَفَرْتَهُ وَلاَ هَمَّاً إِلاَّ فَرَّجْتَهُ وَلاَ دَيْناً إِلاَّ قَضَيْتَهُ وَلاَ حَاجَةً مِنْ حَوَائِجِ الدُّنْيَا وَالآخِرَةِ إِلاَّ قَضَيْتَهَا يَا أَرْحَمَ الرَّاحِمِينَ.\n\n'
                    'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ، وَصَلَّى اللهُ عَلَى نَبِيِّنَا مُحَمَّدٍ وَعَلَى آلِهِ وَصَحْبِهِ وَسَلَّمَ تَسْلِيماً كَثِيراً.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 2.0,
                      fontWeight: FontWeight.w500,
                      color: _textColor(isDark),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IslamicArchPainter extends CustomPainter {
  final Color strokeColor;
  const _IslamicArchPainter({required this.strokeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    path.moveTo(0, h);
    path.lineTo(0, h * 0.45);
    path.cubicTo(0, h * 0.15, cx - 18, 5, cx, 0);
    path.cubicTo(cx + 18, 5, w, h * 0.15, w, h * 0.45);
    path.lineTo(w, h);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
