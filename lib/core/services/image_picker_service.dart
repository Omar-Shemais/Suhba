import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick image from camera
  Future<File?> pickFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024.w,
        maxHeight: 1024.h,
        imageQuality: 85,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      log('Error picking from camera: $e');
      return null;
    }
  }

  /// Pick image from gallery
  Future<File?> pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024.w,
        maxHeight: 1024.h,
        imageQuality: 85,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      log('Error picking from gallery: $e');
      return null;
    }
  }

  /// Show dialog to choose image source (Camera or Gallery)
  static Future<File?> showImageSourceDialog(BuildContext context) async {
    final imagePickerService = ImagePickerService();

    return await showModalBottomSheet<File?>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'اختر مصدر الصورة',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20.h),

                // Camera option
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text('التقاط صورة'),
                  subtitle: const Text('استخدم الكاميرا'),
                  onTap: () async {
                    final file = await imagePickerService.pickFromCamera();
                    if (context.mounted) {
                      Navigator.pop(context, file);
                    }
                  },
                ),

                SizedBox(height: 10.h),

                // Gallery option
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  title: const Text('اختيار من المعرض'),
                  subtitle: const Text('اختر صورة محفوظة'),
                  onTap: () async {
                    final file = await imagePickerService.pickFromGallery();
                    if (context.mounted) {
                      Navigator.pop(context, file);
                    }
                  },
                ),

                SizedBox(height: 10.h),

                // Cancel button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
