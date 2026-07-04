import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary
  static const blue        = Color(0xFF2563EB);
  static const blueDark    = Color(0xFF1D4ED8);
  static const blueLight   = Color(0xFF3B82F6);
  static const blueSubtle  = Color(0xFFEFF6FF);

  // Status
  static const statusOpen      = Color(0xFF06B6D4);  // Cyan
  static const statusOpenBg    = Color(0xFFECFEFF);
  static const statusProcess   = Color(0xFFF59E0B);  // Amber
  static const statusProcessBg = Color(0xFFFFFBEB);
  static const statusClosed    = Color(0xFF10B981);  // Green
  static const statusClosedBg  = Color(0xFFECFDF5);
  static const statusPending   = Color(0xFF8B5CF6);  // Purple
  static const statusPendingBg = Color(0xFFF5F3FF);

  // Priority
  static const priorityHigh   = Color(0xFFEF4444);
  static const priorityHighBg = Color(0xFFFEF2F2);
  static const priorityMed    = Color(0xFFF59E0B);
  static const priorityMedBg  = Color(0xFFFFFBEB);
  static const priorityLow    = Color(0xFF06B6D4);
  static const priorityLowBg  = Color(0xFFECFEFF);

  // Backgrounds
  static const bgLight     = Color(0xFFF1F5F9);
  static const bgDark      = Color(0xFF0F111A);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark  = Color(0xFF1E293B);
  static const surface2Dark = Color(0xFF0F172A);

  // Text / Borders
  static const textPrimary   = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textHint      = Color(0xFF94A3B8);
  static const borderLight   = Color(0xFFE2E8F0);
  static const borderDark    = Color(0xFF334155);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
}

class RoleThemeColors {
  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color tertiary;
  final Color primaryContainer;
  final Color scaffoldBg;
  final Color surface;
  final Color onPrimary;
  final Color onSurface;
  final Color outline;

  RoleThemeColors({
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.tertiary,
    required this.primaryContainer,
    required this.scaffoldBg,
    required this.surface,
    required this.onPrimary,
    required this.onSurface,
    required this.outline,
  });

  static RoleThemeColors getColors(String role, bool isDark) {
    switch (role.toLowerCase()) {
      case 'user':
        return RoleThemeColors(
          primary: isDark ? const Color(0xFF6192FC) : const Color(0xFF11358B), // 6192FC primary light blue in dark mode, 11358B primary dark blue in light mode
          primaryDark: const Color(0xFF11358B), 
          secondary: const Color(0xFF6192FC), 
          tertiary: const Color(0xFFC7EF66), // C7EF66 lime green accent
          primaryContainer: isDark ? const Color(0xFF11358B) : const Color(0xFFEFF0F4), // EFF0F4 container
          scaffoldBg: isDark ? const Color(0xFF0F111A) : const Color(0xFFEFF0F4), // EFF0F4 page bg
          surface: isDark ? const Color(0xFF1E293B) : Colors.white,
          onPrimary: Colors.white,
          onSurface: isDark ? Colors.white : const Color(0xFF0F172A),
          outline: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        );
      case 'helpdesk':
        return RoleThemeColors(
          primary: isDark ? const Color(0xFF0EA5E9) : const Color(0xFF0077CC),
          primaryDark: const Color(0xFF004A80),
          secondary: const Color(0xFF0EA5E9),
          tertiary: const Color(0xFF0EA5E9),
          primaryContainer: isDark ? const Color(0xFF004A80) : const Color(0xFFF8FAFC),
          scaffoldBg: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          surface: isDark ? const Color(0xFF1E293B) : Colors.white,
          onPrimary: Colors.white,
          onSurface: isDark ? Colors.white : const Color(0xFF0F172A),
          outline: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        );
      case 'admin':
        return RoleThemeColors(
          primary: isDark ? const Color(0xFF2277FF) : const Color(0xFF0056FF),
          primaryDark: const Color(0xFF002C99),
          secondary: const Color(0xFF2277FF),
          tertiary: const Color(0xFFE3E7FC),
          primaryContainer: isDark ? const Color(0xFF002C99) : const Color(0xFFE3E7FC),
          scaffoldBg: isDark ? const Color(0xFF000000) : const Color(0xFFE3E7FC),
          surface: isDark ? const Color(0xFF121212) : Colors.white,
          onPrimary: Colors.white,
          onSurface: isDark ? Colors.white : const Color(0xFF000000),
          outline: isDark ? const Color(0xFF1E293B) : const Color(0xFFCCD1F0),
        );
      default:
        return RoleThemeColors(
          primary: isDark ? const Color(0xFF6192FC) : const Color(0xFF11358B),
          primaryDark: const Color(0xFF11358B),
          secondary: const Color(0xFF6192FC),
          tertiary: const Color(0xFFC7EF66),
          primaryContainer: isDark ? const Color(0xFF11358B) : const Color(0xFFEFF0F4),
          scaffoldBg: isDark ? const Color(0xFF0F111A) : const Color(0xFFEFF0F4),
          surface: isDark ? const Color(0xFF1E293B) : Colors.white,
          onPrimary: Colors.white,
          onSurface: isDark ? Colors.white : const Color(0xFF0F172A),
          outline: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        );
    }
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => getLightThemeForRole('user');
  static ThemeData get darkTheme => getDarkThemeForRole('user');

  static ThemeData getLightThemeForRole(String role) {
    final colors = RoleThemeColors.getColors(role, false);
    final baseLight = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: colors.primary,
    );

    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: colors.primary,
      primaryContainer: colors.primaryContainer,
      secondary: colors.secondary,
      tertiary: colors.tertiary,
      surface: colors.surface,
      onPrimary: colors.onPrimary,
      onSurface: colors.onSurface,
      outline: colors.outline,
    );

    final textTheme = GoogleFonts.poppinsTextTheme(baseLight.textTheme).copyWith(
      headlineLarge: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: AppColors.textHint,
      ),
    );

    return baseLight.copyWith(
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: colors.scaffoldBg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colors.outline,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
        labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.outline,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.priorityHigh,
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
    );
  }

  static ThemeData getDarkThemeForRole(String role) {
    final colors = RoleThemeColors.getColors(role, true);
    final baseDark = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: colors.primary,
    );

    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: colors.primary,
      primaryContainer: colors.primaryContainer,
      secondary: colors.secondary,
      tertiary: colors.tertiary,
      surface: colors.surface,
      onPrimary: colors.onPrimary,
      onSurface: colors.onSurface,
      outline: colors.outline,
    );

    final textTheme = GoogleFonts.poppinsTextTheme(baseDark.textTheme).copyWith(
      headlineLarge: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF94A3B8),
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: const Color(0xFF64748B),
      ),
    );

    return baseDark.copyWith(
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: colors.scaffoldBg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colors.outline,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
        labelStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.outline,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.outline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.priorityHigh,
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: const Color(0xFF94A3B8),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
    );
  }
}
