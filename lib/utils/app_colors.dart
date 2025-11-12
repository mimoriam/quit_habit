import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF4B7BFF);
  static const Color lightPrimaryDark = Color(0xFF3D5CFF);
  static const Color lightSecondary = Color(0xFF8B5CF6);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightInputBackground = Color(0xFFF9FAFB);
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color lightSuccess = Color(0xFF10B981);
  static const Color lightError = Color(0xFFEF4444);
  static const proColor = Color(0xFFFF6900);
  static const Color lightWarning = Color(0xFFF59E0B);

  // --- NEW COLORS FROM DESIGN ---
  static const Color lightBlueBackground = Color(0xFFF0F6FF); // For streak card
  static const Color lightRed = Color(0xFFFF6B6B); // For Breathing card
  static const Color lightBlueDistraction = Color(
    0xFFEFF6FF,
  ); // For Exercise card
  static const Color lightGreenBackground = Color(
    0xFFF0FDF4,
  ); // For Meditate card

  static const Color badgeGreen = Color(0xFFE0FBEF); // For 0% badge bg
  static const Color badgeBlue = Color(0xFFE5F0FF); // For 1 badge bg
  static const Color badgeOrange = Color(0xFFFFF7E6); // For 0 badge bg

  static const Color lightOrangeBackground = Color(
    0xFFFFFBEB,
  ); // For Premium card
  // --- END OF NEW COLORS ---

  // Gradient Colors
  static const Color gradientStart = Color(0xFFF5F3FF);
  static const Color gradientMiddle = Color(0xFFEFF6FF);
  static const Color gradientEnd = Color(0xFFEFF6FF);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0F1419);
  static const Color darkSurface = Color(0xFF1A1F28);
  static const Color darkSurfaceElevated = Color(0xFF252A35);
  static const Color darkPrimary = Color(0xFF5B8BFF);
  static const Color darkPrimaryDark = Color(0xFF4B7BFF);
  static const Color darkSecondary = Color(0xFF9B6CF6);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B8C4);
  static const Color darkTextTertiary = Color(0xFF6B7280);
  static const Color darkBorder = Color(0xFF2D3340);
  static const Color darkInputBackground = Color(0xFF1F242E);
  static const Color darkDivider = Color(0xFF2D3340);
  static const Color darkSuccess = Color(0xFF10B981);
  static const Color darkError = Color(0xFFEF4444);
  static const Color darkWarning = Color(0xFFF59E0B);

  // Common Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Shadow Colors
  static const Color lightShadow = Color.fromRGBO(0, 0, 0, 0.04);
  static const Color mediumShadow = Color.fromRGBO(0, 0, 0, 0.08);
  static const Color darkShadow = Color.fromRGBO(0, 0, 0, 0.12);

  // Overlay Colors
  static const Color lightOverlay = Color.fromRGBO(0, 0, 0, 0.5);
  static const Color darkOverlay = Color.fromRGBO(0, 0, 0, 0.7);

  // Linear Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [gradientStart, gradientMiddle, gradientEnd],
  );

  static const LinearGradient progressGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [gradientStart, gradientEnd],
  );

  // Icon Background Glow
  static const BoxShadow iconGlowLight = BoxShadow(
    color: Color.fromRGBO(75, 123, 255, 0.15),
    blurRadius: 24,
    spreadRadius: 0,
  );

  static const BoxShadow iconGlowDark = BoxShadow(
    color: Color.fromRGBO(91, 139, 255, 0.25),
    blurRadius: 24,
    spreadRadius: 0,
  );
}
