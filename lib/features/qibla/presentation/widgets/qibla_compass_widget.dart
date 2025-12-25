// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class QiblaCompassWidget extends StatelessWidget {
  final double qiblaAngle;

  const QiblaCompassWidget({super.key, required this.qiblaAngle});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: FlutterCompass.events!.map((event) => event.heading ?? 0),

      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "error".tr(),
              style: TextStyle(fontSize: 16.sp, color: AppColors.errorColor),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.goldenPrimary),
          );
        }

        double? north = snapshot.data;
        if (north == null) return const SizedBox();

        // نحسب الفرق بين اتجاه الشمال واتجاه القبلة
        double qiblaDirection = (qiblaAngle - north) * (pi / 180);

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // معلومات الموقع
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldenGradient,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'my_location'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),

                // البوصلة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldenPrimary.withValues(alpha: .2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // دائرة البوصلة الخارجية
                      Container(
                        width: 280.w,
                        height: 280.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.goldenPrimary.withValues(alpha: .1),
                              AppColors.goldenSecondary.withValues(alpha: .2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),

                      // دائرة البوصلة الداخلية
                      Container(
                        width: 250.w,
                        height: 250.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.goldenPrimary,
                            width: 3.w,
                          ),
                          color: Colors.white,
                        ),
                        child: Stack(
                          children: [
                            // الاتجاهات
                            Positioned(
                              top: 8,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: _DirectionText("N", Colors.red),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: _DirectionText(
                                  "S",
                                  AppColors.brownSecondary,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 8,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: _DirectionText(
                                  "W",
                                  AppColors.brownSecondary,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: _DirectionText(
                                  "E",
                                  AppColors.brownSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // السهم
                      Transform.rotate(
                        angle: qiblaDirection,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.goldenPrimary.withValues(
                                  alpha: .4,
                                ),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.navigation,
                            size: 120,
                            color: AppColors.goldenPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // معلومات الزوايا
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.goldenPrimary.withValues(alpha: .3),
                      width: 2.w,
                    ),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.my_location,
                        label: 'qibla_direction'.tr(),
                        value: "${qiblaAngle.toStringAsFixed(1)}°",
                      ),
                      Divider(height: 24.h),
                      _InfoRow(
                        icon: Icons.explore,
                        label: "اتجاه الشمال",
                        value: "${north.toStringAsFixed(1)}°",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Helper widget for direction text
class _DirectionText extends StatelessWidget {
  final String text;
  final Color color;

  const _DirectionText(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20.sp,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Helper widget for info row
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.goldenGradient,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 16.sp, color: AppColors.brownSecondary),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.brownPrimary,
          ),
        ),
      ],
    );
  }
}
