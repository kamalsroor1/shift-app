import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/shift_badge.dart';
import '../../../../core/widgets/status_chip.dart';
import 'add_edit_shift_modal.dart';

/// DayDetailsSheet — Interactive bottom sheet shown when a nurse clicks on any day
/// in the shift calendar. Displays exact shift info, colleagues on duty, and quick actions.
class DayDetailsSheet extends StatelessWidget {
  final DateTime selectedDate;
  final ShiftType? assignedShift;
  final VoidCallback? onSwitchToMarketplace;

  const DayDetailsSheet({
    super.key,
    required this.selectedDate,
    this.assignedShift,
    this.onSwitchToMarketplace,
  });

  @override
  Widget build(BuildContext context) {
    final shift = assignedShift ?? ShiftType.off;
    final isOff = shift == ShiftType.off;

    // Simulated roster of colleagues sharing this shift/date in the department
    final colleagues = isOff
        ? []
        : [
            {'name': 'د. أحمد خالد', 'role': 'طبيب مقيم عناية', 'status': 'في الموقع'},
            {'name': 'ممرضة سارة علي', 'role': 'مشرفة تمريض (ICU)', 'status': 'في الموقع'},
            {'name': 'ممرض محمود حسن', 'role': 'تمريض طوارئ', 'status': 'مناوبة'},
          ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header indicator and Close button
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 24),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        DateFormat('EEEE، d MMMM yyyy', 'ar').format(selectedDate),
                        style: AppTextStyles.headingLg,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.secondaryLow),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Shift assignment card for the current user
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('حالة ورديتي في هذا اليوم', style: AppTextStyles.label),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          isOff
                              ? 'إجازة / راحة أسبوعية'
                              : shift == ShiftType.long
                                  ? 'وردية صباحية طويلة • ١٢ ساعة'
                                  : 'وردية سهر ليلية • ١٢ ساعة',
                          style: AppTextStyles.headingMd,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          isOff
                              ? 'لا توجد ساعات عمل مجدولة اليوم.'
                              : shift == ShiftType.long
                                  ? 'من ٠٧:٣٠ صباحاً حتى ٠٧:٣٠ مساءً'
                                  : 'من ٠٧:٣٠ مساءً حتى ٠٧:٣٠ صباحاً',
                          style: AppTextStyles.bodySm,
                        ),
                      ],
                    ),
                    ShiftBadge(shiftType: shift),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Colleagues section
              Text('زملاء الوردية المداومون في القسم', style: AppTextStyles.headingMd),
              const SizedBox(height: AppSpacing.sm),
              if (isOff)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Center(
                    child: Text(
                      'أنت في إجازة اليوم، استمتع بوقت راحتك المجدول! 🌴',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.secondaryLow),
                    ),
                  ),
                )
              else
                Column(
                  children: colleagues.map((colleague) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primaryLight,
                              child: Text(
                                (colleague['name'] as String).substring(0, 3),
                                style: AppTextStyles.label.copyWith(color: AppColors.primary, fontSize: 11),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(colleague['name'] as String, style: AppTextStyles.headingSm),
                                  Text(colleague['role'] as String, style: AppTextStyles.bodySm),
                                ],
                              ),
                            ),
                            StatusChip(status: colleague['status'] as String),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: AppSpacing.xxxl),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                      icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                      label: const Text('تعديل / إضافة وردية'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => AddEditShiftModal(
                            initialDate: selectedDate,
                            initialShift: shift,
                          ),
                        );
                      },
                    ),
                  ),
                  if (!isOff) ...[
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                        icon: const Icon(Icons.swap_calls_rounded, size: 18),
                        label: const Text('طلب تبادل بالسوق'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (onSwitchToMarketplace != null) {
                            onSwitchToMarketplace!();
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
