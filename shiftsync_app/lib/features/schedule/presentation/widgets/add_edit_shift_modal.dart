import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/shift_badge.dart';
import '../providers/schedule_provider.dart';

/// AddEditShiftModal — Interactive modal allowing nurses/doctors to manually add
/// or modify a shift assignment for any specific date.
class AddEditShiftModal extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final ShiftType? initialShift;

  const AddEditShiftModal({
    super.key,
    required this.initialDate,
    this.initialShift,
  });

  @override
  ConsumerState<AddEditShiftModal> createState() => _AddEditShiftModalState();
}

class _AddEditShiftModalState extends ConsumerState<AddEditShiftModal> {
  late DateTime _selectedDate;
  late ShiftType _selectedType;
  final _noteController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedType = widget.initialShift ?? ShiftType.long;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2028, 12, 31),
      locale: const Locale('ar'),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveShift() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 300)); // smooth visual feedback
    if (!mounted) return;

    await ref.read(scheduleNotifierProvider.notifier).updateShift(_selectedDate, _selectedType);

    if (!mounted) return;
    Navigator.of(context).pop(_selectedType);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تحديث الوردية ليوم ${DateFormat('yyyy-MM-dd').format(_selectedDate)} بنجاح.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.surface),
        ),
        backgroundColor: AppColors.claimGreen,
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_calendar_rounded, color: AppColors.primary, size: 26),
                    const SizedBox(width: AppSpacing.md),
                    Text('إضافة / تعديل وردية', style: AppTextStyles.headingLg),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.secondaryLow),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('قم باختيار التاريخ وننوع المناوبة لجدولة عملك بالقسم.', style: AppTextStyles.bodyMd),

            const SizedBox(height: AppSpacing.xxl),

            // Date Picker Card
            Text('تاريخ الوردية', style: AppTextStyles.label),
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

            // Shift Type Picker
            Text('نوع المناوبة (ساعات العمل)', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _buildShiftChoice(ShiftType.long, 'صباحي (12h)', AppColors.shiftLong),
                const SizedBox(width: AppSpacing.md),
                _buildShiftChoice(ShiftType.night, 'سهر (12h)', AppColors.shiftNight),
                const SizedBox(width: AppSpacing.md),
                _buildShiftChoice(ShiftType.off, 'إجازة / راحة', AppColors.shiftOff),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // Optional note
            Text('ملاحظات الوردية (اختياري)', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'مثال: تغطية بديلة أو تبادل مع زميل...',
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.surfaceAlt),
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
                icon: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface))
                    : const Icon(Icons.check_circle_outline_rounded),
                label: Text(_isSaving ? 'جاري حفظ الوردية...' : 'حفظ وتحديث الوردية في الجدول'),
                onPressed: _isSaving ? null : _saveShift,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftChoice(ShiftType type, String label, Color color) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? color : AppColors.surfaceAlt,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              ShiftBadge(shiftType: type),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: isSelected ? color : AppColors.secondaryLow,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
