import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/assets.dart';
import 'package:islamic_app/core/widgets/custom_error_widget.dart';
import '../../data/models/hizb_model.dart';
import '../../data/models/juz_model.dart';
import '../../data/models/quran_models.dart';
import '../cubit/quran_cubit.dart';
import '../cubit/quran_state.dart';
import '../pages/quran_section_detail_screen.dart';
import '../pages/surah_detail_screen.dart';
import 'islamic_surah_badge.dart';
import 'quran_filter_tabs.dart';
import 'surah_list_item.dart';
import 'surah_loading_shimmer.dart';
import 'reciter_selector_dialog.dart';
import '../../data/repositories/audio_repo.dart';
import 'package:islamic_app/core/utils/service_locator.dart';
import '../../../prayer_times/presentation/widgets/home_quran_reading_card.dart';

class QuranViewBody extends StatefulWidget {
  const QuranViewBody({super.key});

  @override
  State<QuranViewBody> createState() => _QuranViewBodyState();
}

class _QuranViewBodyState extends State<QuranViewBody> {
  final TextEditingController _searchController = TextEditingController();
  QuranTabFilter _selectedFilter = QuranTabFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<QuranCubit>().preloadAllAjza();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SurahModel> _applyFilters(List<SurahModel> allSurahs) {
    List<SurahModel> filtered = allSurahs;

    // تصفية حسب نوع السورة
    if (_selectedFilter == QuranTabFilter.meccan) {
      filtered = filtered
          .where((s) => s.type.toLowerCase() == 'meccan')
          .toList();
    } else if (_selectedFilter == QuranTabFilter.medinan) {
      filtered = filtered
          .where((s) => s.type.toLowerCase() == 'medinan')
          .toList();
    }

    // تصفية حسب نص البحث
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((s) {
        final name = s.name.replaceAll(
          RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'),
          '',
        );
        final idStr = s.id.toString();
        return name.contains(query) ||
            s.name.contains(query) ||
            s.transliteration.toLowerCase().contains(query) ||
            idStr == query;
      }).toList();
    }

    return filtered;
  }

  List<JuzItem> _applyJuzFilters(List<JuzItem> allAjza) {
    if (_searchQuery.isEmpty) return allAjza;

    final query = _searchQuery
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .trim();

    return allAjza.where((juz) {
      final juzName = juz.name.replaceAll(
        RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'),
        '',
      );
      final surahName = juz.startSurahName.replaceAll(
        RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'),
        '',
      );
      final ayahText = juz.startAyahText.replaceAll(
        RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'),
        '',
      );
      final noStr = juz.number.toString();
      final arNoStr = _toArabicDigits(juz.number);

      return juzName.contains(query) ||
          surahName.contains(query) ||
          ayahText.contains(query) ||
          noStr == query ||
          arNoStr == query ||
          'جزء $noStr' == query ||
          'جزء $arNoStr' == query;
    }).toList();
  }

  List<HizbItem> _applyHizbFilters(List<HizbItem> allAhzab) {
    if (_searchQuery.isEmpty) return allAhzab;

    final query = _searchQuery
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .trim();

    return allAhzab.where((hizb) {
      final hizbName = hizb.name.replaceAll(
        RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'),
        '',
      );
      final surahName = hizb.startSurahName.replaceAll(
        RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'),
        '',
      );
      final ayahText = hizb.startAyahText.replaceAll(
        RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'),
        '',
      );
      final noStr = hizb.number.toString();
      final arNoStr = _toArabicDigits(hizb.number);

      return hizbName.contains(query) ||
          surahName.contains(query) ||
          ayahText.contains(query) ||
          noStr == query ||
          arNoStr == query ||
          'حزب $noStr' == query ||
          'حزب $arNoStr' == query;
    }).toList();
  }

  String _toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.tryParse(d) ?? 0])
        .join('');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF1E2125) : const Color(0xFFFAF5ED),
      child: Column(
        children: [
          // 1. الهيدر الفني البانورامي (المساجد، الفوانيس، زر الرجوع، الخط القرآني، وحقل البحث)
          _buildHeader(context, isDark),

          // بطاقة متابعة القراءة المتناسقة مع الثيم
          if (_searchQuery.isEmpty && _selectedFilter == QuranTabFilter.all) ...[
            Padding(
              padding: EdgeInsets.only(top: 8.h, bottom: 6.h),
              child: const HomeQuranReadingCard(),
            ),
          ],

          // 2. أزرار تصفية السور (الكل، مكية، مدنية، الجزء، الحزب)
          QuranFilterTabs(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),

          SizedBox(height: 4.h),

          // 3. قائمة السور أو الأجزاء أو الأحزاب
          Expanded(child: _buildCurrentList(isDark)),
        ],
      ),
    );
  }

  Widget _buildCurrentList(bool isDark) {
    if (_selectedFilter == QuranTabFilter.juz) {
      return _buildJuzList(isDark);
    } else if (_selectedFilter == QuranTabFilter.hizb) {
      return _buildHizbList(isDark);
    }
    return _buildSurahList(isDark);
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        // الخلفية الفنية الإسلامية للمساجد والفوانيس المضيئة
        Positioned.fill(
          child: ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: isDark ? 0.35 : 0.88),
                  Colors.white.withValues(alpha: isDark ? 0.15 : 0.45),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.68, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: Image.asset(
              AssetsData.quranHeaderBg,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),

        // المحتوى: زر الرجوع على اليمين، خط القرآن الكريم بالتشكيل، وحقل البحث
        Padding(
          padding: EdgeInsets.only(
            top: topPadding + 4.h,
            left: 16.w,
            right: 16.w,
            bottom: 10.h,
          ),
          child: Column(
            children: [
              // الصف العلوي: زر الرجوع على اليمين، والعنوان في المنتصف
              Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // زر الرجوع الدائري في أقصى اليمين (نفس مكان أيقونة الكتاب في الصورة المرجعية)
                    _buildBackButton(context, isDark),

                    // عنوان الشاشة في المنتصف بالخط الأميري الفاخر مع التشكيل
                    Text(
                      'القُرْآنُ الكَرِيم',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 34.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: isDark
                            ? const Color(0xFFF7ECE1)
                            : const Color(0xFF38291B),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),

                    // زر اختيار القارئ المتناسق مع الثيمات على اليسار
                    _buildReciterButton(context, isDark),
                  ],
                ),
              ),

              SizedBox(height: 10.h),

              // حقل البحث الدائري الأنيق
              _buildSearchBar(isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReciterButton(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showReciterSelector(context, getIt<AudioRepository>());
        },
        borderRadius: BorderRadius.circular(50.r),
        child: Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF282C32)
                : const Color(0xFFFCF9F3),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? const Color(0xFF383E46)
                  : const Color(0xFFEADBCE),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? 0.25 : 0.06,
                ),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.record_voice_over_rounded,
            size: 21.sp,
            color: isDark
                ? const Color(0xFFF7ECE1)
                : const Color(0xFF143427),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        borderRadius: BorderRadius.circular(50.r),
        child: Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF382A1E)
                : const Color(0xFFB58848).withValues(alpha: 0.88),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? const Color(0xFF5A4432)
                  : Colors.white.withValues(alpha: 0.45),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 19.sp,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF21252A)
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEFE8DA),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          fontSize: 14.sp,
          color: isDark ? const Color(0xFFF7ECE1) : const Color(0xFF38291B),
        ),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          hintText: 'ابحث في السور أو الآيات ...',
          hintStyle: TextStyle(
            fontSize: 13.5.sp,
            color: isDark ? const Color(0xFF9E8E81) : const Color(0xFF9E8E81),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? const Color(0xFF143427) : const Color(0xFF8C7A6B),
            size: 22.sp,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: isDark
                        ? const Color(0xFF143427)
                        : const Color(0xFF8C7A6B),
                    size: 18.sp,
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
        ),
      ),
    );
  }

  Widget _buildSurahList(bool isDark) {
    return BlocBuilder<QuranCubit, QuranState>(
      builder: (context, state) {
        if (state is QuranLoading) {
          return const SurahsloadingShimmer();
        }

        if (state is QuranError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: () => context.read<QuranCubit>().loadSurahs(),
          );
        }

        if (state is QuranLoaded) {
          final surahs = _applyFilters(state.surahs);

          if (surahs.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64.sp,
                      color: isDark
                          ? const Color(0xFF5A4432)
                          : const Color(0xFFC7B7A6),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'لا توجد سور مطابقة لبحثك',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFC7B7A6)
                            : const Color(0xFF8C7765),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF143427),
            onRefresh: () => context.read<QuranCubit>().loadSurahs(),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.only(bottom: 24.h, top: 4.h),
              itemCount: surahs.length,
              itemBuilder: (context, index) {
                final surah = surahs[index];
                return SurahListItem(
                  key: ValueKey('surah_${surah.id}'),
                  surah: surah,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SurahDetailScreen(surahId: surah.id),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildJuzList(bool isDark) {
    final ajza = _applyJuzFilters(JuzItem.ajza);

    if (ajza.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64.sp,
                color: isDark
                    ? const Color(0xFF5A4432)
                    : const Color(0xFFC7B7A6),
              ),
              SizedBox(height: 12.h),
              Text(
                'لا توجد أجزاء مطابقة لبحثك',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFC7B7A6)
                      : const Color(0xFF8C7765),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.only(bottom: 24.h, top: 4.h),
      itemCount: ajza.length,
      itemBuilder: (context, index) {
        final juz = ajza[index];

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.5.h),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        QuranSectionDetailScreen.juz(juzNumber: juz.number),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF241D18)
                      : const Color(0xFFFCF9F3),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF3A2E24)
                        : const Color(0xFFEFE8DA),
                    width: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.025,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      // 1. السهم في أقصى اليمين (مطابق لتصميم السور)
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14.sp,
                        color: isDark
                            ? const Color(0xFF9E8B7A)
                            : const Color(0xFF8C7A6B),
                      ),

                      SizedBox(width: 8.w),

                      // 2. الشارة الإسلامية المثمنة برقم الجزء
                      IslamicSurahBadge(
                        surahNumber: juz.number,
                        isDark: isDark,
                      ),

                      SizedBox(width: 14.w),

                      // 3. تفاصيل الجزء في المنتصف: اسم الجزء، سورة البداية، والآية القرآنية
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              juz.name,
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 18.5.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFFF7ECE1)
                                    : const Color(0xFF38291B),
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'يبدأ من: سورة ${juz.startSurahName}',
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFFB5A495)
                                    : const Color(0xFF8C7A6B),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              juz.startAyahText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF143427),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 4. المعلم الإسلامي الدائري في أقصى اليسار
                      _buildJuzEmblem(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHizbList(bool isDark) {
    final ahzab = _applyHizbFilters(HizbItem.ahzab);

    if (ahzab.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64.sp,
                color: isDark
                    ? const Color(0xFF5A4432)
                    : const Color(0xFFC7B7A6),
              ),
              SizedBox(height: 12.h),
              Text(
                'لا توجد أحزاب مطابقة لبحثك',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFC7B7A6)
                      : const Color(0xFF8C7765),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.only(bottom: 24.h, top: 4.h),
      itemCount: ahzab.length,
      itemBuilder: (context, index) {
        final hizb = ahzab[index];

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.5.h),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        QuranSectionDetailScreen.hizb(hizbNumber: hizb.number),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF241D18)
                      : const Color(0xFFFCF9F3),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF3A2E24)
                        : const Color(0xFFEFE8DA),
                    width: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.025,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      // 1. السهم في أقصى اليمين (مطابق لتصميم السور)
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14.sp,
                        color: isDark
                            ? const Color(0xFF9E8B7A)
                            : const Color(0xFF8C7A6B),
                      ),

                      SizedBox(width: 8.w),

                      // 2. الشارة الإسلامية المثمنة برقم الحزب
                      IslamicSurahBadge(
                        surahNumber: hizb.number,
                        isDark: isDark,
                      ),

                      SizedBox(width: 14.w),

                      // 3. تفاصيل الحزب: اسم الحزب، سورة البداية، ورقم الجزء
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${hizb.name} (${_toArabicDigits(hizb.number)})',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 18.5.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFFF7ECE1)
                                    : const Color(0xFF38291B),
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'سورة ${hizb.startSurahName} (آية ${_toArabicDigits(hizb.startAyah)}) • الجزء ${_toArabicDigits(hizb.juzNumber)}',
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFFB5A495)
                                    : const Color(0xFF8C7A6B),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              hizb.startAyahText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF143427),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 4. المعلم الإسلامي الدائري في أقصى اليسار
                      _buildJuzEmblem(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJuzEmblem(bool isDark) {
    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF21252A) : const Color(0xFFF5EFE3),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFE8DFCF),
          width: 1,
        ),
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26.r),
          child: Padding(
            padding: EdgeInsets.all(7.w),
            child: Image.asset(
              AssetsData.kaaba,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.menu_book_rounded,
                size: 24.sp,
                color: const Color(0xFF143427),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
