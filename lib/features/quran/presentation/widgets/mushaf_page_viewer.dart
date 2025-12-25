// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import 'package:islamic_app/features/quran/presentation/cubit/mushaf_cubit.dart';

import '../../data/helpers/mushaf_storage_helper.dart';
import '../../data/models/mushaf_models.dart';
import 'mushaf_page_widget.dart';

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
  bool _isZooming = false;
  double _textScale = 1.0;
  bool _showControls = true;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentPage);
    _loadPreferences();
    _checkBookmark();
  }

  // ✅ تحميل التفضيلات المحفوظة
  Future<void> _loadPreferences() async {
    final savedTextScale = await MushafStorageHelper.getTextScale();
    setState(() {
      _textScale = savedTextScale.clamp(0.7, 1.5); // تأكد من القيمة ضمن النطاق
    });
  }

  // ✅ التحقق من العلامة المرجعية
  Future<void> _checkBookmark() async {
    final bookmarked = await context.read<MushafCubit>().isPageBookmarked(
      widget.currentPage,
    );
    setState(() {
      _isBookmarked = bookmarked;
    });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            // صفحات المصحف
            PageView.builder(
              controller: _pageController,
              physics: _isZooming
                  ? const NeverScrollableScrollPhysics()
                  : const PageScrollPhysics(),
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
            ),

            // شريط التحكم العلوي
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: _showControls ? 20 : -100,
              left: 16,
              right: 16,
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 32,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // زر العلامة المرجعية
                        IconButton(
                          icon: Icon(
                            _isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: _isBookmarked
                                ? isDark
                                      ? AppColors.secondaryColor
                                      : AppColors.primaryColor
                                : Colors.white,
                            size: 20,
                          ),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            await context.read<MushafCubit>().toggleBookmark(
                              widget.currentPage,
                            );
                            _checkBookmark();

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: isDark
                                    ? AppColors.secondaryColor
                                    : AppColors.primaryColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                content: Text(
                                  _isBookmarked
                                      ? (isArabic
                                            ? 'تم إزالة العلامة المرجعية'
                                            : 'Bookmark removed')
                                      : (isArabic
                                            ? 'تم إضافة علامة مرجعية'
                                            : 'Bookmark added'),
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),

                        SizedBox(width: 4.w),
                        Container(
                          width: 1.w,
                          height: 24.h,
                          color: Colors.white38,
                        ),
                        SizedBox(width: 4.w),

                        // زر التصغير
                        IconButton(
                          icon: const Icon(
                            Icons.text_decrease,
                            color: Colors.white,
                            size: 20,
                          ),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          onPressed: _textScale > 0.7
                              ? () {
                                  setState(() {
                                    _textScale = (_textScale - 0.1).clamp(
                                      0.7,
                                      1.5,
                                    );
                                  });
                                  MushafStorageHelper.saveTextScale(_textScale);
                                }
                              : null,
                        ),

                        // السلايدر
                        SizedBox(
                          width: 80.w,
                          child: Slider(
                            value: _textScale,
                            min: 0.7,
                            max: 1.5,
                            divisions: 8,
                            activeColor: Colors.white,
                            inactiveColor: Colors.white38,
                            onChanged: (value) {
                              setState(() {
                                _textScale = value;
                              });
                            },
                            onChangeEnd: (value) {
                              MushafStorageHelper.saveTextScale(value);
                            },
                          ),
                        ),

                        // زر التكبير
                        IconButton(
                          icon: const Icon(
                            Icons.text_increase,
                            color: Colors.white,
                            size: 20,
                          ),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          onPressed: _textScale < 1.5
                              ? () {
                                  setState(() {
                                    _textScale = (_textScale + 0.1).clamp(
                                      0.7,
                                      1.5,
                                    );
                                  });
                                  MushafStorageHelper.saveTextScale(_textScale);
                                }
                              : null,
                        ),

                        SizedBox(width: 4.w),
                        Container(
                          width: 1.w,
                          height: 24.h,
                          color: Colors.white38,
                        ),
                        SizedBox(width: 4.w),

                        // زر الانتقال للصفحة
                        IconButton(
                          icon: const Icon(
                            Icons.format_list_numbered,
                            color: Colors.white,
                            size: 20,
                          ),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          onPressed: () =>
                              _showPageJumpDialog(context, isArabic),
                        ),

                        // زر العلامات المرجعية
                        IconButton(
                          icon: const Icon(
                            Icons.bookmarks,
                            color: Colors.white,
                            size: 20,
                          ),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          onPressed: () => _goToBookmark(context, isArabic),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // رقم الصفحة السفلي
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: _showControls ? 20 : -100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    isArabic
                        ? 'صفحة ${widget.currentPage + 1} من ${widget.pages.length}'
                        : 'Page ${widget.currentPage + 1} of ${widget.pages.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  // نافذة الانتقال للصفحة
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
            hintText: isArabic
                ? 'أدخل رقم الصفحة (1-${widget.pages.length})'
                : 'Enter page number (1-${widget.pages.length})',
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
              if (pageNum != null &&
                  pageNum > 0 &&
                  pageNum <= widget.pages.length) {
                _pageController.jumpToPage(pageNum - 1);
                Navigator.pop(dialogContext);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isArabic
                          ? 'الرجاء إدخال رقم صفحة صحيح'
                          : 'Please enter a valid page number',
                    ),
                  ),
                );
              }
            },
            child: Text(isArabic ? 'انتقال' : 'Go'),
          ),
        ],
      ),
    );
  }

  // الذهاب للعلامة المرجعية
  Future<void> _goToBookmark(BuildContext context, bool isArabic) async {
    final cubit = context.read<MushafCubit>();
    final bookmark = await cubit.getBookmark();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (bookmark == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: isDark
              ? AppColors.secondaryColor
              : AppColors.primaryColor,
          behavior: SnackBarBehavior.floating,
          content: Text(
            isArabic ? 'لا توجد علامة مرجعية محفوظة' : 'No bookmark saved',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      _pageController.jumpToPage(bookmark);
    }
  }
}
