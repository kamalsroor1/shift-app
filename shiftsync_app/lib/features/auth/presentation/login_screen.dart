import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../main.dart';
import '../domain/repositories/auth_repository.dart';

/// LoginScreen — Professional Arabic medical personnel authentication screen
/// connected to live FastAPI backend via AuthRepository with offline/demo fallback.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController(text: '01000000000');
  final _passwordController = TextEditingController(text: 'secret123');
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  Future<void> _handleLiveLogin() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.login(_phoneController.text.trim(), _passwordController.text);
      if (mounted) {
        _navigateToMain();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message, style: AppTextStyles.bodySm.copyWith(color: AppColors.surface)),
            backgroundColor: AppColors.debtRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر الاتصال بالخادم. جرب زر الدخول التجريبي أو تأكد من الشبكة.', style: AppTextStyles.bodySm.copyWith(color: AppColors.surface)),
            backgroundColor: AppColors.debtRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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

              // Primary Action Button (Live API Auth)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLiveLogin,
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface))
                      : const Text('دخول إلى مناوباتي (خادم شِفْتَك الحي)'),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Quick Demo Login Button for instant offline / fallback testing
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.bolt_rounded, color: AppColors.primary),
                  label: const Text('دخول تجريبي سريع (وضع غير متصل / كمال سرور)'),
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
