import 'package:flutter/material.dart';
import 'package:islamic_app/core/constants/app_colors.dart';
import '../../data/models/mushaf_models.dart';
import 'mushaf_text_builder.dart';

class MushafPageWidget extends StatefulWidget {
  final MushafPage page;
  final Function(bool)? onZoomChanged;
  final double textScale; // إضافة حجم النص

  const MushafPageWidget({
    super.key,
    required this.page,
    this.onZoomChanged,
    this.textScale = 1.0, // القيمة الافتراضية
  });

  @override
  State<MushafPageWidget> createState() => _MushafPageWidgetState();
}

class _MushafPageWidgetState extends State<MushafPageWidget> {
  final TransformationController _controller = TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return GestureDetector(
      onDoubleTap: () => _handleDoubleTap(),
      child: Container(
        color: isDark
            ? AppColors.primaryDarkColor
            : AppColors.primaryLightColor,
        child: InteractiveViewer(
          transformationController: _controller,
          minScale: 1.0,
          maxScale: 3.0,
          panEnabled: true,
          scaleEnabled: true,
          constrained: false,
          onInteractionStart: (_) => widget.onZoomChanged?.call(true),
          onInteractionEnd: (_) => _handleInteractionEnd(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              width: MediaQuery.of(context).size.width,
              child: MushafTextBuilder.buildContinuousText(
                verses: widget.page.verses,
                isDark: isDark,
                isArabic: isArabic,
                textScale: widget.textScale, // تمرير حجم النص
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleDoubleTap() {
    final currentScale = _controller.value.getMaxScaleOnAxis();
    final newScale = currentScale > 1.3 ? 1.0 : 1.5;

    setState(() {
      // ignore: deprecated_member_use
      _controller.value = Matrix4.identity()..scale(newScale);
    });
    widget.onZoomChanged?.call(newScale != 1.0);
  }

  void _handleInteractionEnd() {
    final scale = _controller.value.getMaxScaleOnAxis();
    widget.onZoomChanged?.call(scale > 1.01);
  }
}
