import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/assets.dart';
import 'package:islamic_app/features/quran/data/helpers/last_read_storage.dart';
import 'package:islamic_app/features/quran/presentation/pages/surah_detail_screen.dart';

class HomeQuranReadingCard extends StatefulWidget {
  const HomeQuranReadingCard({super.key});

  @override
  State<HomeQuranReadingCard> createState() => _HomeQuranReadingCardState();
}

class _HomeQuranReadingCardState extends State<HomeQuranReadingCard> with WidgetsBindingObserver {
  LastReadModel? _lastRead;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLastRead();
    LastReadManager.lastReadUpdated.addListener(_loadLastRead);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadLastRead();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    LastReadManager.lastReadUpdated.removeListener(_loadLastRead);
    super.dispose();
  }

  Future<void> _loadLastRead() async {
    final lastRead = await LastReadManager.getLastRead(forceReload: true);
    if (mounted) {
      setState(() {
        _lastRead = lastRead;
      });
    }
  }

  String _toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.tryParse(d) ?? 0])
        .join('');
  }

  String _formatSurahTitle(String? name) {
    if (name == null || name.isEmpty) return 'سورة البقرة';
    if (name.startsWith('سورة') || name.startsWith('سُورَةُ')) return name;
    return 'سورة $name';
  }

  @override
  Widget build(BuildContext context) {
    final surahTitle = _formatSurahTitle(_lastRead?.surahNameArabic);
    final ayahNo = _lastRead?.ayahNumber ?? 1;
    final totalVerses = _lastRead?.totalVerses ?? 286;
    final double progress = (totalVerses > 0 ? (ayahNo / totalVerses) : 0.05).clamp(0.05, 1.0);

    final subText = _lastRead == null || _lastRead!.isDefault
        ? 'ابدأ القراءة • آية ١ من ${_toArabicDigits(totalVerses)}'
        : 'آخر موضع قراءة • آية ${_toArabicDigits(ayahNo)} من ${_toArabicDigits(totalVerses)}';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F4838),
            Color(0xFF143427),
            Color(0xFF0F2B1F),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: const Color(0xFF2E5E4A).withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2B1F).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final surahId = _lastRead?.surahId ?? 2;
            final ayahNumber = _lastRead?.ayahNumber ?? 1;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurahDetailScreen(
                  surahId: surahId,
                  initialAyahNumber: ayahNumber,
                ),
              ),
            ).then((_) => _loadLastRead());
          },
          borderRadius: BorderRadius.circular(22.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // الجانب الأيمن: تفاصيل القراءة والتقدم
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // شارة "متابعة القراءة"
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 4.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEADCC8),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          'متابعة القراءة',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF38291B),
                          ),
                        ),
                      ),

                      SizedBox(height: 10.h),

                      // اسم السورة
                      Text(
                        surahTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // موضع القراءة الأخير
                      Text(
                        subText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFFB4DAC8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // شريط التقدم
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          height: 5.5.h,
                          width: 140.w,
                          color: Colors.white.withValues(alpha: 0.16),
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Container(
                              width: 140.w * progress,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7D8C0),
                                borderRadius: BorderRadius.circular(8.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFE7D8C0)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 10.w),

                // الجانب الأيسر: مجسم المصحف الشريف ثلاثي الأبعاد
                Hero(
                  tag: 'quran_3d_banner',
                  child: Container(
                    width: 115.w,
                    height: 105.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 12,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
