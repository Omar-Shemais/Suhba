import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:islamic_app/core/constants/app_colors.dart';

class RoundsSelectorBottomSheet extends StatefulWidget {
  final int currentValue;
  final Function(int) onApply;

  const RoundsSelectorBottomSheet({
    super.key,
    required this.currentValue,
    required this.onApply,
  });

  @override
  State<RoundsSelectorBottomSheet> createState() =>
      _RoundsSelectorBottomSheetState();
}

class _RoundsSelectorBottomSheetState extends State<RoundsSelectorBottomSheet> {
  static const List<int> roundOptions = [1, 3, 7, 10];
  late int? selectedRounds;
  final TextEditingController customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedRounds = widget.currentValue;
  }

  @override
  void dispose() {
    customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : AppColors.brownPrimary;
    final secondaryTextColor =
        isDark ? Colors.white70 : AppColors.brownSecondary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282C32) : const Color(0xFFFAF5ED),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? const Color(0xFF383E46) : const Color(0xFFEADBCE),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Center(
            child: Text(
              'select_rounds'.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Preset label
          Text(
            'preset_rounds'.tr(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          // Preset options
          Row(
            children: roundOptions.map((rounds) {
              final isSelected = selectedRounds == rounds;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedRounds = rounds;
                          customController.clear();
                        });
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppColors.goldenGradient : null,
                          color: isSelected
                              ? null
                              : (isDark ? const Color(0xFF21252A) : Colors.white),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark
                                    ? const Color(0xFF383E46)
                                    : const Color(0xFFEADBCE)),
                            width: 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.goldenPrimary
                                        .withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            rounds.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : primaryTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Custom rounds label
          Text(
            'custom_rounds'.tr(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 10),
          // Custom input
          TextField(
            controller: customController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  selectedRounds = int.tryParse(value);
                });
              }
            },
            decoration: InputDecoration(
              hintText: 'enter_number_of_rounds'.tr(),
              hintStyle: TextStyle(
                color: secondaryTextColor.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF21252A) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF383E46)
                      : const Color(0xFFEADBCE),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF383E46)
                      : const Color(0xFFEADBCE),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF2E7D5E)
                      : const Color(0xFF143427),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: const Icon(
                Icons.edit_outlined,
                color: AppColors.goldenPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 22),
          // Apply button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.goldenGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldenPrimary.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                if (selectedRounds != null && selectedRounds! > 0) {
                  widget.onApply(selectedRounds!);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'apply_selection'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
