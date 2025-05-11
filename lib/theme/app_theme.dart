import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Shared colors
  static const Color primaryColor = Color(0xFF6369D9); // Blue-purple

  // Dark theme colors
  static const Color darkBackgroundColor = Color(0xFF121212); // Dark background
  static const Color darkSurfaceColor = Color(0xFF1D1D1D); // Dark surface
  static const Color darkCardColor = Color(0xFF252525); // Dark card
  static const Color darkPrimaryTextColor = Color(0xFFFFFFFF); // White
  static const Color darkSecondaryTextColor = Color(0xFFAFAFAF); // Light gray
  static const Color darkDisabledTextColor = Color(0xFF6E6E6E); // Disabled gray

  // Light theme colors
  static const Color lightBackgroundColor = Color(
    0xFFF9F9F9,
  ); // Light background
  static const Color lightSurfaceColor = Color(0xFFFFFFFF); // Light surface
  static const Color lightCardColor = Color(0xFFFFFFFF); // Light card
  static const Color lightPrimaryTextColor = Color(0xFF121212); // Dark text
  static const Color lightSecondaryTextColor = Color(0xFF757575); // Gray text
  static const Color lightDisabledTextColor = Color(
    0xFFBDBDBD,
  ); // Light gray text

  // Colors used in both themes
  static const Color accentRed = Color(0xFFFF4666); // Red for high priority
  static const Color accentYellow = Color(
    0xFFFFBD3E,
  ); // Yellow for medium priority
  static const Color accentGreen = Color(0xFF66CC41); // Green for low priority
  static const Color accentBlue = Color(0xFF5EB0EF); // Blue accent

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6369D9), Color(0xFF8A8EF0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Theme data
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      cardColor: darkCardColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: darkPrimaryTextColor),
        titleTextStyle: TextStyle(
          color: darkPrimaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: darkSecondaryTextColor,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            color: darkPrimaryTextColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: darkPrimaryTextColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            color: darkPrimaryTextColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            color: darkPrimaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          bodyMedium: TextStyle(
            color: darkSecondaryTextColor,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          bodySmall: TextStyle(
            color: darkSecondaryTextColor,
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: darkSurfaceColor,
        // background: darkBackgroundColor,
        error: accentRed,
        onPrimary: darkPrimaryTextColor,
        onSecondary: darkPrimaryTextColor,
        onSurface: darkPrimaryTextColor,
        // onBackground: darkPrimaryTextColor,
        onError: darkPrimaryTextColor,
        brightness: Brightness.dark,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: darkSecondaryTextColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: darkPrimaryTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: darkSurfaceColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: darkDisabledTextColor),
      ),
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBackgroundColor,
      cardColor: lightCardColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: lightPrimaryTextColor),
        titleTextStyle: TextStyle(
          color: lightPrimaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: lightSecondaryTextColor,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            color: lightPrimaryTextColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: lightPrimaryTextColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            color: lightPrimaryTextColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            color: lightPrimaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          bodyMedium: TextStyle(
            color: lightSecondaryTextColor,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          bodySmall: TextStyle(
            color: lightSecondaryTextColor,
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        surface: lightSurfaceColor,
        background: lightBackgroundColor,
        error: accentRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightPrimaryTextColor,
        onBackground: lightPrimaryTextColor,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: lightSecondaryTextColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: lightBackgroundColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: lightSecondaryTextColor.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: lightDisabledTextColor),
      ),
    );
  }
}
