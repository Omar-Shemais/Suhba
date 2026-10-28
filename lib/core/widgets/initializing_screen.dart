// ============================================================================
// INITIALIZING SCREEN - Loading screen shown during background initialization
// ============================================================================
// This screen appears immediately after splash while services load in background.
// It provides visual feedback to users that the app is working.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Lightweight loading screen shown while services initialize
/// Visually similar to splash screen for seamless transition
class InitializingScreen extends StatelessWidget {
  const InitializingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8E1), // Light cream
              Color(0xFFFFE4B5), // Light peach
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon with Gradient
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade700, Colors.amber.shade500],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.mosque, size: 80, color: Colors.white),
              ),

              SizedBox(height: 40.h),

              // Loading Indicator
              SizedBox(
                width: 40.w,
                height: 40.h,
                child: CircularProgressIndicator(
                  strokeWidth: 3.w,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ),

              SizedBox(height: 24.h),

              // Optional: Loading text
              Text(
                'جاري التحميل...',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.brown.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
