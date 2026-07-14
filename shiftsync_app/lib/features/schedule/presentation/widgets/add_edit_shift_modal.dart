import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/shift_badge.dart';
import '../providers/schedule_provider.dart';

/// AddEditShiftModal — Interactive modal supporting both:
/// 1. ⚡ الإضافة السريعة لمناوبات الشهر (Batch Shift Planner) for up to 15+ shifts in seconds.
/// 2. 📅 تعديل يوم محدد (Single Day) for tweaking one specific day.
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
  bool _isBatchMode = true; // Default to fast monthly batch mode right away

  // Single day state
  late DateTime _selectedDate;
  late ShiftType _selectedType;
  final _noteController = TextEditingController();

  // Batch planner state
  late DateTime _batchMonthDate;
  ShiftType _activeStamp = ShiftType.night; // Default active stamp when stamping days
  final Map<DateTime, ShiftType> _batchShifts = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedType = widget.initialShift ?? ShiftType.long;

    // If initialDate is near end of month (e.g. day >= 20), default batch month to NEXT month
    // as nurses typically plan the upcoming month before the 1st of the month.
    if (widget.initialDate.day >= 20) {
      _batchMonthDate = DateTime(widget.initialDate.year, widget.initialDate.month + 1, 1);
    } else {
      _batchMonthDate = DateTime(widget.initialDate.year, widget.initialDate.month, 1);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickSingleDate() async {
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

  Future<void> _saveSingleShift() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 200));
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

  Future<void> _saveBatchShifts() async {
    if (_batchShifts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('برجاء ختم/تحديد يوم واحد على الأقل قبل الحفظ.', style: AppTextStyles.bodySm.copyWith(color: AppColors.surface)),
          backgroundColor: AppColors.debtRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    await ref.read(scheduleNotifierProvider.notifier).updateBatchShifts(_batchShifts);

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم اعتماد وحفظ ${_batchShifts.length} مناوبة لشهر ${DateFormat('MMMM yyyy', 'ar').format(_batchMonthDate)} دفعة واحدة في ثوانٍ!',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.surface, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.claimGreen,
      ),
    );
  }

  void _changeBatchMonth(int monthDelta) {
    setState(() {
      _batchMonthDate = DateTime(_batchMonthDate.year, _batchMonthDate.month + monthDelta, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
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
              // Header & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 26),
                      const SizedBox(width: AppSpacing.sm),
                      Text('إدارة مناوبات القسم', style: AppTextStyles.headingLg),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.secondaryLow),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Mode Switcher Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildModeTab(
                        label: '⚡ جدولة سريعة (شهر كامل)',
                        isActive: _isBatchMode,
                        onTap: () => setState(() => _isBatchMode = true),
                      ),
                    ),
                    Expanded(
                      child: _buildModeTab(
                        label: '📅 يوم محدد',
                        isActive: !_isBatchMode,
                        onTap: () => setState(() => _isBatchMode = false),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              if (_isBatchMode) _buildBatchPlannerContent() else _buildSingleDayContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeTab({required String label, required bool isActive, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: isActive ? AppShadows.cardShadow : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isActive ? AppColors.primaryDark : AppColors.secondaryLow,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ==================== BATCH MONTHLY PLANNER CONTENT ====================
  Widget _buildBatchPlannerContent() {
    final int daysInMonth = DateTime(_batchMonthDate.year, _batchMonthDate.month + 1, 0).day;
    final int nightCount = _batchShifts.values.where((e) => e == ShiftType.night).length;
    final int longCount = _batchShifts.values.where((e) => e == ShiftType.long).length;
    final int offCount = _batchShifts.values.where((e) => e == ShiftType.off).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.touch_app_rounded, color: AppColors.primaryDark, size: 22),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'اختر الختم النشط أولاً (سهر / طويل)، ثم اضغط على أيام الشهر لتسجيل المناوبة فوراً بضغطة واحدة!',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Month Selector Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.surfaceAlt),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppColors.primary),
                tooltip: 'الشهر السابق',
                onPressed: () => _changeBatchMonth(-1),
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    DateFormat('MMMM yyyy', 'ar').format(_batchMonthDate),
                    style: AppTextStyles.headingMd.copyWith(color: AppColors.primaryDark),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: AppColors.primary),
                tooltip: 'الشهر التالي',
                onPressed: () => _changeBatchMonth(1),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Active Stamp Selector
        Text('١. اختر الختم النشط للختم على الأيام:', style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _buildStampButton(ShiftType.night, '🔴 سهر (Night)', AppColors.shiftNight),
            const SizedBox(width: AppSpacing.sm),
            _buildStampButton(ShiftType.long, '🟢 طويل (Long)', AppColors.shiftLong),
            const SizedBox(width: AppSpacing.sm),
            _buildStampButton(ShiftType.off, '⚪ راحة (Off)', AppColors.shiftOff),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // 31-Day Grid
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text('٢. اضغط على الأيام لختم الوردية فوراً:', style: AppTextStyles.label),
            ),
            if (_batchShifts.isNotEmpty)
              TextButton.icon(
                onPressed: () => setState(() => _batchShifts.clear()),
                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.debtRed),
                label: Text('مسح التحديد', style: AppTextStyles.caption.copyWith(color: AppColors.debtRed, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: 1.25,
          ),
          itemCount: daysInMonth,
          itemBuilder: (context, index) {
            final int dayNum = index + 1;
            final DateTime dayDate = DateTime(_batchMonthDate.year, _batchMonthDate.month, dayNum);
            final ShiftType? assigned = _batchShifts[dayDate];
            final String weekdayName = DateFormat('E', 'ar').format(dayDate);

            return InkWell(
              onTap: () {
                setState(() {
                  if (_batchShifts[dayDate] == _activeStamp) {
                    _batchShifts.remove(dayDate); // Toggle off if already stamped with same
                  } else {
                    _batchShifts[dayDate] = _activeStamp;
                  }
                });
              },
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Container(
                decoration: BoxDecoration(
                  color: assigned != null
                      ? _getShiftColor(assigned).withOpacity(0.18)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: assigned != null ? _getShiftColor(assigned) : AppColors.surfaceAlt,
                    width: assigned != null ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weekdayName,
                      style: AppTextStyles.caption.copyWith(
                        color: assigned != null ? _getShiftColor(assigned) : AppColors.secondaryLow,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$dayNum',
                      style: AppTextStyles.label.copyWith(
                        color: assigned != null ? _getShiftColor(assigned) : AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (assigned != null) ...[
                      const SizedBox(height: 2),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _getShiftColor(assigned),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: AppSpacing.xl),

        // Summary Bar & Save Action
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryBadge('إجمالي', '${_batchShifts.length}', AppColors.primary),
              _buildSummaryBadge('🔴 سهر', '$nightCount', AppColors.shiftNight),
              _buildSummaryBadge('🟢 طويل', '$longCount', AppColors.shiftLong),
              _buildSummaryBadge('⚪ راحة', '$offCount', AppColors.shiftOff),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              backgroundColor: AppColors.primary,
            ),
            icon: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface))
                : const Icon(Icons.check_circle_rounded),
            label: Text(
              _isSaving
                  ? 'جاري اعتماد جدول الشهر...'
                  : '💾 اعتماد وحفظ المناوبات دفعة واحدة (${_batchShifts.length} وردية)',
              style: AppTextStyles.label.copyWith(color: AppColors.surface, fontWeight: FontWeight.w700),
            ),
            onPressed: _isSaving ? null : _saveBatchShifts,
          ),
        ),
      ],
    );
  }

  Widget _buildStampButton(ShiftType type, String label, Color color) {
    final bool isSelected = _activeStamp == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeStamp = type),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: color,
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Column(
            children: [
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: isSelected ? AppColors.surface : color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isSelected)
                Text(
                  '✓ الختم النشط',
                  style: AppTextStyles.caption.copyWith(color: AppColors.surface, fontSize: 10),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBadge(String label, String count, Color color) {
    return Column(
      children: [
        Text(count, style: AppTextStyles.headingMd.copyWith(color: color, fontWeight: FontWeight.w700)),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.secondaryLow)),
      ],
    );
  }

  Color _getShiftColor(ShiftType type) {
    switch (type) {
      case ShiftType.long:
        return AppColors.shiftLong;
      case ShiftType.night:
        return AppColors.shiftNight;
      case ShiftType.off:
        return AppColors.shiftOff;
    }
  }

  // ==================== SINGLE DAY EDIT CONTENT ====================
  Widget _buildSingleDayContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('تاريخ الوردية', style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: _pickSingleDate,
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

        Text('نوع المناوبة (ساعات العمل)', style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _buildSingleShiftChoice(ShiftType.long, 'صباحي (12h)', AppColors.shiftLong),
            const SizedBox(width: AppSpacing.md),
            _buildSingleShiftChoice(ShiftType.night, 'سهر (12h)', AppColors.shiftNight),
            const SizedBox(width: AppSpacing.md),
            _buildSingleShiftChoice(ShiftType.off, 'إجازة / راحة', AppColors.shiftOff),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

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
            label: Text(_isSaving ? 'جاري حفظ الوردية...' : 'حفظ وتحديث الوردية لليوم المختار'),
            onPressed: _isSaving ? null : _saveSingleShift,
          ),
        ),
      ],
    );
  }

  Widget _buildSingleShiftChoice(ShiftType type, String label, Color color) {
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
