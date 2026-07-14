import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// StatusChip — Clean status tag with a colored indicator dot and clear Arabic terminology.
class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    Color dotColor;
    String displayLabel;

    switch (status.toLowerCase()) {
      case 'pending':
      case 'قيد الانتظار':
        bg = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFB45309);
        dotColor = AppColors.warning;
        displayLabel = 'قيد الانتظار';
        break;
      case 'accepted':
      case 'مقبول':
        bg = AppColors.primaryLight;
        textColor = AppColors.primaryDark;
        dotColor = AppColors.primary;
        displayLabel = 'مقبول';
        break;
      case 'listed':
      case 'معروض':
        bg = AppColors.primaryLight;
        textColor = AppColors.primaryDark;
        dotColor = AppColors.primary;
        displayLabel = 'معروض للبيع';
        break;
      case 'completed':
      case 'purchased':
      case 'مكتمل':
      case 'تم الشراء':
        bg = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF15803D);
        dotColor = AppColors.success;
        displayLabel = status.toLowerCase() == 'purchased' ? 'تم الشراء' : 'مكتمل';
        break;
      case 'rejected':
      case 'expired':
      case 'مرفوض':
      case 'منتهي':
        bg = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFB91C1C);
        dotColor = AppColors.error;
        displayLabel = status.toLowerCase() == 'expired' ? 'منتهي الصلاحية' : 'مرفوض';
        break;
      case 'active':
      case 'نشط':
        bg = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF15803D);
        dotColor = AppColors.success;
        displayLabel = 'نشط في المناوبة';
        break;
      case 'settled':
      case 'تم التسديد':
      default:
        bg = AppColors.surfaceAlt;
        textColor = AppColors.secondaryMid;
        dotColor = AppColors.secondaryLow;
        displayLabel = 'تم التسديد';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            displayLabel,
            style: AppTextStyles.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
