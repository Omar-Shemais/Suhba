import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/core/constants/assets.dart';
import 'package:islamic_app/core/utils/service_locator.dart';
import '../../data/models/audio_model.dart';
import '../../data/repositories/audio_repo.dart';
import '../widgets/radio_station_card.dart';

class RadioCategoryItem {
  final String id;
  final String title;
  final IconData icon;

  const RadioCategoryItem({
    required this.id,
    required this.title,
    required this.icon,
  });
}

class RadioViewBody extends StatefulWidget {
  const RadioViewBody({super.key});

  @override
  State<RadioViewBody> createState() => _RadioViewBodyState();
}

class _RadioViewBodyState extends State<RadioViewBody> {
  final TextEditingController _searchController = TextEditingController();
  List<RadioStationModel> _allStations = [];
  List<RadioStationModel> _filteredStations = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedCategory = 'quran';

  static const List<RadioCategoryItem> _categories = [
    RadioCategoryItem(
      id: 'quran',
      title: 'القرآن الكريم',
      icon: Icons.menu_book_rounded,
    ),
    RadioCategoryItem(
      id: 'hadith',
      title: 'الأحاديث النبوية',
      icon: Icons.mosque_rounded,
    ),
    RadioCategoryItem(
      id: 'azkar',
      title: 'أذكار الصباح',
      icon: Icons.wb_sunny_rounded,
    ),
  ];

  Color get _primaryColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF2E7D5E) : const Color(0xFF143427);
  }

  @override
  void initState() {
    super.initState();
    _fetchStations();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchStations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stations = await getIt<AudioRepository>().getRadioStations();
      if (mounted) {
        setState(() {
          _allStations = stations;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    // 1. فلترة حسب التصنيف المختار
    var list = _allStations
        .where((s) => s.category == _selectedCategory)
        .toList();

    // بالنسبة لقسم الأذكار
    if (_selectedCategory == 'azkar') {
      list = list.where((s) {
        final text = '${s.name} ${s.arabicName}'.toLowerCase();
        return text.contains('صباح') ||
            text.contains('مساء') ||
            text.contains('رقية') ||
            text.contains('الرقية');
      }).take(3).toList();
    } else if (_selectedCategory == 'quran') {
      list = list.take(20).toList();
    } else {
      list = list.take(15).toList();
    }

    // 2. فلترة بالبحث النصي إن وجد
    if (query.isNotEmpty) {
      list = list.where((station) {
        final arabic = station.arabicName.toLowerCase();
        final name = station.name.toLowerCase();
        return arabic.contains(query) || name.contains(query);
      }).toList();
    }

    setState(() {
      _filteredStations = list;
    });
  }

  void _onCategorySelected(String categoryId) {
    if (_selectedCategory == categoryId) return;
    setState(() {
      _selectedCategory = categoryId;
    });
    _applyFilters();
  }

  int _getCategoryCount(String categoryId) {
    if (categoryId == 'azkar') {
      return _allStations
          .where((s) => s.category == 'azkar')
          .where((s) {
            final text = '${s.name} ${s.arabicName}'.toLowerCase();
            return text.contains('صباح') ||
                text.contains('مساء') ||
                text.contains('رقية') ||
                text.contains('الرقية');
          })
          .take(3)
          .length;
    }
    if (categoryId == 'quran') {
      return _allStations
          .where((s) => s.category == 'quran')
          .take(20)
          .length;
    }
    return _allStations
        .where((s) => s.category == categoryId)
        .take(15)
        .length;
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          // خلفية المساجد الفنية في الجزء العلوي بتدرج ناعم
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
                    Colors.white.withValues(alpha: isDark ? 0.35 : 0.65),
                    Colors.white.withValues(alpha: isDark ? 0.15 : 0.35),
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

          // المحتوى
          SafeArea(
            child: Column(
              children: [
                // شريط العنوان العلوي الأنيق
                _buildTopAppBar(isDark),
                SizedBox(height: 12.h),

                // تصنيفات الإذاعات
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: _buildCategoryChips(isDark),
                ),
                SizedBox(height: 14.h),

                // شريط البحث المقوس
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: _buildSearchBar(isDark),
                ),
                SizedBox(height: 10.h),

                // سطر عدد الإذاعات المتاحة
                if (!_isLoading && _errorMessage == null)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '(${_toArabicDigits(_filteredStations.length)}) إذاعة متاحة',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF8C7A6B),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          Text(
                            'نتائج البحث',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                SizedBox(height: 10.h),

                // قائمة الإذاعات
                Expanded(
                  child: _buildBody(isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // شريط العنوان العلوي (سهم الرجوع + العنوان والزخرفة الإسلامية)
  // ==============================================================
  Widget _buildTopAppBar(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الرجوع في أقصى اليمين (في الواجهة العربية)
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : const Color(0xFF38291D),
              size: 20.sp,
            ),
            tooltip: 'رجوع',
            onPressed: () => Navigator.of(context).pop(),
          ),

          // العنوان في المنتصف مع الزخرفة الإسلامية
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'الراديو',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF38291D),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32.w,
                      height: 1.h,
                      color: isDark ? Colors.white24 : const Color(0xFFC7B9A9),
                    ),
                    SizedBox(width: 4.w),
                    Container(
                      width: 3.5.r,
                      height: 3.5.r,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : const Color(0xFFC7B9A9),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.mosque_rounded,
                      size: 15.sp,
                      color: isDark ? Colors.white54 : const Color(0xFF8C7A6B),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      width: 3.5.r,
                      height: 3.5.r,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : const Color(0xFFC7B9A9),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Container(
                      width: 32.w,
                      height: 1.h,
                      color: isDark ? Colors.white24 : const Color(0xFFC7B9A9),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // مساحة فارغة لضبط التوسيط
          SizedBox(width: 48.w),
        ],
      ),
    );
  }

  // ==============================================================
  // كبسولات التصنيفات (القرآن، الأحاديث، أذكار)
  // ==============================================================
  Widget _buildCategoryChips(bool isDark) {
    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat.id;
          final count = _getCategoryCount(cat.id);

          return GestureDetector(
            onTap: () => _onCategorySelected(cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? const Color(0xFF2E7D5E) : const Color(0xFF143427))
                    : (isDark ? const Color(0xFF282C32) : const Color(0xFFFCFAF7)),
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? const Color(0xFF2E7D5E) : const Color(0xFF143427))
                      : (isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE)),
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (isDark
                                  ? const Color(0xFF2E7D5E)
                                  : const Color(0xFF143427))
                              .withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat.icon,
                    size: 17.sp,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF736152)),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    cat.title,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : const Color(0xFF38291D)),
                    ),
                  ),
                  if (count > 0) ...[
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF5EFE3)
                            : (isDark
                                ? const Color(0xFF21252A)
                                : const Color(0xFFF2ECE3)),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        _toArabicDigits(count),
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? (isDark
                                  ? const Color(0xFF2E7D5E)
                                  : const Color(0xFF143427))
                              : (isDark ? Colors.white70 : const Color(0xFF736152)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==============================================================
  // شريط البحث المقوس
  // ==============================================================
  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF21252A) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: _searchController,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 13.5.sp,
          color: isDark ? Colors.white : const Color(0xFF38291D),
        ),
        decoration: InputDecoration(
          hintText: 'ابحث في هذا القسم...',
          hintStyle: TextStyle(
            color: isDark ? Colors.white38 : const Color(0xFF8C7A6B),
            fontSize: 13.sp,
          ),
          suffixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.white70 : const Color(0xFF38291D),
            size: 22.sp,
          ),
          prefixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          filled: false,
          contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ==============================================================
  // محتوى قائمة الإذاعات
  // ==============================================================
  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48.sp, color: Colors.grey),
            SizedBox(height: 12.h),
            Text(
              'تعذر تحميل الإذاعات، تأكد من الاتصال بالإنترنت',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: _fetchStations,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredStations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.radio, size: 48.sp, color: Colors.grey.shade400),
            SizedBox(height: 12.h),
            Text(
              'لا توجد إذاعة مطابقة للبحث في هذا القسم',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemCount: _filteredStations.length + 1, // +1 for bottom ornament
      itemBuilder: (context, index) {
        if (index == _filteredStations.length) {
          return _buildBottomOrnament(isDark);
        }
        final station = _filteredStations[index];
        return RadioStationCard(
          key: ValueKey('station_${station.id}_${station.url}'),
          station: station,
          index: index,
        );
      },
    );
  }

  Widget _buildBottomOrnament(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40.w,
            height: 1.h,
            color: isDark ? Colors.white24 : const Color(0xFFC7B9A9),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.mosque_rounded,
            size: 18.sp,
            color: isDark ? Colors.white38 : const Color(0xFF8C7A6B),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 40.w,
            height: 1.h,
            color: isDark ? Colors.white24 : const Color(0xFFC7B9A9),
          ),
        ],
      ),
    );
  }
}
