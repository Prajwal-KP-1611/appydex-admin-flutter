import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppyDex Admin Theme Configuration
/// Based on the official design system specification

/// Design tokens for the AppyDex Admin theme (Material 3)
class AppColors {
  // Core palette
  static const primary = Color(0xFF0B5FFF); // #0B5FFF
  static const primaryVariant = Color(0xFF0838B1); // #0838B1
  static const accent = Color(0xFF00C48C); // #00C48C
  static const danger = Color(0xFFE53935); // #E53935

  static const surfaceLight = Color(0xFFFFFFFF); // #FFFFFF
  static const surfaceDark = Color(0xFF0F1720); // #0F1720
  static const textMuted = Color(0xFF6B7280); // #6B7280

  // States
  static const primaryHover = Color(0xFF0A52E0); // #0A52E0
  static const primarySoft = Color(0xFFE8F0FF); // #E8F0FF
  static const accentHover = Color(0xFF00A97A); // #00A97A
  static const accentSoft = Color(0xFFE6FFF7); // #E6FFF7
  static const dangerHover = Color(0xFFC62828); // #C62828
  static const dangerSoft = Color(0xFFFDECEC); // #FDECEC
}

/// Backwards-compatible facade used across the app. Maps to AppColors.
class AppTheme {
  // Maintain existing color names used in the codebase
  static const Color primaryDeepBlue = AppColors.primary;
  static const Color accentEmerald = AppColors.accent;
  static const Color textDarkSlate = Color(0xFF111827);
  static const Color dangerRed = AppColors.danger;
  static const Color surface = AppColors.surfaceLight;
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color borderGray = Color(0xFFD1D5DB);
  static const Color primaryHovered = AppColors.primaryHover;
  static const Color primarySoftBg = AppColors.primarySoft;
  // Restored legacy tokens for compatibility
  static const Color secondarySkyBlue = Color(0xFF38BDF8);
  static const Color backgroundNeutralGray = Color(0xFFF9FAFB);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color successGreen = Color(0xFF22C55E);

  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primaryVariant,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.accentSoft,
      onSecondaryContainer: AppColors.accentHover,
      tertiary: AppColors.primaryVariant,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.primarySoft,
      onTertiaryContainer: AppColors.primaryVariant,
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: AppColors.dangerSoft,
      onErrorContainer: AppColors.dangerHover,
      surface: AppColors.surfaceLight,
      onSurface: Color(0xFF0F1720),
      surfaceTint: AppColors.primary,
      shadow: Colors.black54,
      outline: Color(0xFFD1D5DB),
      outlineVariant: Color(0xFFE5E7EB),
      scrim: Colors.black54,
      inverseSurface: Color(0xFF1F2937),
      onInverseSurface: Colors.white,
      inversePrimary: AppColors.primaryVariant,
    );

    final textTheme = GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        headlineLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          textBaseline: TextBaseline.alphabetic,
        ),
        headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    ).apply(bodyColor: textDarkSlate, displayColor: textDarkSlate);

    final defaultRadius = BorderRadius.circular(12);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.primarySoft,
      textTheme: textTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: textDarkSlate,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          color: textDarkSlate,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: defaultRadius),
        margin: const EdgeInsets.all(0),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        // Error style - make it more visible
        errorStyle: const TextStyle(
          color: AppColors.danger,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        errorMaxLines: 3,
        border: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: defaultRadius),
          elevation: 0,
          overlayColor: AppColors.primaryHover.withOpacity(0.08),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: defaultRadius),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: defaultRadius),
        backgroundColor: textDarkSlate,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.surfaceLight,
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: textTheme.headlineMedium,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.surfaceLight,
        elevation: 2,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: borderGray,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: textDarkSlate,
        size: 24,
        opacity: 0.87,
      ),

      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(color: AppColors.primary, size: 24),

      // Icon Button Theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textDarkSlate.withOpacity(0.7),
          hoverColor: textDarkSlate.withOpacity(0.08),
          highlightColor: textDarkSlate.withOpacity(0.12),
          iconSize: 24,
        ),
      ),
    );
  }

  /// Dark theme using the same tokens
  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryVariant,
      onPrimaryContainer: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.black,
      secondaryContainer: AppColors.accentHover,
      onSecondaryContainer: Colors.white,
      tertiary: AppColors.primaryVariant,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFF1F2A44),
      onTertiaryContainer: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: AppColors.dangerHover,
      onErrorContainer: Colors.white,
      surface: AppColors.surfaceDark,
      onSurface: Colors.white,
      surfaceTint: AppColors.primary,
      shadow: Colors.black,
      outline: Color(0xFF2D3748),
      outlineVariant: Color(0xFF334155),
      scrim: Colors.black54,
      inverseSurface: AppColors.surfaceLight,
      onInverseSurface: Color(0xFF0F1720),
      inversePrimary: AppColors.primary,
    );

    final textTheme = GoogleFonts.interTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    ).apply(bodyColor: Colors.white, displayColor: Colors.white);

    final defaultRadius = BorderRadius.circular(12);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surfaceDark,
      textTheme: textTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.headlineMedium?.copyWith(color: Colors.white),
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF111827),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: defaultRadius),
        margin: const EdgeInsets.all(0),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111827),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        prefixIconColor: Colors.white.withOpacity(0.8),
        suffixIconColor: Colors.white.withOpacity(0.8),
        errorStyle: const TextStyle(
          color: AppColors.danger,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        errorMaxLines: 3,
        border: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: defaultRadius),
          elevation: 0,
          overlayColor: AppColors.primaryHover.withOpacity(0.12),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: defaultRadius),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: defaultRadius),
        backgroundColor: const Color(0xFF111827),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: textTheme.headlineMedium,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E293B),
        labelStyle: textTheme.labelMedium?.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF111827),
        elevation: 2,
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFF364152),
        thickness: 1,
        space: 1,
      ),

      iconTheme: const IconThemeData(color: Colors.white, size: 24),
      primaryIconTheme: const IconThemeData(color: AppColors.primary, size: 24),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: Colors.white.withOpacity(0.9),
          hoverColor: Colors.white.withOpacity(0.08),
          highlightColor: Colors.white.withOpacity(0.12),
          iconSize: 24,
        ),
      ),
    );
  }
}
