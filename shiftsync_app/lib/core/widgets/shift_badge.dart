import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

enum ShiftType { long, night, off }
enum BadgeSize { small, medium }

/// ShiftBadge — Pill-shaped indicator for shift types with clear Arabic labels.
class ShiftBadge extends StatelessWidget {
  final ShiftType shiftType;
  final BadgeSize size;

  const ShiftBadge({
    super.key,
    required this.shiftType,
    this.size = BadgeSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    String label;

    switch (shiftType) {
      case ShiftType.long:
        bg = AppColors.shiftLongBg;
        textColor = AppColors.shiftLong;
        label = 'صباحية طويلة';
        break;
      case ShiftType.night:
        bg = AppColors.shiftNightBg;
        textColor = AppColors.shiftNight;
        label = 'سهر ليلي';
        break;
      case ShiftType.off:
        bg = AppColors.shiftOffBg;
        textColor = AppColors.shiftOff;
        label = 'يوم راحة';
        break;
    }

    final isSmall = size == BadgeSize.small;

    return Container(
      padding: isSmall
          ? const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs)
          : const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: (isSmall ? AppTextStyles.caption : AppTextStyles.label).copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
