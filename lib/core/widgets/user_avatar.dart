import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:developer';
import '../../../core/utils/image_helper.dart';
import '../../features/auth/data/models/user_model.dart';

/// A widget that displays user avatar with support for:
/// - Base64 encoded images
/// - Initials-based avatars with colored background
/// - Customizable size
class UserAvatar extends StatelessWidget {
  final UserModel? user;
  final double radius;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;

  const UserAvatar({
    super.key,
    this.user,
    this.radius = 24,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2,
    required borderwidth,
  });

  @override
  Widget build(BuildContext context) {
    // If no user, show default avatar
    if (user == null) {
      return _buildDefaultAvatar(context);
    }

    // If user has base64 photo, display it
    if (user!.photoBase64 != null && user!.photoBase64!.isNotEmpty) {
      final isValid = ImageHelper.isValidBase64(user!.photoBase64);
      if (isValid) {
        log('[UserAvatar] Displaying base64 photo for user: ${user!.id}');
        return _buildBase64Avatar(user!.photoBase64!);
      } else {
        log(
          '[UserAvatar] Invalid base64 for user: ${user!.id}, length: ${user!.photoBase64!.length}',
        );
      }
    }

    // Otherwise, show initials avatar
    log('[UserAvatar] Using initials avatar for user: ${user!.id}');
    return _buildInitialsAvatar(context);
  }

  Widget _buildBase64Avatar(String base64String) {
    final imageBytes = ImageHelper.base64ToBytes(base64String);

    if (imageBytes == null) {
      log('[UserAvatar] Failed to decode base64 to bytes');
      return _buildInitialsAvatar(null);
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: showBorder
              ? Border.all(
                  color: borderColor ?? Colors.white,
                  width: borderWidth,
                )
              : null,
        ),
        child: ClipOval(
          child: Image.memory(
            imageBytes,
            key: ValueKey(
              base64String.hashCode,
            ), // Force rebuild when image changes
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            cacheWidth: (radius * 2 * 3)
                .toInt(), // Cache at 3x device pixel ratio
            gaplessPlayback: true, // Smooth transition when image changes
            errorBuilder: (context, error, stackTrace) {
              log('[UserAvatar] Error displaying image: $error');
              return _buildInitialsAvatar(context);
            },
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(BuildContext? context) {
    final name = user?.displayName ?? user?.email.split('@')[0] ?? '؟';
    final initials = ImageHelper.getInitials(name);
    final backgroundColor = ImageHelper.getAvatarColor(name);

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          border: showBorder
              ? Border.all(
                  color: borderColor ?? Colors.white,
                  width: borderWidth,
                )
              : null,
        ),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              color: Colors.white,
              fontSize: radius * 0.8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      child: Icon(Icons.person, size: radius * 1.2, color: Colors.grey[600]),
    );
  }
}

/// A variant with edit button overlay
class EditableUserAvatar extends StatelessWidget {
  final UserModel? user;
  final double radius;
  final VoidCallback? onEditTap;
  final bool isLoading;

  const EditableUserAvatar({
    super.key,
    this.user,
    this.radius = 50,
    this.onEditTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main avatar
        UserAvatar(
          user: user,
          radius: radius,
          showBorder: true,
          borderColor: Theme.of(context).colorScheme.primary,
          borderwidth: 3.w,
        ),

        // Loading overlay
        if (isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),

        // Edit button
        if (!isLoading && onEditTap != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onEditTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2.w,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: radius * 0.4,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
