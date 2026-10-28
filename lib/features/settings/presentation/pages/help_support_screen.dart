import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/assets.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'كيف أستخدم التطبيق؟',
      'answer':
          'يمكنك تصفح القرآن الكريم، قراءة الأذكار اليومية، متابعة مواقيت الصلاة والأذان بدقة، والاستماع إلى إذاعات القرآن الكريم، وإدارة خطط الختمة وصيام السنن بكل سهولة.',
    },
    {
      'question': 'ما مدى دقة مواعيد الصلاة؟',
      'answer':
          'تعتمد مواقيت الصلاة على إحداثيات موقعك الجغرافي وطرق الحساب الفلكية المعتمدة رسمياً لكل بلد (مثل الهيئة المصرية العامة للمساحة أو تقويم أم القرى)، لضمان أعلى درجات الدقة.',
    },
    {
      'question': 'لماذا قد تكون بوصلة القبلة غير دقيقة؟',
      'answer':
          'تعتمد بوصلة القبلة على حساس المغناطيسية بهاتفك. تأكد من تفعيل خدمات الموقع، والابتعاد عن المعادن والأجهزة الكهربائية، ومعايرة البوصلة بتحريك الهاتف في الهواء على شكل 8.',
    },
    {
      'question': 'كيف أقوم بتفعيل إشعارات الصلاة والأذكار؟',
      'answer':
          'انتقل إلى شاشة "إعدادات الإشعارات والتنبيهات" وتأكد من تفعيل الصلوات والأذكار المرغوبة، وتأكد من إعطاء التطبيق إذن العمل في الخلفية واستثناءه من تحسين البطارية من إعدادات الهاتف.',
    },
    {
      'question': 'هل يعمل التطبيق بدون إنترنت؟',
      'answer':
          'نعم، الغالبية العظمى من خصائص تطبيق صحبة (مثل قراءة المصحف الشريف كاملاً، تصفح الأذكار وحصن المسلم، الأحاديث النبوية، مواقيت الصلاة، وحساب القبلة) تعمل بشكل كامل محلياً ودون الحاجة لأي اتصال بالإنترنت.',
    },
    {
      'question': 'كيف تعمل خطة الختمة القرآنية؟',
      'answer':
          'يمكنك تحديد مدة الختمة (مثل ٣٠ يوماً أو ٦٠ يوماً)، وسيقوم التطبيق بحساب وردك اليومي من الصفحات ومتابعة إنجازك يومياً حتى إتمام الختمة وقراءة دعاء ختم القرآن الكريم.',
    },
  ];

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
                  _buildTopAppBar(isDark),
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
                          // بطاقة الأسئلة الشائعة والإرشادات
                          _buildFaqCard(isDark),
                          SizedBox(height: 18.h),

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
  // شريط العنوان العلوي
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

          // العنوان في المنتصف
          Expanded(
            child: Text(
              'المساعدة والإرشادات',
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
  // بطاقة الأسئلة الشائعة والإرشادات
  // ==============================================================
  Widget _buildFaqCard(bool isDark) {
    return Container(
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
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // رأس بطاقة الأسئلة الشائعة
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
                    Icons.quiz_outlined,
                    color: const Color(0xFF143427),
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'الأسئلة الشائعة وإرشادات الاستخدام',
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

          // عناصر الأسئلة والأجوبة
          ...List.generate(_faqs.length, (index) {
            final faq = _faqs[index];
            final isLast = index == _faqs.length - 1;

            return Column(
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ),
                      childrenPadding: EdgeInsets.only(
                        left: 18.w,
                        right: 18.w,
                        bottom: 14.h,
                      ),
                      trailing: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark ? Colors.white54 : const Color(0xFF8C7A6B),
                        size: 24.sp,
                      ),
                      title: Text(
                        faq['question']!,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF38291D),
                        ),
                      ),
                      children: [
                        Text(
                          faq['answer']!,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF736152),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildBottomOrnament(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
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
