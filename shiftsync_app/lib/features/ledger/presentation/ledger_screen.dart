import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_chip.dart';
import 'providers/ledger_provider.dart';
import 'widgets/create_ledger_entry_modal.dart';

/// LedgerScreen — Financial ledger screen in EGP allowing medical staff
/// to track debts/claims, settle balances, and record new IOUs cleanly.
class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  int _filterIndex = 0; // 0: All, 1: Unsettled only

  @override
  Widget build(BuildContext context) {
    final ledgerAsync = ref.watch(ledgerNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('المحفظة المالية والديون (EGP)', style: AppTextStyles.displayMd),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(ledgerNotifierProvider.notifier).fetchEntries(),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const CreateLedgerEntryModal(),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        icon: const Icon(Icons.add_rounded),
        label: Text('تسجيل مطالبة / سلفة', style: AppTextStyles.label.copyWith(color: AppColors.surface)),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(ledgerNotifierProvider.notifier).fetchEntries(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary KPI Row
              ledgerAsync.when(
                loading: () => _buildSummaryRow(400.0, 800.0),
                error: (_, __) => _buildSummaryRow(400.0, 800.0),
                data: (entries) {
                  double totalDebit = 0;
                  double totalCredit = 0;
                  for (final e in entries) {
                    if (e['is_settled'] != true && e['status'] != 'مسدد') {
                      final amt = (e['amount'] is num) ? (e['amount'] as num).toDouble() : 0.0;
                      if (e['is_debtor'] == true) {
                        totalDebit += amt;
                      } else {
                        totalCredit += amt;
                      }
                    }
                  }
                  return _buildSummaryRow(totalDebit, totalCredit);
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              // Filters
              Row(
                children: [
                  _buildFilterChip('كل المعاملات المالية', 0),
                  const SizedBox(width: AppSpacing.sm),
                  _buildFilterChip('الديون غير المسددة', 1),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Transactions list
              ledgerAsync.when(
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.xxxl), child: CircularProgressIndicator())),
                error: (err, _) => Center(child: Text('حدث خطأ في تحميل المعاملات.', style: AppTextStyles.bodyMd)),
                data: (entries) {
                  final filtered = _filterIndex == 1
                      ? entries.where((e) => e['is_settled'] != true && e['status'] != 'مسدد').toList()
                      : entries;

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxxl),
                        child: Column(
                          children: [
                            const Icon(Icons.account_balance_wallet_outlined, size: 56, color: AppColors.surfaceAlt),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _filterIndex == 1 ? 'لا توجد ديون معلقة حالياً! محفظتك متزنة ⚖️' : 'لا توجد أي معاملات مسجلة حتى الآن.',
                              style: AppTextStyles.bodyMd,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: filtered.map((entry) => _buildTransactionCard(context, entry)).toList(),
                  );
                },
              ),
              const SizedBox(height: 80), // space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(double debit, double credit) {
    return Row(
      children: [
        Expanded(
          child: AppCard(
            accentColor: AppColors.debtRed,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('عليا فلوس (I OWE)', style: AppTextStyles.label.copyWith(color: AppColors.secondaryLow)),
                    const Icon(Icons.call_made_rounded, color: AppColors.debtRed, size: 18),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${debit.toStringAsFixed(debit.truncateToDouble() == debit ? 0 : 1)} ج.م',
                  style: AppTextStyles.displayMd.copyWith(color: AppColors.debtRed),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppCard(
            accentColor: AppColors.claimGreen,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ليا فلوس (OWED TO ME)', style: AppTextStyles.label.copyWith(color: AppColors.secondaryLow)),
                    const Icon(Icons.call_received_rounded, color: AppColors.claimGreen, size: 18),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${credit.toStringAsFixed(credit.truncateToDouble() == credit ? 0 : 1)} ج.م',
                  style: AppTextStyles.displayMd.copyWith(color: AppColors.claimGreen),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _filterIndex == index;
    return ChoiceChip(
      label: Text(
        label,
        style: AppTextStyles.label.copyWith(color: isSelected ? AppColors.surface : AppColors.secondaryLow),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      onSelected: (_) => setState(() => _filterIndex = index),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Map<String, dynamic> entry) {
    final isDebtor = entry['is_debtor'] == true;
    final isSettled = entry['is_settled'] == true || entry['status'] == 'مسدد';
    final amt = (entry['amount'] is num) ? (entry['amount'] as num).toDouble() : 0.0;
    DateTime? date;
    try {
      date = DateTime.parse(entry['created_at']);
    } catch (_) {
      date = DateTime.now();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: AppCard(
        accentColor: isSettled ? AppColors.secondaryLow : (isDebtor ? AppColors.debtRed : AppColors.claimGreen),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isDebtor ? AppColors.debtRed.withOpacity(0.15) : AppColors.claimGreen.withOpacity(0.15),
                      child: Icon(
                        isDebtor ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        color: isDebtor ? AppColors.debtRed : AppColors.claimGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry['counterparty_name'] ?? 'زميل', style: AppTextStyles.headingSm),
                        Text(
                          isDebtor ? 'أنا مدين له (سلفة / بدل)' : 'أنا دائن له (مطالبة مالية)',
                          style: AppTextStyles.bodySm.copyWith(
                            color: isDebtor ? AppColors.debtRed : AppColors.claimGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                StatusChip(status: isSettled ? 'مسدد' : 'غير مسدد'),
              ],
            ),
            const Divider(height: AppSpacing.xl, color: AppColors.surfaceAlt),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    entry['description'] ?? 'بدل وردية / سلفة مالية',
                    style: AppTextStyles.bodyMd,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  '${amt.toStringAsFixed(amt.truncateToDouble() == amt ? 0 : 1)} ج.م',
                  style: AppTextStyles.headingLg.copyWith(
                    color: isSettled ? AppColors.secondaryLow : (isDebtor ? AppColors.debtRed : AppColors.claimGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'مسجل بتاريخ: ${DateFormat('yyyy-MM-dd').format(date)}',
              style: AppTextStyles.caption.copyWith(color: AppColors.secondaryLow),
            ),
            if (!isSettled) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: const Text('تسوية وسداد المعاملة الآن'),
                  onPressed: () => _confirmSettle(context, entry),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSettle(BuildContext context, Map<String, dynamic> entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 28),
            const SizedBox(width: AppSpacing.md),
            Text('تأكيد تسوية الدين', style: AppTextStyles.headingLg),
          ],
        ),
        content: Text(
          'هل تم سداد وتسوية مبلغ (${entry['amount']} ج.م) مع الزميل ${entry['counterparty_name']} بشكل نهائي؟ سيتم أرشفة المعاملة كمسددة.',
          style: AppTextStyles.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('إلغاء', style: AppTextStyles.label.copyWith(color: AppColors.secondaryLow)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.surface),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('تأكيد التسوية'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final id = entry['id'] as int? ?? 0;
      await ref.read(ledgerNotifierProvider.notifier).settleEntry(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم توثيق تسوية وسداد المبلغ بنجاح! ✅', style: AppTextStyles.bodySm.copyWith(color: AppColors.surface)),
            backgroundColor: AppColors.claimGreen,
          ),
        );
      }
    }
  }
}
