import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_tokens.dart';
import 'core/widgets/app_card.dart';
import 'core/widgets/shift_badge.dart';
import 'core/widgets/shift_calendar.dart';
import 'core/widgets/status_chip.dart';
import 'features/auth/presentation/welcome_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ShiftSyncApp(),
    ),
  );
}

class ShiftSyncApp extends StatelessWidget {
  const ShiftSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shiftak • شِفْتَك',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Arabic-First Localization & RTL Support
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // App now officially starts from the Welcome Onboarding Screen!
      home: const WelcomeScreen(),
    );
  }
}

/// MainNavigationScaffold — Stateful container displaying our interactive calendar,
/// Egyptian Pound (`ج.م`) ledger items, and shift cards alongside bottom navigation.
class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;
  DateTime _selectedDay = DateTime.now();

  // Mock shifts mapped to normalized dates for testing month-by-month view
  late Map<DateTime, ShiftType> _mockShifts;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _mockShifts = {
      today: ShiftType.long,
      today.add(const Duration(days: 1)): ShiftType.night,
      today.add(const Duration(days: 2)): ShiftType.off,
      today.add(const Duration(days: 4)): ShiftType.long,
      today.add(const Duration(days: 6)): ShiftType.night,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBodyContent(),
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
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.surface,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.secondaryLow,
            selectedLabelStyle: AppTextStyles.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
            unselectedLabelStyle: AppTextStyles.label.copyWith(color: AppColors.secondaryLow, fontWeight: FontWeight.w500),
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

  Widget _buildBodyContent() {
    if (_currentIndex != 0) {
      final tabNames = ['الجدول والورديات', 'سوق التبادلات', 'المحفظة والمالية', 'الطلبات والإشعارات', 'حسابي'];
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
                  _currentIndex == 1 ? Icons.swap_horizontal_circle :
                  _currentIndex == 2 ? Icons.account_balance_wallet :
                  _currentIndex == 3 ? Icons.notifications : Icons.person,
                  size: 56,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('قسم ${tabNames[_currentIndex]}', style: AppTextStyles.headingLg),
                const SizedBox(height: AppSpacing.sm),
                Text('جاري تطوير هذه الشاشة ضمن مراحل الهيكل الأساسي.', style: AppTextStyles.bodyMd),
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
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile Greeting inspired by reference
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    'ك س',
                    style: AppTextStyles.headingMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('كمال سرور', style: AppTextStyles.displayMd),
                      Text('قسم العناية المركزة (ICU) • ممرض رئيسي', style: AppTextStyles.bodySm),
                    ],
                  ),
                ),
                const StatusChip(status: 'نشط'),
              ],
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Interactive Month/Week Shift Calendar
            Text('تقويم الورديات (تصفح شهر بشهر)', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.md),
            ShiftCalendar(
              selectedDay: _selectedDay,
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                });
              },
              shifts: _mockShifts,
            ),

            const SizedBox(height: AppSpacing.xxxl),

            Text('الورديات المجدولة (حسب اليوم المختار)', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.md),

            // Card 1: Long Day with Blue Accent bar on the RIGHT (RTL leading edge!)
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

            // Card 2: Night Shift with Indigo Accent bar on the RIGHT
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

            // Debit Card preview (عليا فلوس - شيفت بـ 400 ج.م)
            AppCard(
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
                          Text('عليا فلوس (I OWE)', style: AppTextStyles.headingSm.copyWith(color: AppColors.debtRed)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text('لـ سارة أحمد • تبديل شيفت سهر (١ وردية)', style: AppTextStyles.bodySm),
                    ],
                  ),
                  Text('٤٠٠ ج.م', style: AppTextStyles.displayMd.copyWith(color: AppColors.debtRed)),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Credit Card preview (ليا فلوس - شيفتين بـ 800 ج.م)
            AppCard(
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
                          Text('ليا فلوس (OWED TO ME)', style: AppTextStyles.headingSm.copyWith(color: AppColors.claimGreen)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text('من أحمد علي • تبديل شيفتين صباحي (٢ وردية)', style: AppTextStyles.bodySm),
                    ],
                  ),
                  Text('٨٠٠ ج.م', style: AppTextStyles.displayMd.copyWith(color: AppColors.claimGreen)),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}
