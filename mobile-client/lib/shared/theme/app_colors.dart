import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Vibrant Green Theme for KraveKart)
  static const Color primary = Color(0xFF2E7D32); // Deep green
  static const Color primaryLight = Color(0xFF4CAF50); // Lighter green
  static const Color primaryDark = Color(0xFF1B5E20); // Darker green
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFE8F5E8);
  static const Color onPrimaryContainer = Color(0xFF1B5E20);

  // Secondary Colors (Complementary orange/amber)
  static const Color secondary = Color(0xFFFF8F00); // Vibrant orange
  static const Color secondaryLight = Color(0xFFFFC107); // Amber
  static const Color secondaryDark = Color(0xFFE65100); // Dark orange
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFFF3E0);
  static const Color onSecondaryContainer = Color(0xFFE65100);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA); // Very light gray
  static const Color onBackground = Color(0xFF1C1B1F);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1C1B1F);

  // Surface Variants
  static const Color surfaceVariant = Color(0xFFF3F3F3);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  static const Color surfaceContainer = Color(0xFFF7F2FA);
  static const Color surfaceContainerHighest = Color(0xFFE6E0E9);

  // Outline Colors
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);

  // State Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color onErrorContainer = Color(0xFF8B0000);

  static const Color warning = Color(0xFFF57C00);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color onWarningContainer = Color(0xFFE65100);

  static const Color success = Color(0xFF388E3C);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFE8F5E8);
  static const Color onSuccessContainer = Color(0xFF1B5E20);

  static const Color info = Color(0xFF1976D2);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFE3F2FD);
  static const Color onInfoContainer = Color(0xFF0D47A1);

  // Inverse Colors
  static const Color inverseSurface = Color(0xFF313033);
  static const Color inverseOnSurface = Color(0xFFF4EFF4);
  static const Color inversePrimary = Color(0xFF81C784);

  // Shadow and Elevation
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkOnBackground = Color(0xFFE6E1E5);
  static const Color darkSurface = Color(0xFF1F1F1F);
  static const Color darkOnSurface = Color(0xFFE6E1E5);
  static const Color darkSurfaceVariant = Color(0xFF2D2D2D);
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);

  // KraveKart Specific Colors
  static const Color discountRed = Color(0xFFE53935);
  static const Color discountGreen = Color(0xFF43A047);
  static const Color savingsGold = Color(0xFFFFC107);
  static const Color foodOrange = Color(0xFFFF7043);
  static const Color freshGreen = Color(0xFF66BB6A);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondary, secondaryDark],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF81C784), success, Color(0xFF2E7D32)],
  );

  // Polka Dot Pattern Colors
  static const Color polkaDotPrimary = Color(0x1A2E7D32);
  static const Color polkaDotSecondary = Color(0x1AFF8F00);
  static const Color polkaDotSurface = Color(0x0A000000);

  // Color Schemes
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    secondary: secondary,
    onSecondary: onSecondary,
    tertiary: freshGreen,
    onTertiary: Colors.white,
    error: error,
    onError: onError,
    background: background,
    onBackground: onBackground,
    surface: surface,
    onSurface: onSurface,
    surfaceVariant: surfaceVariant,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    shadow: shadow,
    scrim: scrim,
    inverseSurface: inverseSurface,
    // inverseOnSurface: inverseOnSurface, // Deprecated in newer Flutter versions
    inversePrimary: inversePrimary,
    surfaceTint: primary,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryLight,
    onPrimary: Colors.black,
    secondary: secondaryLight,
    onSecondary: Colors.black,
    tertiary: freshGreen,
    onTertiary: Colors.black,
    error: Color(0xFFEF5350),
    onError: Colors.black,
    background: darkBackground,
    onBackground: darkOnBackground,
    surface: darkSurface,
    onSurface: darkOnSurface,
    surfaceVariant: darkSurfaceVariant,
    onSurfaceVariant: darkOnSurfaceVariant,
    outline: Color(0xFF938F99),
    outlineVariant: Color(0xFF49454F),
    shadow: shadow,
    scrim: scrim,
    inverseSurface: Color(0xFFE6E1E5),
    // inverseOnSurface: Color(0xFF313033), // Deprecated in newer Flutter versions
    inversePrimary: primary,
    surfaceTint: primaryLight,
  );

  // Utility methods
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}