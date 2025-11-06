import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primaryBlue = Color(0xFF4C7EFF);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryGradientStart = Color(0xFF4C7EFF);
  static const Color primaryGradientEnd = Color(0xFF8B5CF6);

  // Accent Colors
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color accentRed = Color(0xFFFF3B30);
  static const Color accentGreen = Color(0xFF34C759);
  static const Color accentTeal = Color(0xFF5AC8FA);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F3FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF8E8E93);
  static const Color lightTextTertiary = Color(0xFFC7C7CC);
  static const Color lightBorder = Color(0xFFE5E5EA);
  static const Color lightInputBackground = Color(0xFFF7F8FA);
  static const Color lightDivider = Color(0xFFE5E5EA);
  static const Color lightShadow = Color(0x0D000000);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkCardBackground = Color(0xFF2C2C2E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8E8E93);
  static const Color darkTextTertiary = Color(0xFF48484A);
  static const Color darkBorder = Color(0xFF38383A);
  static const Color darkInputBackground = Color(0xFF1C1C1E);
  static const Color darkDivider = Color(0xFF38383A);
  static const Color darkShadow = Color(0x1A000000);

  // Success Rate Colors (for progress indicators)
  static const Color successHigh = Color(0xFF34C759); // 85%+
  static const Color successMedium = Color(0xFFFF9500); // 78-84%
  static const Color successLow = Color(0xFFFF3B30); // Below 78%

  // Google Button
  static const Color googleButtonBorder = Color(0xFFE5E5EA);
  static const Color googleButtonBackground = Color(0xFFFFFFFF);

  // Status Colors
  static const Color error = Color(0xFFFF3B30);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF4C7EFF);

  // Overlay Colors
  static const Color overlayLight = Color(0x0D000000);
  static const Color overlayDark = Color(0x33000000);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF5F3FF), Color(0xFFEFF6FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient progressGradient = LinearGradient(
    colors: [Color(0xFFFF3B30), Color(0xFFFF9500)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Button Gradients
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF4C7EFF), Color(0xFF8B5CF6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Card Shadow
  static List<BoxShadow> cardShadow = [
    BoxShadow(color: lightShadow, blurRadius: 20, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> cardShadowDark = [
    BoxShadow(color: darkShadow, blurRadius: 20, offset: const Offset(0, 4)),
  ];

  // Elevated Card Shadow (for selected states)
  static List<BoxShadow> elevatedCardShadow = [
    BoxShadow(
      color: primaryBlue.withValues(alpha: 0.15),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
