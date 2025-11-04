import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppyDex Admin Theme Configuration
/// Based on the official design system specification

class AppTheme {
  // Core Colors from Specification
  static const Color primaryDeepBlue = Color(0xFF1E3A8A);
  static const Color secondarySkyBlue = Color(0xFF38BDF8);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color backgroundNeutralGray = Color(0xFFF9FAFB);
  static const Color textDarkSlate = Color(0xFF111827);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFDC2626);
  static const Color successGreen = Color(0xFF22C55E);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color borderGray = Color(0xFFD1D5DB);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: primaryDeepBlue,
      onPrimary: surface,
      secondary: secondarySkyBlue,
      onSecondary: surface,
      tertiary: accentEmerald,
      onTertiary: surface,
      error: dangerRed,
      onError: surface,
      surface: surface,
      onSurface: textDarkSlate,
      surfaceContainerHighest: surfaceVariant,
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
      scaffoldBackgroundColor: backgroundNeutralGray,
      textTheme: textTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: surface,
        foregroundColor: textDarkSlate,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          color: textDarkSlate,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: defaultRadius),
        margin: const EdgeInsets.all(0),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        // Error style - make it more visible
        errorStyle: const TextStyle(
          color: dangerRed,
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
          borderSide: const BorderSide(color: primaryDeepBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: dangerRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: dangerRed, width: 2),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDeepBlue,
          foregroundColor: surface,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: defaultRadius),
          elevation: 0,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDeepBlue,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          side: const BorderSide(color: primaryDeepBlue),
          shape: RoundedRectangleBorder(borderRadius: defaultRadius),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDeepBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: defaultRadius),
        backgroundColor: textDarkSlate,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: surface),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
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
        backgroundColor: surface,
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
      primaryIconTheme: const IconThemeData(color: primaryDeepBlue, size: 24),

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
}
