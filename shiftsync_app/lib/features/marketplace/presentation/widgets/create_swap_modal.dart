import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/shift_badge.dart';
import '../providers/marketplace_provider.dart';

/// CreateSwapModal — Form modal allowing nurses to select one of their upcoming
/// shifts and publish a peer swap request to the department marketplace.
class CreateSwapModal extends ConsumerStatefulWidget {
  const CreateSwapModal({super.key});

  @override
  ConsumerState<CreateSwapModal> createState() => _CreateSwapModalState();
}

class _CreateSwapModalState extends ConsumerState<CreateSwapModal> {
  late DateTime _selectedDate;
  String _shiftType = 'صباحي طويل (12h)';
  final _reasonController = TextEditingController();
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2028, 12, 31),
      locale: const Locale('ar'),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _publishSwap() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى كتابة سبب أو ملاحظة لطلب التبادل لتوضيحها لزملائك.', style: AppTextStyles.bodySm.copyWith(color: AppColors.surface)),
          backgroundColor: AppColors.debtRed,
        ),
      );
      return;
    }

    setState(() => _isPublishing = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    await ref.read(marketplaceNotifierProvider.notifier).addSwapListing(
          shiftDate: _selectedDate,
          shiftType: _shiftType,
          reason: reason,
        );

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نشر عرض التبادل في سوق القسم بنجاح! 🤝', style: AppTextStyles.bodySm.copyWith(color: AppColors.surface)),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        top: AppSpacing.xxl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.swap_horizontal_circle_rounded, color: AppColors.primary, size: 26),
                    const SizedBox(width: AppSpacing.md),
                    Text('نشر طلب تبادل جديد', style: AppTextStyles.headingLg),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.secondaryLow),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('اختر الوردية التي ترغب في التنازل عنها أو تبديلها مع زملائك بالقسم.', style: AppTextStyles.bodyMd),

            const SizedBox(height: AppSpacing.xxl),

            // Date Selection
            Text('تاريخ ورديتي المطلوب تبديلها', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.surfaceAlt),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE، d MMMM yyyy', 'ar').format(_selectedDate),
                      style: AppTextStyles.headingSm.copyWith(color: AppColors.primary),
                    ),
                    const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Shift type selection
            Text('نوع الوردية', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text('صباحي طويل (12h)', style: AppTextStyles.label),
                    selected: _shiftType == 'صباحي طويل (12h)',
                    selectedColor: AppColors.shiftLong.withOpacity(0.2),
                    onSelected: (v) {
                      if (v) setState(() => _shiftType = 'صباحي طويل (12h)');
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ChoiceChip(
                    label: Text('سهر ليلي (12h)', style: AppTextStyles.label),
                    selected: _shiftType == 'سهر ليلي (12h)',
                    selectedColor: AppColors.shiftNight.withOpacity(0.2),
                    onSelected: (v) {
                      if (v) setState(() => _shiftType = 'سهر ليلي (12h)');
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // Reason input
            Text('سبب التبادل / ملاحظات للزملاء', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'اكتب سبب التبادل هنا (مثال: ظرف عائلي طارئ وسفر أو التزام دراسي)...',
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.all(AppSpacing.md),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                icon: _isPublishing
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface))
                    : const Icon(Icons.send_rounded),
                label: Text(_isPublishing ? 'جاري نشر العرض...' : 'نشر طلب التبادل بالسوق الآن'),
                onPressed: _isPublishing ? null : _publishSwap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
