import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // Spacing Constants
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusXXLarge = 24.0;
  static const double radiusCircle = 100.0;

  // Button Heights
  static const double buttonHeightSmall = 44.0;
  static const double buttonHeightMedium = 52.0;
  static const double buttonHeightLarge = 56.0;

  // Input Field Heights
  static const double inputHeightSmall = 44.0;
  static const double inputHeightMedium = 52.0;
  static const double inputHeightLarge = 60.0;

  // Card Dimensions
  static const double cardElevation = 0.0;
  static const double cardPadding = 16.0;

  // Icon Sizes
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Border Width
  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 1.5;
  static const double borderWidthThick = 2.0;

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryBlue,
    scaffoldBackgroundColor: AppColors.lightBackground,
    fontFamily: GoogleFonts.inter().fontFamily,

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryBlue,
      secondary: AppColors.primaryPurple,
      surface: AppColors.lightSurface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.lightTextPrimary,
      onError: Colors.white,
    ),

    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: const IconThemeData(
        color: AppColors.lightTextPrimary,
        size: iconSizeMedium,
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
      ),
    ),

    // Text Theme
    textTheme: TextTheme(
      // Display - Large Headers
      displayLarge: GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: AppColors.lightTextPrimary,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.lightTextPrimary,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
        height: 1.3,
      ),

      // Headline - Section Headers
      headlineLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
        height: 1.4,
      ),

      // Title - Card Titles
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
        height: 1.4,
      ),

      // Body - Regular Text
      bodyLarge: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextSecondary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextSecondary,
        height: 1.5,
      ),

      // Label - Buttons & Small Text
      labelLarge: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
        height: 1.2,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextSecondary,
        height: 1.2,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextTertiary,
        height: 1.2,
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, buttonHeightLarge),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        minimumSize: const Size(double.infinity, buttonHeightLarge),
        side: const BorderSide(
          color: AppColors.lightBorder,
          width: borderWidthThin,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightInputBackground,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.lightBorder,
          width: borderWidthThin,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.lightBorder,
          width: borderWidthThin,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.primaryBlue,
          width: borderWidthMedium,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: borderWidthThin,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: borderWidthMedium,
        ),
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.lightTextSecondary,
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextTertiary,
      ),
      errorStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.error,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.lightCardBackground,
      elevation: cardElevation,
      shadowColor: AppColors.lightShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      margin: const EdgeInsets.all(0),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.lightDivider,
      thickness: borderWidthThin,
      space: spacing24,
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryBlue;
        }
        return Colors.transparent;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
      ),
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryBlue,
      linearTrackColor: AppColors.lightBorder,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryBlue,
    scaffoldBackgroundColor: AppColors.darkBackground,
    fontFamily: GoogleFonts.inter().fontFamily,

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryBlue,
      secondary: AppColors.primaryPurple,
      surface: AppColors.darkSurface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.darkTextPrimary,
      onError: Colors.white,
    ),

    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: const IconThemeData(
        color: AppColors.darkTextPrimary,
        size: iconSizeMedium,
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: AppColors.darkTextPrimary,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.darkTextPrimary,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
        height: 1.3,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
        height: 1.4,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextSecondary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextSecondary,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
        height: 1.2,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextSecondary,
        height: 1.2,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextTertiary,
        height: 1.2,
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, buttonHeightLarge),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        minimumSize: const Size(double.infinity, buttonHeightLarge),
        side: const BorderSide(
          color: AppColors.darkBorder,
          width: borderWidthThin,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkInputBackground,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.darkBorder,
          width: borderWidthThin,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.darkBorder,
          width: borderWidthThin,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.primaryBlue,
          width: borderWidthMedium,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: borderWidthThin,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: borderWidthMedium,
        ),
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextSecondary,
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextTertiary,
      ),
      errorStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.error,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.darkCardBackground,
      elevation: cardElevation,
      shadowColor: AppColors.darkShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      margin: const EdgeInsets.all(0),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: borderWidthThin,
      space: spacing24,
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryBlue;
        }
        return Colors.transparent;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
      ),
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryBlue,
      linearTrackColor: AppColors.darkBorder,
    ),
  );
}
