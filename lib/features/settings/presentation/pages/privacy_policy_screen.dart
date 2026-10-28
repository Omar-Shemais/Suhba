import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/assets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                          // 1. بطاقة الأمان والخصوصية العلوية
                          _buildHeaderShieldCard(isDark),
                          SizedBox(height: 16.h),

                          // 2. بنود الخصوصية
                          _buildPolicySection(
                            isDark: isDark,
                            icon: Icons.person_off_rounded,
                            title: 'عدم جمع أو طلب أي بيانات شخصية',
                            content:
                                'تطبيق صحبة لا يتطلب منك إنشاء حساب، ولا يطلب تسجيل أي بريد إلكتروني، اسم، أو رقم هاتف. نؤمن بأن العبادة شأن بين العبد وربه، ولذلك يمكنك استخدام التطبيق بكامل وظائفه فور تثبيته دون أي تسجيل.',
                          ),
                          SizedBox(height: 12.h),

                          _buildPolicySection(
                            isDark: isDark,
                            icon: Icons.location_on_rounded,
                            title: 'خدمات الموقع الجغرافي (GPS)',
                            content:
                                'يُستخدم إذن الموقع الجغرافي محلياً داخل جهازك فقط لحساب مواقيت الصلاة الدقيقة وتحديد اتجاه القبلة بالاعتماد على الطرق الفلكية الرسمية، ولا يتم إرسال موقعك أو تتبعه أو تخزينه في أي خوادم خارجية إطلاقاً.',
                          ),
                          SizedBox(height: 12.h),

                          _buildPolicySection(
                            isDark: isDark,
                            icon: Icons.storage_rounded,
                            title: 'التخزين المحلي الآمن',
                            content:
                                'تُحفظ كافة بياناتك التعبدية (مثل علامات القراءة في المصحف الشريف، وتقدمك في الختمات، وسجل الأذكار اليومية وصيام السنن) محلياً داخل ذاكرة جهازك فقط، وتُحذف تلقائياً وبشكل نهائي عند إزالة التطبيق.',
                          ),
                          SizedBox(height: 12.h),

                          _buildPolicySection(
                            isDark: isDark,
                            icon: Icons.block_flipped,
                            title: 'تطبيق خالٍ تماماً من الإعلانات والتتبع',
                            content:
                                'لا يحتوي تطبيق صحبة على أي إعلانات تجارية مزعجة، ولا يتضمن أي أدوات تعقب أو شبكات تحليل لسلوك المستخدم، احترماً لأوقات الذكر والخشوع وراحة المستخدم.',
                          ),
                          SizedBox(height: 12.h),

                          _buildPolicySection(
                            isDark: isDark,
                            icon: Icons.notifications_active_rounded,
                            title: 'أذونات الإشعارات وتشغيل الصوت',
                            content:
                                'تُستخدم أذونات الإشعارات لإرسال تنبيهات الأذان والأذكار ومواقيت الصيام حسب تفضيلاتك التي تختارها، بينما تُستخدم أذونات الصوت لتشغيل تلاوة القرآن الكريم وإذاعات القرآن الكريم في الخلفية.',
                          ),
                          SizedBox(height: 12.h),

                          _buildPolicySection(
                            isDark: isDark,
                            icon: Icons.wifi_off_rounded,
                            title: 'العمل بدون إنترنت (حماية كاملة)',
                            content:
                                'تم تصميم التطبيق ليعمل في معظم أركانه (قراءة القرآن الكريم، الأذكار، الأحاديث النبوية، مواقيت الصلاة، وحساب القبلة) دون الحاجة للاتصال بالإنترنت، مما يضمن أعلى درجات الخصوصية والأمان.',
                          ),
                          SizedBox(height: 12.h),

                          _buildPolicySection(
                            isDark: isDark,
                            icon: Icons.volunteer_activism_rounded,
                            title: 'تطبيق وقفي لوجه الله تعالى',
                            content:
                                'هذا التطبيق صدقة جارية ووقف لوجه الله تعالى، متاح مجاناً لجميع المسلمين حول العالم دون أي أهداف ربحية أو تجارية.',
                          ),
                          SizedBox(height: 18.h),

                          // تاريخ التحديث والزخرفة
                          _buildFooter(isDark),
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
              'سياسة الخصوصية',
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
  // بطاقة درع الأمان العلوية
  // ==============================================================
  Widget _buildHeaderShieldCard(bool isDark) {
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
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : const Color(0xFFE8F1EC),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF143427).withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.verified_user_rounded,
              color: const Color(0xFF143427),
              size: 28.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خصوصيتك أمانة ومحفوظة بالكامل',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF143427),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'تطبيق صحبة صُمم بنية الصدقة الجارية، بدون أي إعلانات أو تتبع، وبياناتك لا تغادر جهازك.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.white70 : const Color(0xFF736152),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // بطاقة البند
  // ==============================================================
  Widget _buildPolicySection({
    required bool isDark,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.04 : 0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFFE8F1EC),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF143427),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF143427),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            content,
            textAlign: TextAlign.justify,
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
  // تذييل الصفحة
  // ==============================================================
  Widget _buildFooter(bool isDark) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : const Color(0xFFEADBCE).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            'تطبيق صُحْبَة • وقف لوجه الله تعالى',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF736152),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36.w,
              height: 1.h,
              color: isDark ? Colors.white24 : const Color(0xFFC7B9A9),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.mosque_rounded,
              size: 16.sp,
              color: isDark ? Colors.white38 : const Color(0xFF8C7A6B),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 36.w,
              height: 1.h,
              color: isDark ? Colors.white24 : const Color(0xFFC7B9A9),
            ),
          ],
        ),
      ],
    );
  }
}
