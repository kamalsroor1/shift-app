import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../main.dart';

/// LoginScreen — Professional Arabic medical personnel authentication screen
/// adhering strictly to ShiftSync Design Tokens.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController(text: '01000000000');
  final _passwordController = TextEditingController(text: 'secret123');
  bool _obscurePassword = true;
  bool _rememberMe = true;

  void _navigateToMain() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const MainNavigationScaffold(),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('تسجيل الدخول', style: AppTextStyles.headingLg),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text('مرحباً بك مجدداً 👋', style: AppTextStyles.displayMd),
              const SizedBox(height: AppSpacing.xs),
              Text('أدخل بيانات الاعتماد الخاصة بك للوصول لجدول المناوبات والمالية.', style: AppTextStyles.bodyMd),

              const SizedBox(height: AppSpacing.xxxl),

              // Phone Number Input
              Text('رقم الهاتف المرتبط بالقسم', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: AppTextStyles.monoMd,
                decoration: InputDecoration(
                  hintText: '01xxxxxxxxx',
                  prefixIcon: const Icon(Icons.phone_android_rounded, color: AppColors.secondaryLow),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.surfaceAlt, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Password Input
              Text('كلمة المرور', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: AppTextStyles.monoMd,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.secondaryLow),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.secondaryLow,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.surfaceAlt, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _rememberMe = val ?? true;
                          });
                        },
                      ),
                      Text('تذكر الدخول على هذا الجهاز', style: AppTextStyles.bodySm),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('نسيت كلمة المرور؟', style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToMain,
                  child: const Text('دخول إلى مناوباتي'),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Quick Demo Login Button for convenient testing
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.bolt_rounded, color: AppColors.primary),
                  label: const Text('دخول تجريبي سريع (كمال سرور • ICU)'),
                  onPressed: _navigateToMain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
