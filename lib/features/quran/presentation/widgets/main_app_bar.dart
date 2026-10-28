import 'package:flutter/material.dart';
import 'package:islamic_app/core/constants/app_text_styles.dart';

class MainAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onMenuTap;
  final VoidCallback? onSearchTap;

  const MainAppBar({
    super.key,
    required this.title,
    this.onMenuTap,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),

          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headline,
            ),
          ),

          IconButton(icon: const Icon(Icons.search), onPressed: onSearchTap),
        ],
      ),
    );
  }
}
