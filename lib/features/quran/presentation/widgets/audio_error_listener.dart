import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/audio_cubit.dart';
import '../cubit/audio_state.dart';

class AudioErrorListener extends StatelessWidget {
  final Widget child;

  const AudioErrorListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AudioCubit, AudioState>(
      listenWhen: (previous, current) => current is AudioError,
      listener: (context, state) {
        if (state is AudioError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      state.message,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {}
          });
        }
      },
      child: child,
    );
  }
}
