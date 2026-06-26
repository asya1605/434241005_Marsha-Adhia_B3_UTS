import 'package:flutter/material.dart';
import '../../../../core/theme/theme_provider.dart';

/// Design tokens hasil redesign dashboard.
/// Biru utama: sky blue (#2B9FF0) — bukan indigo/ungu.
class AppColors {
  AppColors._();

  static bool get isDark => ThemeProvider.isDark;

  // Primary
  static const Color primary = Color(0xFF2B9FF0);
  static Color get primaryDark => isDark ? const Color(0xFF161B2E) : const Color(0xFF1565D8);
  static Color get primaryLight => isDark ? const Color(0xFF1A2F50) : const Color(0xFFEBF6FF);

  // Background
  static Color get bgPage => isDark ? const Color(0xFF0F1117) : const Color(0xFFF4F6FA);
  static Color get bgCard => isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);

  // Status
  static Color get statusOpenBg => isDark ? const Color(0xFF334155) : const Color(0xFFF4F6FA);
  static Color get statusOpenText => isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
  static Color get statusProgressBg => isDark ? const Color(0xFF172554) : const Color(0xFFEBF6FF);
  static Color get statusProgressText => isDark ? const Color(0xFF60A5FA) : const Color(0xFF2B9FF0);
  static Color get statusClosedBg => isDark ? const Color(0xFF064E3B) : const Color(0xFFE3F5EC);
  static Color get statusClosedText => isDark ? const Color(0xFF34D399) : const Color(0xFF1F9D63);
  static Color get statusWarningBg => isDark ? const Color(0xFF78350F) : const Color(0xFFFDF1DE);
  static Color get statusWarningText => isDark ? const Color(0xFFFBBF24) : const Color(0xFFC8870C);
  static const Color statusDangerDot = Color(0xFFE24B4A);

  // Category Colors (Task 5)
  static const Color categoryNetwork = Color(0xFF2B9FF0);
  static const Color categoryHardware = Color(0xFF7C3AED);
  static const Color categorySoftware = Color(0xFF1F9D63);
  static const Color categoryOther = Color(0xFF6B7280);

  // Card Shadow (Task 6)
  static final BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.06),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );

  // Centralized Card Getters (Task 7)
  static Color cardBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);

  static Color cardBorderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

  // Text
  static Color get textPrimary => isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A2E);
  static Color get textSecondary => isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
  static Color get textTertiary => isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF);

  // Border
  static Color get borderLight => isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

  /// Mapping status tiket -> (background, text color).
  /// Dipakai oleh TicketBoardingCard & StatCardGrid agar konsisten.
  static (Color bg, Color text) statusColors(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return (statusOpenBg, statusOpenText);
      case 'in_progress':
      case 'process':
      case 'pending':
      case 'diproses':
        return (statusProgressBg, statusProgressText);
      case 'closed':
      case 'resolved':
      case 'done':
        return (statusClosedBg, statusClosedText);
      default:
        return (statusOpenBg, statusOpenText);
    }
  }
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
}

class AppRadius {
  AppRadius._();
  static const double card = 12.0;
  static const double chip = 10.0;
  static const double hero = 14.0;
  static const double pill = 20.0;
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get sectionHeading => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get cardTitle => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMeta => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get caption => TextStyle(
    fontSize: 10,
    color: AppColors.textTertiary,
  );

  static TextStyle get statNumber => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
}
