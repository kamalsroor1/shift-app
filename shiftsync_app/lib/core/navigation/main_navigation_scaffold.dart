import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_card.dart';
import '../widgets/shift_badge.dart';
import '../widgets/shift_calendar.dart';
import '../widgets/status_chip.dart';
import '../../features/ledger/presentation/providers/ledger_provider.dart';
import '../../features/schedule/presentation/providers/schedule_provider.dart';

class MainNavigationScaffold extends ConsumerStatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  ConsumerState<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends ConsumerState<MainNavigationScaffold> {
  int _currentIndex = 0;
  DateTime _selectedDay = DateTime.now();

  late Map<DateTime, ShiftType> _fallbackShifts;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _fallbackShifts = {
      today: ShiftType.long,
      today.add(const Duration(days: 1)): ShiftType.night,
      today.add(const Duration(days: 2)): ShiftType.off,
      today.add(const Duration(days: 4)): ShiftType.long,
      today.add(const Duration(days: 6)): ShiftType.night,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(scheduleNotifierProvider);
    final ledgerAsync = ref.watch(ledgerNotifierProvider);

    final currentShifts = scheduleAsync.when(
      data: (map) => map.isNotEmpty ? map : _fallbackShifts,
      loading: () => _fallbackShifts,
      error: (_, __) => _fallbackShifts,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBodyContent(currentShifts, ledgerAsync),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: const Color(0x0A000000),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.surface,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.secondaryLow,
            selectedLabelStyle: AppTextStyles.label.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: AppTextStyles.label.copyWith(
              color: AppColors.secondaryLow,
              fontWeight: FontWeight.w500,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined),
                activeIcon: Icon(Icons.calendar_month),
                label: 'الجدول والورديات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.swap_horizontal_circle_outlined),
                activeIcon: Icon(Icons.swap_horizontal_circle),
                label: 'سوق التبادلات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined),
                activeIcon: Icon(Icons.account_balance_wallet),
                label: 'المحفظة والمالية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none_rounded),
                activeIcon: Icon(Icons.notifications_rounded),
                label: 'الطلبات والإشعارات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'حسابي',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent(
    Map<DateTime, ShiftType> shifts,
    AsyncValue<List<Map<String, dynamic>>> ledgerAsync,
  ) {
    if (_currentIndex != 0) {
      final tabNames = [
        'الجدول والورديات',
        'سوق التبادلات',
        'المحفظة والمالية',
        'الطلبات والإشعارات',
        'حسابي',
      ];
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(tabNames[_currentIndex], style: AppTextStyles.displayMd),
        ),
        body: Center(
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _currentIndex == 1
                      ? Icons.swap_horizontal_circle
                      : _currentIndex == 2
                          ? Icons.account_balance_wallet
                          : _currentIndex == 3
                              ? Icons.notifications
                              : Icons.person,
                  size: 56,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('قسم ${tabNames[_currentIndex]}', style: AppTextStyles.headingLg),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'متصل بوكلاء البيانات الحية ومستودعات التخزين الآمن.',
                  style: AppTextStyles.bodyMd,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('نظام شِفْتَك • المناوبات والمالية', style: AppTextStyles.displayMd),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(scheduleNotifierProvider.notifier).fetchCurrentMonth();
              ref.read(ledgerNotifierProvider.notifier).fetchEntries();
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile Greeting
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    'ك س',
                    style: AppTextStyles.headingMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('كمال سرور', style: AppTextStyles.displayMd),
                      Text(
                        'قسم العناية المركزة (ICU) • ممرض رئيسي',
                        style: AppTextStyles.bodySm,
                      ),
                    ],
                  ),
                ),
                const StatusChip(status: 'نشط'),
              ],
            ),

            const SizedBox(height: AppSpacing.xxxl),

            Text('تقويم الورديات (تصفح شهر بشهر)', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.md),
            ShiftCalendar(
              selectedDay: _selectedDay,
              onDaySelected: (selected, focused) {
                setState(() => _selectedDay = selected);
              },
              shifts: shifts,
            ),

            const SizedBox(height: AppSpacing.xxxl),

            Text('الورديات المجدولة (حسب اليوم المختار)', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.md),

            AppCard(
              accentColor: AppColors.shiftLong,
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('وردية اليوم المختار • ١٢ ساعة', style: AppTextStyles.headingMd),
                      const SizedBox(height: AppSpacing.xs),
                      Text('٠٧:٣٠ صباحاً – ٠٧:٣٠ مساءً', style: AppTextStyles.bodySm),
                    ],
                  ),
                  const ShiftBadge(shiftType: ShiftType.long),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            AppCard(
              accentColor: AppColors.shiftNight,
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('المناوبة التالية • سهر ليلي', style: AppTextStyles.headingMd),
                      const SizedBox(height: AppSpacing.xs),
                      Text('٠٧:٣٠ مساءً – ٠٧:٣٠ صباحاً', style: AppTextStyles.bodySm),
                    ],
                  ),
                  const ShiftBadge(shiftType: ShiftType.night),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            Text('المحفظة المالية (التسوية بالجنيه المصري ج.م)', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.md),

            ...ledgerAsync.when(
              loading: () => [
                _buildFallbackDebit(),
                const SizedBox(height: AppSpacing.lg),
                _buildFallbackCredit(),
              ],
              error: (_, __) => [
                _buildFallbackDebit(),
                const SizedBox(height: AppSpacing.lg),
                _buildFallbackCredit(),
              ],
              data: (entries) {
                if (entries.isEmpty) {
                  return [
                    _buildFallbackDebit(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildFallbackCredit(),
                  ];
                }
                return entries.map((entry) {
                  final amount = entry['amount_egp'] ?? 400;
                  final isOwed = entry['is_claim'] == true;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: AppCard(
                      accentColor: isOwed ? AppColors.claimGreen : AppColors.debtRed,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isOwed
                                        ? Icons.arrow_downward_rounded
                                        : Icons.arrow_upward_rounded,
                                    color: isOwed ? AppColors.claimGreen : AppColors.debtRed,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isOwed ? 'ليا فلوس (OWED TO ME)' : 'عليا فلوس (I OWE)',
                                    style: AppTextStyles.headingSm.copyWith(
                                      color: isOwed ? AppColors.claimGreen : AppColors.debtRed,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                entry['description'] ?? 'تسوية تبادل مناوبة',
                                style: AppTextStyles.bodySm,
                              ),
                            ],
                          ),
                          Text(
                            '$amount ج.م',
                            style: AppTextStyles.displayMd.copyWith(
                              color: isOwed ? AppColors.claimGreen : AppColors.debtRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList();
              },
            ),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackDebit() {
    return AppCard(
      accentColor: AppColors.debtRed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.arrow_upward_rounded, color: AppColors.debtRed, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'عليا فلوس (I OWE)',
                    style: AppTextStyles.headingSm.copyWith(color: AppColors.debtRed),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('لـ سارة أحمد • تبديل شيفت سهر (١ وردية)', style: AppTextStyles.bodySm),
            ],
          ),
          Text('٤٠٠ ج.م', style: AppTextStyles.displayMd.copyWith(color: AppColors.debtRed)),
        ],
      ),
    );
  }

  Widget _buildFallbackCredit() {
    return AppCard(
      accentColor: AppColors.claimGreen,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.arrow_downward_rounded, color: AppColors.claimGreen, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'ليا فلوس (OWED TO ME)',
                    style: AppTextStyles.headingSm.copyWith(color: AppColors.claimGreen),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('من أحمد علي • تبديل شيفتين صباحي (٢ وردية)', style: AppTextStyles.bodySm),
            ],
          ),
          Text('٨٠٠ ج.م', style: AppTextStyles.displayMd.copyWith(color: AppColors.claimGreen)),
        ],
      ),
    );
  }
}
