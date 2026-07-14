import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ShiftSync Design Tokens (Arabic-First RTL UI)
/// All values are immutable constants. No raw hex or dimensions outside this file.
class AppColors {
  AppColors._();

  // ── Brand & Primary ─────────────────────────────────────────────────────────
  static const Color primary       = Color(0xFF2563EB); // Blue 600   — actions, active state
  static const Color primaryLight  = Color(0xFFEFF6FF); // Blue 50    — surface tint
  static const Color primaryDark   = Color(0xFF1D4ED8); // Blue 700   — pressed state

  static const Color secondary     = Color(0xFF0F172A); // Slate 900  — dark headers
  static const Color secondaryMid  = Color(0xFF475569); // Slate 600  — body text
  static const Color secondaryLow  = Color(0xFF94A3B8); // Slate 400  — captions, icons

  // ── Surface & Background (Minimalist Clean Palette) ─────────────────────────
  static const Color background    = Color(0xFFF8FAFC); // Slate 50   — ultra-soft app bg
  static const Color surface       = Color(0xFFFFFFFF); // White      — pure white cards
  static const Color surfaceAlt    = Color(0xFFF1F5F9); // Slate 100  — secondary surfaces

  // ── Shift State Colors & Accent Bars ────────────────────────────────────────
  static const Color shiftLong     = Color(0xFF3B82F6); // Blue 500   — Long Day
  static const Color shiftLongBg   = Color(0xFFEFF6FF); // Blue 50
  static const Color shiftNight    = Color(0xFF6366F1); // Indigo 500 — Night shift
  static const Color shiftNightBg  = Color(0xFFEEF2FF); // Indigo 50
  static const Color shiftOff      = Color(0xFF64748B); // Slate 500  — Day Off
  static const Color shiftOffBg    = Color(0xFFF1F5F9); // Slate 100

  // ── Financial Ledger Colors ─────────────────────────────────────────────────
  static const Color debtRed       = Color(0xFFEF4444); // Red 500    — "I owe" / عليا فلوس
  static const Color debtRedBg     = Color(0xFFFEF2F2); // Red 50
  static const Color debtRedBorder = Color(0xFFFECACA); // Red 200
  static const Color claimGreen    = Color(0xFF22C55E); // Green 500  — "Owed to me" / ليا فلوس
  static const Color claimGreenBg  = Color(0xFFF0FDF4); // Green 50
  static const Color claimBorder   = Color(0xFFBBF7D0); // Green 200
  static const Color settledGray   = Color(0xFF94A3B8); // Slate 400  — Settled

  // ── Status & Feedback ───────────────────────────────────────────────────────
  static const Color success       = Color(0xFF16A34A); // Green 600
  static const Color warning       = Color(0xFFF59E0B); // Amber 500
  static const Color error         = Color(0xFFDC2626); // Red 600
  static const Color info          = Color(0xFF0284C7); // Sky 600

  // ── Swap State Colors ───────────────────────────────────────────────────────
  static const Color swapPending   = Color(0xFFF59E0B); // Amber 500
  static const Color swapAccepted  = Color(0xFF3B82F6); // Blue 500
  static const Color swapCompleted = Color(0xFF22C55E); // Green 500
  static const Color swapRejected  = Color(0xFFEF4444); // Red 500
  static const Color swapExpired   = Color(0xFF94A3B8); // Slate 400
}

class AppTextStyles {
  AppTextStyles._();

  // Arabic-First Typography using GoogleFonts.cairo for elegant, highly readable Arabic
  static TextStyle get _baseCairo => GoogleFonts.cairo();

  static TextStyle displayLg  = _baseCairo.copyWith(fontSize: 26, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.secondary);
  static TextStyle displayMd  = _baseCairo.copyWith(fontSize: 20, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.secondary);
  static TextStyle headingLg  = _baseCairo.copyWith(fontSize: 18, fontWeight: FontWeight.w700, height: 1.4, color: AppColors.secondary);
  static TextStyle headingMd  = _baseCairo.copyWith(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4, color: AppColors.secondary);
  static TextStyle headingSm  = _baseCairo.copyWith(fontSize: 14, fontWeight: FontWeight.w600, height: 1.5, color: AppColors.secondary);
  static TextStyle bodyLg     = _baseCairo.copyWith(fontSize: 15, fontWeight: FontWeight.w500, height: 1.6, color: AppColors.secondaryMid);
  static TextStyle bodyMd     = _baseCairo.copyWith(fontSize: 13, fontWeight: FontWeight.w500, height: 1.6, color: AppColors.secondaryMid);
  static TextStyle bodySm     = _baseCairo.copyWith(fontSize: 12, fontWeight: FontWeight.w500, height: 1.5, color: AppColors.secondaryMid);
  static TextStyle label      = _baseCairo.copyWith(fontSize: 12, fontWeight: FontWeight.w600, height: 1.4, color: AppColors.secondaryMid);
  static TextStyle caption    = _baseCairo.copyWith(fontSize: 11, fontWeight: FontWeight.w500, height: 1.4, color: AppColors.secondaryLow);
  static TextStyle buttonText = _baseCairo.copyWith(fontSize: 15, fontWeight: FontWeight.w700, height: 1.2, color: AppColors.surface);
  static TextStyle monoMd     = GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary);
}

class AppSpacing {
  AppSpacing._();
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double xxl  = 24.0;
  static const double xxxl = 32.0;
}

class AppRadius {
  AppRadius._();
  static const double sm   = 8.0;   // Tags, chips
  static const double md   = 12.0;  // Input fields, small cards
  static const double lg   = 18.0;  // Main floating cards matching reference
  static const double xl   = 24.0;  // Bottom sheets, modals
  static const double full = 999.0; // Pills, badges
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0E000000), blurRadius: 16, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x06000000), blurRadius: 4,  offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> modalShadow = [
    BoxShadow(color: Color(0x18000000), blurRadius: 32, offset: Offset(0, 12)),
  ];

  static const List<BoxShadow> none = [];
}
