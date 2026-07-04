import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../main.dart'; // import navigatorKey
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AppColors {
  AppColors._();

  static bool get isDark => ThemeProvider.isDark;

  static BuildContext? get _context => navigatorKey.currentContext;

  static RoleThemeColors get _roleColors {
    final ctx = _context;
    if (ctx != null) {
      try {
        final auth = Provider.of<AuthProvider>(ctx, listen: false);
        return RoleThemeColors.getColors(auth.role ?? 'user', isDark);
      } catch (_) {
        // fallback if AuthProvider is not available in context
      }
    }
    return RoleThemeColors.getColors('user', isDark);
  }

  // Primary
  static Color get primary => _roleColors.primary;
  static Color get primaryDark => _roleColors.primaryDark;
  static Color get primaryLight => _roleColors.secondary;
  static Color get blue => _roleColors.primary;

  // Background
  static Color get bgPage => _roleColors.scaffoldBg;
  static Color get bgCard => _roleColors.surface;

  // Status
  static Color get statusOpenBg => isDark ? const Color(0xFF334155) : const Color(0xFFF4F6FA);
  static Color get statusOpenText => isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
  static Color get statusProgressBg => isDark ? const Color(0xFF172554) : const Color(0xFFEBF6FF);
  static Color get statusProgressText => _roleColors.primary;
  static Color get statusClosedBg => isDark ? const Color(0xFF064E3B) : const Color(0xFFE3F5EC);
  static Color get statusClosedText => isDark ? const Color(0xFF34D399) : const Color(0xFF1F9D63);
  static Color get statusWarningBg => isDark ? const Color(0xFF78350F) : const Color(0xFFFDF1DE);
  static Color get statusWarningText => isDark ? const Color(0xFFFBBF24) : const Color(0xFFC8870C);
  static const Color statusDangerDot = Color(0xFFE24B4A);
  
  static Color get priorityHigh => const Color(0xFFEF4444);
  static Color get priorityMed => const Color(0xFFFBBF24);
  static Color get priorityLow => const Color(0xFF10B981);

  // Category Colors
  static Color get categoryNetwork => _roleColors.primary;
  static Color get categoryHardware => const Color(0xFFF59E0B);
  static Color get categorySoftware => const Color(0xFFEF4444);
  static const Color categoryOther = Color(0xFF6B7280);

  // Card Shadow
  static final BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.06),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );

  // Centralized Card Getters
  static Color cardBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);

  static Color cardBorderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

  // Text
  static Color get textPrimary => isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A2E);
  static Color get textSecondary => isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
  static Color get textTertiary => isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF);
  static Color get textHint => isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF);

  // Border
  static Color get borderLight => _roleColors.outline;
  static Color get borderDark => _roleColors.outline;
  static Color get surfaceDark => _roleColors.surface;
  static Color get surfaceLight => _roleColors.surface;
  static Color get surface2Dark => _roleColors.primaryContainer;

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
