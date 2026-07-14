import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_card.dart';
import '../widgets/shift_badge.dart';
import '../widgets/shift_calendar.dart';
import '../widgets/status_chip.dart';
import '../../features/ledger/presentation/providers/ledger_provider.dart';
import '../../features/schedule/presentation/providers/schedule_provider.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/schedule/presentation/widgets/day_details_sheet.dart';
import '../../features/schedule/presentation/widgets/add_edit_shift_modal.dart';
import '../../features/marketplace/presentation/marketplace_screen.dart';
import '../../features/ledger/presentation/ledger_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';

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

  Future<void> _confirmAndLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.debtRed, size: 28),
            const SizedBox(width: AppSpacing.md),
            Text('تسجيل الخروج', style: AppTextStyles.headingLg),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج من نظام شِفْتَك وإخلاء الجلسة المؤقتة من هذا الجهاز؟',
          style: AppTextStyles.bodyMd,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('إلغاء', style: AppTextStyles.label.copyWith(color: AppColors.secondaryLow)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.debtRed,
              foregroundColor: AppColors.surface,
            ),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('تسجيل الخروج'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final repo = ref.read(authRepositoryProvider);
      await repo.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تسجيل الخروج من حسابك بنجاح. نراك قريباً 👋', style: AppTextStyles.bodySm.copyWith(color: AppColors.surface)),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
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

  Widget _buildAccountScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('حسابي والملف الشخصي', style: AppTextStyles.displayMd),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.debtRed),
            tooltip: 'تسجيل الخروج',
            onPressed: () => _confirmAndLogout(context),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Header Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      'ك س',
                      style: AppTextStyles.displayMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('كمال سرور', style: AppTextStyles.headingLg),
                        const SizedBox(height: AppSpacing.xs),
                        Text('مدير النظام (Super Admin)', style: AppTextStyles.bodySm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.xs),
                        Text('الهاتف: 07800000000\nالقسم: الطوارئ (Emergency)', style: AppTextStyles.monoMd.copyWith(fontSize: 13, color: AppColors.secondaryLow)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),
            Text('إعدادات النظام والتطبيقات', style: AppTextStyles.headingMd),
            const SizedBox(height: AppSpacing.md),

            AppCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                    title: Text('إشعارات المناوبات والتبادلات', style: AppTextStyles.bodyMd),
                    trailing: Switch(value: true, activeColor: AppColors.primary, onChanged: (v) {}),
                  ),
                  const Divider(height: 1, color: AppColors.surfaceAlt),
                  ListTile(
                    leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                    title: Text('لغة واجهة الاستخدام', style: AppTextStyles.bodyMd),
                    trailing: Text('العربية (ar)', style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                  ),
                  const Divider(height: 1, color: AppColors.surfaceAlt),
                  ListTile(
                    leading: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                    title: Text('المظهر والسمات', style: AppTextStyles.bodyMd),
                    trailing: Text('الوضع النهاري', style: AppTextStyles.label.copyWith(color: AppColors.secondaryLow)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),
            Text('الأمان والجلسة', style: AppTextStyles.headingMd),
            const SizedBox(height: AppSpacing.md),

            // Prominent Logout Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.security_rounded, color: AppColors.secondaryLow),
                      const SizedBox(width: AppSpacing.sm),
                      Text('إدارة الجلسة الحالية', style: AppTextStyles.headingSm),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('يمكنك تسجيل الخروج من الجهاز الحالي مع الاحتفاظ بكافة بيانات ومناوبات حسابك بأمان في خوادم شِفْتَك.', style: AppTextStyles.bodySm),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.debtRed,
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('تسجيل الخروج من نظام شِفْتَك'),
                      onPressed: () => _confirmAndLogout(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent(
    Map<DateTime, ShiftType> shifts,
    AsyncValue<List<Map<String, dynamic>>> ledgerAsync,
  ) {
    if (_currentIndex == 1) {
      return const MarketplaceScreen();
    }
    if (_currentIndex == 2) {
      return const LedgerScreen();
    }
    if (_currentIndex == 3) {
      return const NotificationsScreen();
    }
    if (_currentIndex == 4) {
      return _buildAccountScreen(context);
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
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.debtRed),
            tooltip: 'تسجيل الخروج',
            onPressed: () => _confirmAndLogout(context),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('تقويم الورديات (تصفح شهر بشهر)', style: AppTextStyles.label),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                  label: Text('إضافة مناوبة', style: AppTextStyles.label.copyWith(color: AppColors.surface)),
                  onPressed: () {
                    final normalized = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => AddEditShiftModal(
                        initialDate: _selectedDay,
                        initialShift: shifts[normalized] ?? _fallbackShifts[normalized],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ShiftCalendar(
              selectedDay: _selectedDay,
              onDaySelected: (selected, focused) {
                setState(() => _selectedDay = selected);
                final normalized = DateTime(selected.year, selected.month, selected.day);
                final assigned = shifts[normalized] ?? _fallbackShifts[normalized] ?? ShiftType.off;
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => DayDetailsSheet(
                    selectedDate: selected,
                    assignedShift: assigned,
                    onSwitchToMarketplace: () => setState(() => _currentIndex = 1),
                  ),
                );
              },
              shifts: shifts,
            ),

            const SizedBox(height: AppSpacing.xxxl),

            Text('الورديات المجدولة لليوم المختار (${DateFormat('yyyy-MM-dd').format(_selectedDay)})', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.md),

            Builder(
              builder: (context) {
                final normalized = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
                final currentShift = shifts[normalized] ?? _fallbackShifts[normalized] ?? ShiftType.off;
                final isOff = currentShift == ShiftType.off;

                return AppCard(
                  accentColor: isOff
                      ? AppColors.shiftOff
                      : currentShift == ShiftType.long
                          ? AppColors.shiftLong
                          : AppColors.shiftNight,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => DayDetailsSheet(
                        selectedDate: _selectedDay,
                        assignedShift: currentShift,
                        onSwitchToMarketplace: () => setState(() => _currentIndex = 1),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOff
                                ? 'إجازة / راحة اليوم المختار'
                                : currentShift == ShiftType.long
                                    ? 'وردية صباحية طويلة • ١٢ ساعة'
                                    : 'وردية سهر ليلية • ١٢ ساعة',
                            style: AppTextStyles.headingMd,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            isOff
                                ? 'اضغط لعرض تفاصيل الزملاء أو إضافة وردية جديدة'
                                : currentShift == ShiftType.long
                                    ? '٠٧:٣0 صباحاً – ٠٧:٣٠ مساءً (اضغط للتفاصيل)'
                                    : '٠٧:٣٠ مساءً – ٠٧:٣٠ صباحاً (اضغط للتفاصيل)',
                            style: AppTextStyles.bodySm,
                          ),
                        ],
                      ),
                      ShiftBadge(shiftType: currentShift),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            AppCard(
              accentColor: AppColors.shiftNight,
              onTap: () {
                final nextDay = _selectedDay.add(const Duration(days: 1));
                final normalizedNext = DateTime(nextDay.year, nextDay.month, nextDay.day);
                final nextShift = shifts[normalizedNext] ?? _fallbackShifts[normalizedNext] ?? ShiftType.night;
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => DayDetailsSheet(
                    selectedDate: nextDay,
                    assignedShift: nextShift,
                    onSwitchToMarketplace: () => setState(() => _currentIndex = 1),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('المناوبة التالية (${DateFormat('yyyy-MM-dd').format(_selectedDay.add(const Duration(days: 1)))})', style: AppTextStyles.headingMd),
                      const SizedBox(height: AppSpacing.xs),
                      Text('٠٧:٣٠ مساءً – ٠٧:٣٠ صباحاً (اضغط لعرض التفاصيل)', style: AppTextStyles.bodySm),
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
                  final amount = entry['amount_egp'] ?? entry['amount'] ?? 400;
                  final isOwed = entry['is_claim'] == true || entry['is_debtor'] == false;
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
                            '${_formatArabicAmount(amount)} ج.م',
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

  String _formatArabicAmount(dynamic amount) {
    final numVal = (amount is num) ? amount : double.tryParse(amount.toString()) ?? 0;
    final intVal = numVal.truncate();
    final westernStr = intVal.toString();
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final buffer = StringBuffer();
    for (int i = 0; i < westernStr.length; i++) {
      final code = westernStr.codeUnitAt(i);
      if (code >= 48 && code <= 57) {
        buffer.write(arabicDigits[code - 48]);
      } else {
        buffer.write(westernStr[i]);
      }
    }
    return buffer.toString();
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
