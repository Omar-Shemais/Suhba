// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/features/quran/presentation/cubit/mushaf_cubit.dart';
import '../../data/helpers/mushaf_storage_helper.dart';
import '../../data/helpers/quran_reading_mode_helper.dart';
import '../../data/models/mushaf_models.dart';
import 'mushaf_page_widget.dart';
import 'quran_auto_scroll_sidebar.dart';
import 'quran_reading_mode_sheet.dart';

class MushafPageViewer extends StatefulWidget {
  final List<MushafPage> pages;
  final int currentPage;

  const MushafPageViewer({
    super.key,
    required this.pages,
    required this.currentPage,
  });

  @override
  State<MushafPageViewer> createState() => _MushafPageViewerState();
}

class _MushafPageViewerState extends State<MushafPageViewer> {
  late PageController _pageController;
  final ScrollController _scrollController = ScrollController();

  bool _isZooming = false;
  double _textScale = 1.0;
  bool _showControls = true;
  bool _isBookmarked = false;
  QuranScrollMode _scrollMode = QuranScrollMode.horizontal;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentPage);
    _loadPreferences();
    _checkBookmark();
  }

  Future<void> _loadPreferences() async {
    final savedTextScale = await MushafStorageHelper.getTextScale();
    final mode = await QuranReadingModeHelper.getScrollMode();
    final hasChosen = await QuranReadingModeHelper.hasUserChosenMode();

    if (mounted) {
      setState(() {
        _textScale = savedTextScale.clamp(0.7, 1.5);
        _scrollMode = mode;
      });

      // إذا لم يكن قد اختار النمط من قبل، نظهر النافذة لتحديد الخيار فوراً
      if (!hasChosen) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          QuranReadingModeSheet.show(
            context,
            currentMode: _scrollMode,
            onModeSelected: (newMode) {
              setState(() => _scrollMode = newMode);
            },
          );
        });
      }
    }
  }

  Future<void> _checkBookmark() async {
    final bookmarked = await context.read<MushafCubit>().isPageBookmarked(
      widget.currentPage,
    );
    if (mounted) {
      setState(() => _isBookmarked = bookmarked);
    }
  }

  @override
  void didUpdateWidget(MushafPageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      _checkBookmark();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVertical = _scrollMode == QuranScrollMode.vertical;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Stack(
          children: [
            // صفحات المصحف: إما تصفح أفقي أو تمرير رأسي
            if (!isVertical)
              PageView.builder(
                controller: _pageController,
                physics: _isZooming
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(parent: PageScrollPhysics()),
                itemCount: widget.pages.length,
                onPageChanged: (index) {
                  context.read<MushafCubit>().goToPage(index);
                },
                itemBuilder: (context, index) {
                  return MushafPageWidget(
                    page: widget.pages[index],
                    textScale: _textScale,
                    onZoomChanged: (isZooming) {
                      setState(() => _isZooming = isZooming);
                    },
                  );
                },
              )
            else
              ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.pages.length,
                padding: EdgeInsets.only(top: 60.h, bottom: 90.h),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Column(
                      children: [
                        // شريط فاصل بين الصفحات في الوضع الرأسي
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.goldenPrimary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'صفحة ${widget.pages[index].pageNumber}',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.goldenPrimary,
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        MushafPageWidget(
                          page: widget.pages[index],
                          textScale: _textScale,
                          onZoomChanged: (isZooming) {
                            setState(() => _isZooming = isZooming);
                          },
                        ),
                        Divider(
                          color: AppColors.goldenPrimary.withOpacity(0.3),
                          thickness: 1,
                          indent: 30.w,
                          endIndent: 30.w,
                        ),
                      ],
                    ),
                  );
                },
              ),

            // الشريط الجانبي للأوتوسكرول (يظهر في الوضع الرأسي)
            if (isVertical)
              QuranAutoScrollSidebar(
                scrollController: _scrollController,
              ),

            // شريط التحكم العلوي الأنيق
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: _showControls ? 14 : -100,
              left: 12,
              right: 12,
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 24,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xE61F1F1F) : const Color(0xF2FFFFFF),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: AppColors.goldenPrimary.withOpacity(0.4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // زر الرجوع
                        if (Navigator.canPop(context))
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: isDark ? Colors.white : Colors.black87,
                              size: 18.sp,
                            ),
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            },
                          ),

                        // زر تبديل الوضع (رأسي / أفقي)
                        InkWell(
                          onTap: () {
                            QuranReadingModeSheet.show(
                              context,
                              currentMode: _scrollMode,
                              onModeSelected: (mode) {
                                setState(() => _scrollMode = mode);
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.goldenPrimary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isVertical ? Icons.swap_vert_rounded : Icons.auto_stories_rounded,
                                  size: 16.sp,
                                  color: AppColors.goldenPrimary,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  isVertical ? 'رأسي' : 'أفقي',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.goldenPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: 6.w),

                        // زر العلامة المرجعية
                        IconButton(
                          icon: Icon(
                            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: _isBookmarked ? AppColors.goldenPrimary : (isDark ? Colors.white70 : Colors.black54),
                            size: 20.sp,
                          ),
                          onPressed: () async {
                            await context.read<MushafCubit>().toggleBookmark(widget.currentPage);
                            _checkBookmark();
                          },
                        ),

                        // زر التصغير
                        IconButton(
                          icon: Icon(Icons.text_decrease_rounded, size: 18.sp, color: isDark ? Colors.white70 : Colors.black54),
                          onPressed: _textScale > 0.7
                              ? () {
                                  setState(() {
                                    _textScale = (_textScale - 0.1).clamp(0.7, 1.5);
                                  });
                                  MushafStorageHelper.saveTextScale(_textScale);
                                }
                              : null,
                        ),

                        // زر التكبير
                        IconButton(
                          icon: Icon(Icons.text_increase_rounded, size: 18.sp, color: AppColors.goldenPrimary),
                          onPressed: _textScale < 1.5
                              ? () {
                                  setState(() {
                                    _textScale = (_textScale + 0.1).clamp(0.7, 1.5);
                                  });
                                  MushafStorageHelper.saveTextScale(_textScale);
                                }
                              : null,
                        ),

                        // الانتقال لصفحة
                        IconButton(
                          icon: Icon(Icons.format_list_numbered_rounded, size: 18.sp, color: isDark ? Colors.white70 : Colors.black54),
                          onPressed: () => _showPageJumpDialog(context, isArabic),
                        ),

                        // الذهاب للعلامة
                        IconButton(
                          icon: Icon(Icons.bookmarks_rounded, size: 18.sp, color: isDark ? Colors.white70 : Colors.black54),
                          onPressed: () => _goToBookmark(context, isArabic),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // مؤشر الصفحة السفلي (في الوضع الأفقي)
            if (!isVertical)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                bottom: _showControls ? 20 : -100,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xE61F1F1F) : const Color(0xF2FFFFFF),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.goldenPrimary.withOpacity(0.35),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      'صفحة ${widget.currentPage + 1} من ${widget.pages.length}',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldenPrimary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPageJumpDialog(BuildContext context, bool isArabic) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isArabic ? 'الانتقال إلى صفحة' : 'Jump to Page'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'أدخل رقم الصفحة (1-${widget.pages.length})',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              final pageNum = int.tryParse(controller.text);
              if (pageNum != null && pageNum > 0 && pageNum <= widget.pages.length) {
                if (_scrollMode == QuranScrollMode.horizontal) {
                  _pageController.jumpToPage(pageNum - 1);
                }
                Navigator.pop(dialogContext);
              }
            },
            child: Text(isArabic ? 'انتقال' : 'Go'),
          ),
        ],
      ),
    );
  }

  Future<void> _goToBookmark(BuildContext context, bool isArabic) async {
    final cubit = context.read<MushafCubit>();
    final bookmark = await cubit.getBookmark();

    if (bookmark == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد علامة مرجعية محفوظة'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      if (_scrollMode == QuranScrollMode.horizontal) {
        _pageController.jumpToPage(bookmark);
      }
    }
  }
}
