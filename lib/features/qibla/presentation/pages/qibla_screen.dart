import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/core/widgets/custom_app_bar.dart';
import '../../data/repositories/qibla_repo.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

import '../cubit/qibla_cubit.dart';
import '../cubit/qibla_states.dart';
import '../widgets/qibla_compass_widget.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  late final QiblaCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = QiblaCubit(QiblaRepository())..getQibla();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: 'qibla_direction'.tr(),
          showReciterIcon: false,
        ),
        body: BlocBuilder<QiblaCubit, QiblaState>(
          builder: (context, state) {
            if (state is QiblaLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.goldenPrimary,
                ),
              );
            }

            if (state is QiblaFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.errorColor,
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<QiblaCubit>().getQibla();
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text('retry'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldenPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is QiblaSuccess) {
              return Center(child: QiblaCompassWidget(qiblaAngle: state.angle));
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldenGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.explore,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      'press_to_find_qibla'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // floatingActionButton: FloatingActionButton.extended(
        //   onPressed: () {
        //     context.read<QiblaCubit>().getQibla();
        //   },
        //   icon: const Icon(Icons.explore),
        //   label: Text('qibla_direction'.tr()),
        //   backgroundColor: AppColors.goldenPrimary,
        //   foregroundColor: Colors.white,
        // ),
      ),
    );
  }
}
