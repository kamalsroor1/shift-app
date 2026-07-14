import 'package:flutter/material.dart';
import 'app_tokens.dart';

/// ShiftSync Theme Configuration (Arabic-First RTL UI with Light & Dark Mode)
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.surface,
        secondary: AppColors.secondary,
        onSecondary: AppColors.surface,
        surface: AppColors.surface,
        onSurface: AppColors.secondary,
        error: AppColors.error,
        onError: AppColors.surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.displayMd,
        iconTheme: const IconThemeData(color: AppColors.secondary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          elevation: 0,
          textStyle: AppTextStyles.buttonText,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: const BorderSide(color: AppColors.secondaryLow, width: 1.5),
          textStyle: AppTextStyles.buttonText.copyWith(color: AppColors.secondary),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.secondaryLow,
        selectedLabelStyle: AppTextStyles.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
        unselectedLabelStyle: AppTextStyles.label.copyWith(color: AppColors.secondaryLow),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3B82F6), // Vibrant blue 500
        onPrimary: Colors.white,
        secondary: Color(0xFFE2E8F0), // Slate 200
        onSecondary: Color(0xFF0F172A),
        surface: Color(0xFF1E293B), // Slate 800
        onSurface: Color(0xFFF8FAFC), // Slate 50
        error: AppColors.error,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.displayMd.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: AppTextStyles.buttonText,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFF8FAFC),
          side: const BorderSide(color: Color(0xFF475569), width: 1.5),
          textStyle: AppTextStyles.buttonText.copyWith(color: const Color(0xFFF8FAFC)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        selectedItemColor: const Color(0xFF60A5FA), // Blue 400
        unselectedItemColor: const Color(0xFF64748B), // Slate 500
        selectedLabelStyle: AppTextStyles.label.copyWith(color: const Color(0xFF60A5FA), fontWeight: FontWeight.w700),
        unselectedLabelStyle: AppTextStyles.label.copyWith(color: const Color(0xFF64748B)),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

/// Helper Extension on BuildContext to provide clean, theme-aware colors across widgets.
extension DarkModeContextHelper on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get bg => isDarkMode ? const Color(0xFF0F172A) : AppColors.background;
  Color get cardSurface => isDarkMode ? const Color(0xFF1E293B) : AppColors.surface;
  Color get cardSurfaceAlt => isDarkMode ? const Color(0xFF334155) : AppColors.surfaceAlt;
  Color get textPrimary => isDarkMode ? const Color(0xFFF8FAFC) : AppColors.secondary;
  Color get textSecondary => isDarkMode ? const Color(0xFFCBD5E1) : AppColors.secondaryMid;
  Color get textMuted => isDarkMode ? const Color(0xFF94A3B8) : AppColors.secondaryLow;
  Color get borderColor => isDarkMode ? const Color(0xFF334155) : AppColors.surfaceAlt;
  Color get tintSurface => isDarkMode ? const Color(0xFF1E293B) : AppColors.primaryLight;
}
