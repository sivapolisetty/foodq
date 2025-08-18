import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors - Yindii-inspired green theme
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF81C784);
  
  // Accent Colors
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentBlue = Color(0xFF2196F3);
  
  // Neutral Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color surfaceColor = Color(0xFFFAFAFA);
  static const Color backgroundColor = Colors.white;
  
  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Shadows
  static const BoxShadow subtleShadow = BoxShadow(
    color: Color(0x10000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );
  
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x15000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );
  
  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  
  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeading = 28.0;
  
  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: fontSizeXXLarge,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMedium,
            vertical: spacingSmall,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[100],
        selectedColor: primaryGreen.withOpacity(0.2),
        labelStyle: const TextStyle(
          fontSize: fontSizeSmall,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingSmall,
          vertical: spacingXSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primaryGreen,
        unselectedItemColor: textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: fontSizeHeading,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: fontSizeTitle,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: fontSizeXXLarge,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: fontSizeXLarge,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSizeLarge,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSizeMedium,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: fontSizeSmall,
          color: textSecondary,
        ),
      ),
    );
  }
  
  // Helper methods for common UI patterns
  static BoxDecoration cardDecoration({
    Color? color,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: color ?? backgroundColor,
      borderRadius: borderRadius ?? BorderRadius.circular(borderRadiusMedium),
      boxShadow: boxShadow ?? [cardShadow],
    );
  }
  
  static InputDecoration searchInputDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingMedium,
        vertical: spacingSmall,
      ),
      filled: true,
      fillColor: backgroundColor,
    );
  }
  
  static ButtonStyle primaryButtonStyle({
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 2,
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: spacingMedium,
        vertical: spacingSmall,
      ),
      minimumSize: minimumSize,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      textStyle: const TextStyle(
        fontSize: fontSizeMedium,
        fontWeight: FontWeight.w600,
      ),
    );
  }
  
  static ButtonStyle secondaryButtonStyle({
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: primaryGreen,
      elevation: 1,
      side: const BorderSide(color: primaryGreen),
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: spacingMedium,
        vertical: spacingSmall,
      ),
      minimumSize: minimumSize,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      textStyle: const TextStyle(
        fontSize: fontSizeMedium,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}