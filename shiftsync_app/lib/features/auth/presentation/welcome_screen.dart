import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';
import 'login_screen.dart';

/// WelcomeScreen — Elegant Arabic-First onboarding & splash screen introducing ShiftSync.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Sleek Hero Logo Container inspired by clean white medical aesthetic
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: AppShadows.modalShadow,
                  border: Border.all(color: AppColors.primaryLight, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.sync_alt_rounded,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Title and Subtitle
              Text(
                'شِفْتَك • Shiftak',
                style: AppTextStyles.displayLg.copyWith(color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'المنصة الموحدة لإدارة المناوبات الطبية، تبديل الورديات الذكي، والتسويات المالية الفورية بين الزملاء.',
                style: AppTextStyles.bodyLg,
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Feature badges row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFeatureItem(Icons.calendar_month_rounded, 'جدول ذكي'),
                  _buildFeatureItem(Icons.swap_horizontal_circle_rounded, 'تبديل فوري'),
                  _buildFeatureItem(Icons.account_balance_wallet_rounded, 'تسوية بالجنيه'),
                ],
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Primary Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text('تسجيل الدخول للمناوبات'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'مخصص للكوادر الصحية بالمستشفيات والأقسام الحرجة (ICU)',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadows.cardShadow,
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.label),
      ],
    );
  }
}
