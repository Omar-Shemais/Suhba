import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';
import '../cubit/azkar_cubit.dart';
import '../cubit/azkar_states.dart';

class EveningAzkarScreen extends StatelessWidget {
  const EveningAzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => AzkarCubit()..getEveningAzkar(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'evening_azkar'.tr(),
            style:
                theme.appBarTheme.titleTextStyle ??
                theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.backgroundDark,
                ),
          ),
          centerTitle: true,

          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surface.withValues(alpha: .9),
                theme.colorScheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: BlocBuilder<AzkarCubit, AzkarState>(
            builder: (context, state) {
              if (state is AzkarLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                );
              } else if (state is AzkarError) {
                return Center(
                  child: Text(
                    "${"error_occurred".tr()}: ${state.message}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontSize: 18.sp,
                    ),
                  ),
                );
              } else if (state is EveningAzkarSuccess) {
                final azkarModel = state.azkarModel;

                if (azkarModel.azkar.isEmpty) {
                  return Center(
                    child: Text(
                      "no_data".tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 18.sp,
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: azkarModel.azkar.length,
                    itemBuilder: (context, index) {
                      final item = azkarModel.azkar[index];

                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        color:
                            theme.cardTheme.color ?? theme.colorScheme.surface,
                        shadowColor: theme.colorScheme.primary.withValues(
                          alpha: .3,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                item.zekr,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                  height: 1.5.h,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.repeat,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: .6),
                                    size: 20,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    "${"repeat_count".tr()}: ${item.repeat}",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: .6),
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                ],
                              ),
                              if (item.bless.isNotEmpty) ...[
                                SizedBox(height: 10.h),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: .1,
                                    ),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.favorite_border,
                                        color: theme.colorScheme.primary,
                                        size: 20,
                                      ),
                                      SizedBox(width: 6.w),
                                      Expanded(
                                        child: Text(
                                          item.bless,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.primary,
                                                height: 1.4.h,
                                              ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
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

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

/*
class EveningAzkarScreen extends StatelessWidget {
  const EveningAzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AzkarCubit()..getEveningAzkar(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('evening_azkar'.tr()),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFBFC8E6),  
                Color(0xFF8A94C1),  
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: BlocBuilder<AzkarCubit, AzkarState>(
            builder: (context, state) {
              if (state is AzkarLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              } else if (state is AzkarError) {
                return Center(
                  child: Text(
                    "${"error_occurred".tr()}: ${state.message}",
                    style: const TextStyle(
                      fontSize: 18.sp,
                      color: Colors.redAccent,
                    ),
                  ),
                );
              } else if (state is EveningAzkarSuccess) {
                final azkarModel = state.azkarModel;

                if (azkarModel.azkar.isEmpty) {
                  return Center(
                    child: Text(
                      "no_data".tr(),
                      style: const TextStyle(fontSize: 18.sp, color: Colors.white),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: azkarModel.azkar.length,
                    itemBuilder: (context, index) {
                      final item = azkarModel.azkar[index];

                      return Card(
                        elevation: 6,
                        margin: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        color: Colors.white.withValues(alpha: .92),
                        shadowColor: Colors.deepPurpleAccent.withValues(alpha: .25),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                item.zekr,
                                style: const TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5.h,
                                  color: Color(0xFF2E2C22), // نفس لون النص في الصبح
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 10.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Icons.repeat,
                                    color: Color(0xFF55536D), // رمادي بنفسجي
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6.w),
                                  Text(
                                    "${"repeat_count".tr()}: ${item.repeat}",
                                    style: const TextStyle(
                                      fontSize: 15.sp,
                                      color: Color(0xFF55536D),
                                    ),
                                  ),
                                ],
                              ),
                              if (item.bless.isNotEmpty) ...[
                                const SizedBox(height: 10.h),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFD8E0F0), // أزرق باهت هادي
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Icon(
                                        Icons.favorite_border,
                                        color: Color(0xFF4E6099), // بنفسجي غامق ناعم
                                        size: 20,
                                      ),
                                      const SizedBox(width: 6.w),
                                      Expanded(
                                        child: Text(
                                          item.bless,
                                          style: const TextStyle(
                                            fontSize: 15.sp,
                                            color: Color(0xFF4E6099),
                                            height: 1.4.h,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
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

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

*/

/*
class EveningAzkarScreen extends StatelessWidget {
  const EveningAzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AzkarCubit()..getEveningAzkar(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('evening_azkar'.tr()),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: BlocBuilder<AzkarCubit, AzkarState>(
            builder: (context, state) {
              if (state is AzkarLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              } else if (state is AzkarError) {
                return Center(
                  child: Text(
                    "${"error_occurred".tr()}: ${state.message}",
                    style: const TextStyle(
                      fontSize: 18.sp,
                      color: Colors.redAccent,
                    ),
                  ),
                );
              } else if (state is EveningAzkarSuccess) {
                final azkarModel = state.azkarModel;

                if (azkarModel.azkar.isEmpty) {
                  return Center(
                    child: Text(
                      "no_data".tr(),
                      style: const TextStyle(fontSize: 18.sp, color: Colors.white),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: azkarModel.azkar.length,
                    itemBuilder: (context, index) {
                      final item = azkarModel.azkar[index];

                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        color: Colors.white.withValues(alpha: .1),
                        shadowColor: Colors.deepPurpleAccent.withValues(alpha: .3),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                item.zekr,
                                style: const TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5.h,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 10.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Icons.repeat,
                                    color: Colors.blueGrey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6.w),
                                  Text(
                                    "${"repeat_count".tr()}: ${item.repeat}",
                                    style: const TextStyle(
                                      fontSize: 15.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              if (item.bless.isNotEmpty) ...[
                                const SizedBox(height: 10.h),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.withValues(alpha: .15),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Icon(
                                        Icons.favorite_border,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                      const SizedBox(width: 6.w),
                                      Expanded(
                                        child: Text(
                                          item.bless,
                                          style: const TextStyle(
                                            fontSize: 15.sp,
                                            color: Colors.white,
                                            height: 1.4.h,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
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

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

*/

/*
class EveningAzkarScreen extends StatelessWidget {
  const EveningAzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AzkarCubit()..getEveningAzkar(),
      child: Scaffold(
        appBar: AppBar(title: Text('evening_azkar'.tr()), centerTitle: true),
        body: BlocBuilder<AzkarCubit, AzkarState>(
          builder: (context, state) {
            if (state is AzkarLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AzkarError) {
              return Center(
                child: Text("${"error_occurred".tr()}: ${state.message}"),
              );
            } else if (state is EveningAzkarSuccess) {
              final azkarModel = state.azkarModel;

              if (azkarModel.azkar.isEmpty) {
                return Center(child: Text("no_data".tr()));
              }

              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView.builder(
                  itemCount: azkarModel.azkar.length,
                  itemBuilder: (context, index) {
                    final item = azkarModel.azkar[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.zekr,
                              style: const TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 8.h),
                            Text(
                              "${"repeat_count".tr()}: ${item.repeat}",
                              style: const TextStyle(
                                fontSize: 14.sp,
                                color: Colors.blueGrey,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 4.h),
                            Text(
                              item.bless,
                              style: const TextStyle(
                                fontSize: 14.sp,
                                color: Colors.green,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
*/
