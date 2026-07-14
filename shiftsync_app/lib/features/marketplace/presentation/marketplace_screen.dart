import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_chip.dart';
import 'providers/marketplace_provider.dart';
import 'widgets/create_swap_modal.dart';

/// MarketplaceScreen — Rich bilingual/Arabic-first screen allowing medical staff
/// to view peer swap requests, filter by status, publish listings, and accept shifts.
class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  int _filterIndex = 0; // 0: All, 1: My requests

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(marketplaceNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('سوق تبادلات الورديات', style: AppTextStyles.displayMd),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(marketplaceNotifierProvider.notifier).refresh(),
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
            builder: (_) => const CreateSwapModal(),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        icon: const Icon(Icons.add_rounded),
        label: Text('طلب تبادل جديد', style: AppTextStyles.label.copyWith(color: AppColors.surface)),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(marketplaceNotifierProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner Card
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(Icons.handshake_rounded, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('التبادل الآمن بين الزملاء', style: AppTextStyles.headingSm),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'تتم الموافقة على عروض التبادل وتوثيقها تلقائياً في جدول القسم فور قبول الزميل.',
                            style: AppTextStyles.bodySm,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Filter Tabs
              Row(
                children: [
                  _buildFilterChip('كل العروض المتاحة', 0),
                  const SizedBox(width: AppSpacing.sm),
                  _buildFilterChip('طلباتي المنشورة', 1),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Listings list
              listingsAsync.when(
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.xxxl), child: CircularProgressIndicator())),
                error: (err, _) => Center(child: Text('حدث خطأ في تحميل عروض التبادل.', style: AppTextStyles.bodyMd)),
                data: (items) {
                  final filtered = _filterIndex == 1
                      ? items.where((e) => e['is_mine'] == true).toList()
                      : items;

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxxl),
                        child: Column(
                          children: [
                            const Icon(Icons.inbox_rounded, size: 56, color: AppColors.surfaceAlt),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _filterIndex == 1
                                  ? 'لم تقم بنشر أي طلبات تبادل بعد.'
                                  : 'لا توجد عروض تبادل مفتوحة حالياً في القسم.',
                              style: AppTextStyles.bodyMd,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: filtered.map((listing) => _buildListingCard(context, listing)).toList(),
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

  Widget _buildListingCard(BuildContext context, Map<String, dynamic> listing) {
    final isMine = listing['is_mine'] == true;
    DateTime? date;
    try {
      date = DateTime.parse(listing['shift_date']);
    } catch (_) {
      date = DateTime.now();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: AppCard(
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
                      backgroundColor: isMine ? AppColors.shiftLong.withOpacity(0.2) : AppColors.primaryLight,
                      child: Text(
                        (listing['requester_name'] as String).substring(0, 3),
                        style: AppTextStyles.label.copyWith(color: isMine ? AppColors.shiftLong : AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(listing['requester_name'] ?? 'زميل', style: AppTextStyles.headingSm),
                        Text(listing['requester_role'] ?? 'القسم الطبي', style: AppTextStyles.bodySm),
                      ],
                    ),
                  ],
                ),
                StatusChip(status: listing['status'] ?? 'مفتوح'),
              ],
            ),
            const Divider(height: AppSpacing.xl, color: AppColors.surfaceAlt),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الوردية المطلوب تبديلها:', style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      DateFormat('EEEE، d MMMM yyyy', 'ar').format(date),
                      style: AppTextStyles.headingSm.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.surfaceAlt),
                  ),
                  child: Text(listing['shift_type'] ?? '12h', style: AppTextStyles.label),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('السبب / الملاحظة: ${listing['reason']}', style: AppTextStyles.bodySm.copyWith(color: AppColors.secondaryLow)),
            const SizedBox(height: AppSpacing.lg),
            if (isMine)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.debtRed,
                    side: const BorderSide(color: AppColors.debtRed),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('سحب وإلغاء هذا العرض'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم سحب طلب التبادل من السوق بنجاح.', style: AppTextStyles.bodySm.copyWith(color: AppColors.surface)),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.claimGreen, foregroundColor: AppColors.surface),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: const Text('قبول التبادل والتغطية'),
                  onPressed: () => _confirmAcceptSwap(context, listing),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAcceptSwap(BuildContext context, Map<String, dynamic> listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Row(
          children: [
            const Icon(Icons.handshake_rounded, color: AppColors.claimGreen, size: 28),
            const SizedBox(width: AppSpacing.md),
            Text('تأكيد قبول التبادل', style: AppTextStyles.headingLg),
          ],
        ),
        content: Text(
          'هل ترغب في الموافقة على تغطية وردية ${listing['requester_name']} ليوم ${listing['shift_date'].toString().split('T')[0]}؟ سيتم إضافة هذه الوردية إلى جدولك الخاص وتحديث النظام.',
          style: AppTextStyles.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('إلغاء', style: AppTextStyles.label.copyWith(color: AppColors.secondaryLow)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.claimGreen, foregroundColor: AppColors.surface),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('تأكيد الموافقة'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم قبول التبادل وإضافته لجدول مناوباتك بنجاح! ✅', style: AppTextStyles.bodySm.copyWith(color: AppColors.surface)),
          backgroundColor: AppColors.claimGreen,
        ),
      );
    }
  }
}
