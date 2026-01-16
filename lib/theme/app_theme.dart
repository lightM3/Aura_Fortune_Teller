import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color deepPurple300 = Color(0xFF9575CD);
  static const Color deepPurple400 = Color(0xFF7E57C2);
  static const Color deepPurple600 = Color(0xFF5E35B1);
  static const Color deepPurple800 = Color(0xFF4527A0);
  static const Color gold400 = Color(0xFFFFD54F);

  // Gradients
  static const LinearGradient mysticGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
  );

  // Theme data
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: deepPurple400,
      secondary: gold400,
      surface: Color(0xFF1A1A2E),
      background: Color(0xFF0F3460),
    ),
    scaffoldBackgroundColor: const Color(0xFF0F3460),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: deepPurple400,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
      bodySmall: TextStyle(color: Colors.white60, fontSize: 12),
    ),
  );

  // Responsive utilities
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200 && desktop != null) {
      return desktop;
    } else if (width >= 800 && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  static int getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 6;
    if (width >= 800) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  static double getCardAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 0.7;
    if (width >= 800) return 0.65;
    return 0.6;
  }
}
