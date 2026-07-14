import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_tokens.dart';
import 'core/widgets/app_card.dart';
import 'core/widgets/shift_badge.dart';
import 'core/widgets/status_chip.dart';

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
      title: 'ShiftSync • شِفْت سينك',
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
      home: const TokenDemoScreen(),
    );
  }
}

/// TokenDemoScreen — Visual presentation verifying Arabic-First UI tokens & right-side accent bars
/// inspired directly by our minimalist clean floating card reference design.
class TokenDemoScreen extends StatelessWidget {
  const TokenDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('نظام شِفْت سينك • المناوبات والمالية', style: AppTextStyles.displayMd),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
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

            const SizedBox(width: double.infinity, height: AppSpacing.xxxl),

            Text('الورديات القادمة هذا الأسبوع', style: AppTextStyles.label),
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
                      Text('غداً • الأربعاء ١٥ يوليو', style: AppTextStyles.headingMd),
                      const SizedBox(height: AppSpacing.xs),
                      Text('٠٧:٣٠ صباحاً – ٠٧:٣٠ مساءً (١٢ ساعة)', style: AppTextStyles.bodySm),
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
                      Text('الخميس • ١٦ يوليو', style: AppTextStyles.headingMd),
                      const SizedBox(height: AppSpacing.xs),
                      Text('٠٧:٣٠ مساءً – ٠٧:٣٠ صباحاً (سهر)', style: AppTextStyles.bodySm),
                    ],
                  ),
                  const ShiftBadge(shiftType: ShiftType.night),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Card 3: Day Off with Slate Accent bar on the RIGHT
            AppCard(
              accentColor: AppColors.shiftOff,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الجمعة • ١٧ يوليو', style: AppTextStyles.headingMd),
                      const SizedBox(height: AppSpacing.xs),
                      Text('يوم راحة مستحقة', style: AppTextStyles.bodySm),
                    ],
                  ),
                  const ShiftBadge(shiftType: ShiftType.off),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            Text('المحفظة المالية وسجل المداولات', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.md),

            // Debit Card preview (عليا فلوس)
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
                      Text('لـ سارة أحمد • تبديل مناوبة سهر', style: AppTextStyles.bodySm),
                    ],
                  ),
                  Text('٢٥,٠٠٠ دينار', style: AppTextStyles.displayMd.copyWith(color: AppColors.debtRed)),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Credit Card preview (ليا فلوس)
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
                      Text('من أحمد علي • مناوبة صباحية طويلة', style: AppTextStyles.bodySm),
                    ],
                  ),
                  Text('٣٠,٠٠٠ دينار', style: AppTextStyles.displayMd.copyWith(color: AppColors.claimGreen)),
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
