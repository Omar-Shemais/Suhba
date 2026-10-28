import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/features/quran/data/helpers/reciter_storage_manager.dart';
import 'package:islamic_app/features/quran/data/models/audio_model.dart';
import 'package:islamic_app/features/quran/data/repositories/audio_repo.dart';
import 'package:islamic_app/features/quran/presentation/cubit/audio_cubit.dart';

class ReciterSelector extends StatefulWidget {
  final AudioRepository audioRepository;

  const ReciterSelector({super.key, required this.audioRepository});

  @override
  State<ReciterSelector> createState() => _ReciterSelectorState();
}

class _ReciterSelectorState extends State<ReciterSelector> {
  List<ReciterModel> _reciters = [];
  List<ReciterModel> _filteredReciters = [];
  bool _isLoading = true;
  int _selectedReciterId = 2;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReciters();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredReciters = _reciters;
      } else {
        _filteredReciters = _reciters.where((r) {
          final ar = r.arabicName.toLowerCase();
          final en = r.name.toLowerCase();
          return ar.contains(query) || en.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadReciters() async {
    try {
      final reciters = await widget.audioRepository.getAllReciters();
      final savedReciterId = await ReciterStorageManager.getSelectedReciterId();

      if (mounted) {
        setState(() {
          _reciters = reciters;
          _filteredReciters = reciters;
          _selectedReciterId = savedReciterId;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.locale.languageCode == 'ar';

    final bgColor = isDark ? const Color(0xFF282C32) : const Color(0xFFFAF5ED);
    final borderColor = isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE);
    final titleColor = isDark ? const Color(0xFFF7ECE1) : const Color(0xFF38291B);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      padding: EdgeInsets.only(
        top: 14.h,
        left: 18.w,
        right: 18.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18.h,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
        border: Border(
          top: BorderSide(color: borderColor, width: 1.2),
          left: BorderSide(color: borderColor, width: 1.2),
          right: BorderSide(color: borderColor, width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. مقبض السحب العلوي (Handle Bar)
          Center(
            child: Container(
              width: 44.w,
              height: 4.5.h,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF48505B) : const Color(0xFFD6C8B8),
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // 2. الهيدر: عنوان إسلامي فخم وزر الإغلاق
          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(7.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF143427).withValues(alpha: isDark ? 0.35 : 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF143427).withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.record_voice_over_rounded,
                        size: 20.sp,
                        color: isDark ? const Color(0xFF2E7D5E) : const Color(0xFF143427),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'اختر القارئ' : 'Select Reciter',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 21.sp,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                        Text(
                          isArabic ? 'أصوات عذبة من كبار القرّاء' : 'Renowned Quran reciters',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: const Color(0xFF8C7A6B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(50.r),
                    child: Container(
                      padding: EdgeInsets.all(7.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF21252A) : const Color(0xFFF1E7D8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: borderColor,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 19.sp,
                        color: titleColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // 3. حقل البحث السريع بين القراء
          Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF21252A) : const Color(0xFFFCF9F3),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: TextField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: titleColor,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: isArabic ? 'ابحث عن اسم القارئ...' : 'Search reciters...',
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF8C7A6B),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20.sp,
                    color: const Color(0xFF8C7A6B),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, size: 18.sp, color: const Color(0xFF8C7A6B)),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // 4. قائمة القراء
          if (_isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (_filteredReciters.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30.h),
              child: Center(
                child: Text(
                  isArabic ? 'لم يتم العثور على قارئ بهذا الاسم' : 'No reciter found',
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    color: const Color(0xFF8C7A6B),
                  ),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: _filteredReciters.length,
                separatorBuilder: (context, index) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final reciter = _filteredReciters[index];
                  final isSelected = reciter.id == _selectedReciterId;

                  final cardBg = isSelected
                      ? (isDark ? const Color(0xFF1E382B) : const Color(0xFFEBF4EE))
                      : (isDark ? const Color(0xFF21252A) : const Color(0xFFFCF9F3));

                  final cardBorder = isSelected
                      ? (isDark ? const Color(0xFF2E7D5E) : const Color(0xFF143427))
                      : borderColor;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          _selectedReciterId = reciter.id;
                        });

                        // حفظ القارئ المختار
                        await ReciterStorageManager.saveSelectedReciter(
                          reciterId: reciter.id,
                          reciterName: reciter.name,
                          reciterArabicName: reciter.arabicName,
                        );

                        // تغيير القارئ في AudioCubit
                        if (context.mounted) {
                          context.read<AudioCubit>().changeReciter(reciter.id);
                        }

                        // إظهار رسالة نجاح منسجمة مع الثيم
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      isArabic
                                          ? 'تم اختيار الشيخ ${reciter.arabicName}'
                                          : 'Selected ${reciter.name}',
                                      style: TextStyle(
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF143427),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          );
                        }

                        // إغلاق الشيت بسلاسة
                        await Future.delayed(const Duration(milliseconds: 350));
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      borderRadius: BorderRadius.circular(16.r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 11.h,
                        ),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: cardBorder,
                            width: isSelected ? 1.6 : 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? (isSelected ? 0.25 : 0.08) : (isSelected ? 0.06 : 0.02),
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
                              // أيقونة القارئ
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF2E7D5E) : const Color(0xFF143427))
                                      : (isDark ? const Color(0xFF2C323A) : const Color(0xFFEFE8DD)),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isSelected ? Icons.record_voice_over_rounded : Icons.person_rounded,
                                  size: 20.sp,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : const Color(0xFF736152)),
                                ),
                              ),
                              SizedBox(width: 12.w),

                              // اسم القارئ والتفاصيل
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isArabic ? reciter.arabicName : reciter.name,
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 16.5.sp,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        color: isSelected
                                            ? (isDark ? Colors.white : const Color(0xFF143427))
                                            : titleColor,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      isArabic ? reciter.name : reciter.arabicName,
                                      style: TextStyle(
                                        fontSize: 11.5.sp,
                                        color: isSelected
                                            ? (isDark ? const Color(0xFF90C2A8) : const Color(0xFF2E6B4E))
                                            : const Color(0xFF8C7A6B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // علامة الاختيار
                              Container(
                                width: 22.w,
                                height: 22.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF2E7D5E) : const Color(0xFF143427))
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : (isDark ? const Color(0xFF4A535E) : const Color(0xFFD4C5B5)),
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check_rounded,
                                        size: 15.sp,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// Helper function to show the bottom sheet
void showReciterSelector(
  BuildContext context,
  AudioRepository audioRepository,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (bottomSheetContext) {
      return BlocProvider.value(
        value: context.read<AudioCubit>(),
        child: ReciterSelector(audioRepository: audioRepository),
      );
    },
  );
}
