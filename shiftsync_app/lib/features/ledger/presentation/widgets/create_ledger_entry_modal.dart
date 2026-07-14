import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_tokens.dart';
import '../providers/ledger_provider.dart';

/// CreateLedgerEntryModal — Interactive modal allowing staff to log new EGP
/// financial claims (OWED TO ME) or debt acknowledgments (I OWE) with peers.
class CreateLedgerEntryModal extends ConsumerStatefulWidget {
  const CreateLedgerEntryModal({super.key});

  @override
  ConsumerState<CreateLedgerEntryModal> createState() => _CreateLedgerEntryModalState();
}

class _CreateLedgerEntryModalState extends ConsumerState<CreateLedgerEntryModal> {
  bool _isDebtor = true; // true = عليا (I OWE), false = ليا (OWED TO ME)
  final _peerController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _peerController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    final peer = _peerController.text.trim();
    final amountText = _amountController.text.trim();
    final desc = _descController.text.trim();

    if (peer.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى كتابة اسم الزميل والمبلغ المالي بالجنيه.', style: AppTextStyles.bodySm.copyWith(color: AppColors.surface)),
          backgroundColor: AppColors.debtRed,
        ),
      );
      return;
    }

    final double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال مبلغ مالي صحيح أكبر من الصفر.', style: AppTextStyles.bodySm.copyWith(color: AppColors.surface)),
          backgroundColor: AppColors.debtRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    await ref.read(ledgerNotifierProvider.notifier).addLedgerEntry(
          counterpartyName: peer,
          amount: amount,
          isDebtor: _isDebtor,
          description: desc.isEmpty ? 'تسوية مالية / بدل مناوبة' : desc,
        );

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isDebtor
              ? 'تم تسجيل السلفة المالية المستحقة عليك بنجاح.'
              : 'تم تسجيل المطالبة المالية المستحقة لك بنجاح.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.surface),
        ),
        backgroundColor: _isDebtor ? AppColors.debtRed : AppColors.claimGreen,
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
                    const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 26),
                    const SizedBox(width: AppSpacing.md),
                    Text('تسجيل معاملة مالية (ج.م)', style: AppTextStyles.headingLg),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.secondaryLow),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('وثّق السلف أو بدلات الورديات مع زملائك بالجنيه المصري.', style: AppTextStyles.bodyMd),

            const SizedBox(height: AppSpacing.xxl),

            // Direction selector
            Text('نوع المعاملة', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text('عليا فلوس (أنا مدين)', style: AppTextStyles.label),
                    selected: _isDebtor,
                    selectedColor: AppColors.debtRed.withOpacity(0.2),
                    onSelected: (v) {
                      if (v) setState(() => _isDebtor = true);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ChoiceChip(
                    label: Text('ليا فلوس (أنا دائن)', style: AppTextStyles.label),
                    selected: !_isDebtor,
                    selectedColor: AppColors.claimGreen.withOpacity(0.2),
                    onSelected: (v) {
                      if (v) setState(() => _isDebtor = false);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // Peer input
            Text('اسم الزميل / الطرف الآخر', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _peerController,
              decoration: InputDecoration(
                hintText: 'مثال: د. أحمد خالد أو ممرضة سارة...',
                filled: true,
                fillColor: AppColors.background,
                prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Amount input
            Text('المبلغ بالجنيه المصري (ج.م)', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              decoration: InputDecoration(
                hintText: 'مثال: 400.00',
                filled: true,
                fillColor: AppColors.background,
                prefixIcon: const Icon(Icons.attach_money_rounded, color: AppColors.primary),
                suffixText: 'ج.م',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Description input
            Text('الوصف أو سبب المطالبة (اختياري)', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                hintText: 'مثال: بدل سهر ليلي في طوارئ يوم الجمعة...',
                filled: true,
                fillColor: AppColors.background,
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
                  backgroundColor: _isDebtor ? AppColors.debtRed : AppColors.claimGreen,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                icon: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface))
                    : const Icon(Icons.check_circle_outline_rounded),
                label: Text(_isSaving ? 'جاري حفظ المعاملة...' : 'حفظ وإضافة للمحفظة المالية'),
                onPressed: _isSaving ? null : _saveEntry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
