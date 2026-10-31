import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/assets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF1E2125) : const Color(0xFFFAF5ED),
        body: Stack(
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

            // المحتوى مع شريط العنوان العلوي
            SafeArea(
              child: Column(
                children: [
                  _buildTopAppBar(context, isDark),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 10.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. بطاقة هوية التطبيق
                          _buildAppIdentityCard(isDark),
                          SizedBox(height: 18.h),

                          // 2. بطاقة مميزات التطبيق الشاملة
                          _buildFeaturesCard(isDark),
                          SizedBox(height: 18.h),

                          // 3. بطاقة الوقف والدعاء
                          _buildWaqfCard(isDark),
                          SizedBox(height: 14.h),

                          // الزخرفة السفلية
                          _buildBottomOrnament(isDark),
                          SizedBox(height: 14.h),
                        ],
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

  // ==============================================================
  // شريط العنوان العلوي (مطابق لمعايير AGENTS.md)
  // ==============================================================
  Widget _buildTopAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الرجوع في أقصى اليمين (في الواجهة العربية) يشير لليسار دائماً
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : const Color(0xFF38291D),
              size: 20.sp,
            ),
            tooltip: 'رجوع',
            onPressed: () => Navigator.of(context).pop(),
          ),

          // العنوان في المنتصف
          Expanded(
            child: Text(
              'عن تطبيق صُحْبَة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.5.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF143427),
              ),
            ),
          ),

          // مساحة فارغة لضبط التوسيط
          SizedBox(width: 48.w),
        ],
      ),
    );
  }

  // ==============================================================
  // 1. بطاقة هوية التطبيق
  // ==============================================================
  Widget _buildAppIdentityCard(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // شعار المسجد المؤطر بإطار إسلامي ذهبي أخضر
          Container(
            width: 76.w,
            height: 76.w,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : const Color(0xFFE8F1EC),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF143427).withValues(alpha: 0.25),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.mosque_rounded,
              color: const Color(0xFF143427),
              size: 40.sp,
            ),
          ),
          SizedBox(height: 14.h),

          // اسم التطبيق
          Text(
            'تطبيق صُحْبَة',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF7ECE1) : const Color(0xFF38291D),
              fontFamily: 'Amiri',
            ),
          ),
          SizedBox(height: 6.h),

          // شارة الإصدار والوقف
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFF143427).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: const Color(0xFF143427).withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Text(
              'الإصدار 1.0.0 • وقف لوجه الله تعالى',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFC7A87A) : const Color(0xFF143427),
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // وصف ورسالة التطبيق
          Text(
            'رفيقك اليومي لطاعة الله وحسن عبادته، تطبيق إسلامي شامل يجمع بين روحانية الذكر وجمال التصميم وسهولة الاستخدام لوجه الله تعالى دون أي إعلانات.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.white70 : const Color(0xFF736152),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // 2. مميزات وخصائص التطبيق الشاملة
  // ==============================================================
  Widget _buildFeaturesCard(bool isDark) {
    final features = [
      {
        'icon': Icons.menu_book_rounded,
        'title': 'القرآن الكريم والتلاوة العطرة',
        'desc':
            'مصحف إلكتروني كامل برسم عثماني، مع إمكانية الاستماع لآيات وسور بأصوات أشهر القراء.',
      },
      {
        'icon': Icons.auto_stories_rounded,
        'title': 'خطط الختمات القرآنية التفاعلية',
        'desc':
            'خطط ختمة مخصصة (٣٠ أو ٦٠ يوماً) مع تتبع الورد اليومي ومؤشر الإنجاز ودعاء ختم القرآن.',
      },
      {
        'icon': Icons.wb_sunny_rounded,
        'title': 'حصن المسلم والأذكار اليومية (بدون إنترنت)',
        'desc':
            'أذكار الصباح والمساء، أذكار النوم، الاستيقاظ، والصلاة، مع عدادات تفاعلية تعمل أوفلاين.',
      },
      {
        'icon': Icons.access_time_filled_rounded,
        'title': 'مواقيت الصلاة الدقيقة والأذان',
        'desc':
            'حساب دقيق لمواقيت الصلاة حسب موقعك الجغرافي بالاعتماد على الهيئات الفلكية الرسمية.',
      },
      {
        'icon': Icons.checklist_rtl_rounded,
        'title': 'الفروض والسنن ومتابعة الصلاة',
        'desc':
            'متابعة والانتظام في أداء الصلوات الخمس اليومية مع مؤشر الإنجاز، والسنن الرواتب، وصيام التطوع.',
      },
      {
        'icon': Icons.format_quote_rounded,
        'title': 'الأحاديث النبوية الشريفة',
        'desc':
            'موسوعة تضم رياض الصالحين والأربعين النووية مع شرح المفردات وإمكانية النسخ والمشاركة.',
      },
      {
        'icon': Icons.radio_rounded,
        'title': 'إذاعات القرآن الكريم المباشرة',
        'desc':
            'بث مباشر على مدار الساعة لأشهر إذاعات القرآن الكريم ومحطات كبار القراء في العالم الإسلامي.',
      },
      {
        'icon': Icons.explore_rounded,
        'title': 'بوصلة القبلة الدقيقة',
        'desc':
            'بوصلة دقيقة ومبسطة ترشدك لاتجاه الكعبة المشرفة في أي مكان حول العالم.',
      },
      {
        'icon': Icons.event_note_rounded,
        'title': 'التقويم الهجري والمناسبات الإسلامية',
        'desc':
            'عرض التاريخ الهجري يومياً ومتابعة أهم الأعياد والمواسم الدينية المباركة.',
      },
      {
        'icon': Icons.favorite_rounded,
        'title': 'الأدعية المأثورة الجامعة',
        'desc':
            'مجموعة واسعة ومصنفة من الأدعية القرآنية والنبوية لمختلف أوقات ومواقف الحياة.',
      },
      {
        'icon': Icons.notifications_active_rounded,
        'title': 'إشعارات ذكية مخصصة',
        'desc':
            'تنبيهات مخصصة لأوقات الصلاة، وأذكار الصباح مع الشروق وأذكار المساء مع الغروب.',
      },
      {
        'icon': Icons.block_flipped,
        'title': 'خالٍ تماماً من الإعلانات وحفظ الخصوصية',
        'desc':
            'تطبيق وقفي مجاني 100% دون أي إعلانات تجارية ودون جمع أي بيانات شخصية.',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس قسم المميزات
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : const Color(0xFFE8F1EC),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.stars_rounded,
                    color: const Color(0xFF143427),
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'مميزات وخصائص تطبيق صُحْبَة',
                    style: TextStyle(
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF143427),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? Colors.white10 : const Color(0xFFEADBCE),
          ),

          // قائمة المميزات
          ...List.generate(features.length, (index) {
            final item = features[index];
            final isLast = index == features.length - 1;

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white10
                              : const Color(0xFF143427).withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: const Color(0xFF143427),
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF38291D),
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              item['desc'] as String,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF736152),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 14.w,
                    endIndent: 14.w,
                    color: isDark ? Colors.white10 : const Color(0xFFEADBCE),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ==============================================================
  // 3. بطاقة الوقف والصدقة الجارية
  // ==============================================================
  Widget _buildWaqfCard(bool isDark) {
    return Container(
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
            color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : const Color(0xFFE8F1EC),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.volunteer_activism_rounded,
              color: isDark ? const Color(0xFFB0B3B8) : const Color(0xFF143427),
              size: 28.sp,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'صدقة جارية لوجه الله تعالى',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF143427),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'نسأل الله العلي القدير أن يجعل هذا العمل خالصاً لوجهه الكريم، وصدقة جارية لكل من ساهم في برمجته وتطويره ونشره بين المسلمين. لا تنسونا ومن تحبون من صالح دعائكم.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5.sp,
              color: isDark ? Colors.white70 : const Color(0xFF736152),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // الزخرفة السفلية
  // ==============================================================
  Widget _buildBottomOrnament(bool isDark) {
    return Row(
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
    );
  }
}
