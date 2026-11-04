import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- BRUTALISM 2.0 PALETTE ---
  static const Color bg = Color(0xFFF5F2EA); // Off-white / brutal canvas
  static const Color black = Color(0xFF111111); // Stark Black
  static const Color yellow = Color(0xFFEFFF00); // Electric Yellow
  static const Color blue = Color(0xFF2448FF); // Cobalt Blue
  static const Color red = Color(0xFFFF3B30); // Signal Red
  static const Color surface = Color(0xFFFFFFFF); // White Surface
  static const Color green = Color(0xFF00D664); // Electric Mint / Success
  static const Color purple = Color(0xFF9D00FF); // Acid Purple / Highlight
  static const Color orange = Color(0xFFFF6B00); // Vivid Safety Orange
  static const Color grayBorder = Color(0xFF111111); // Heavy black borders
  static const Color mutedGray = Color(0xFFE2DDD1); // Subtle divider gray

  // Backwards compatibility mappings for existing screens
  static const Color primaryColor = black;
  static const Color secondaryColor = blue;
  static const Color accentColor = yellow;
  static const Color errorColor = red;
  static const Color successColor = green;
  static const Color backgroundColor = bg;
  static const Color cardColor = surface;
  static const Color textPrimary = black;
  static const Color textSecondary = Color(0xFF4A4A4A);

  // --- BRUTALIST SHADOWS & BORDERS ---
  static const double borderWidth = 2.5;
  static const double borderRadius = 2.0;
  static const double radiusSm = 2.0;
  static const double radiusMd = 4.0;
  static const double radiusLg = 6.0;

  static const BorderSide brutalBorderSide = BorderSide(
    color: black,
    width: borderWidth,
  );

  static const BoxShadow brutalShadow = BoxShadow(
    color: black,
    offset: Offset(3.5, 3.5),
    blurRadius: 0,
    spreadRadius: 0,
  );

  static const BoxShadow brutalShadowSm = BoxShadow(
    color: black,
    offset: Offset(2, 2),
    blurRadius: 0,
    spreadRadius: 0,
  );

  static const BoxShadow brutalShadowLg = BoxShadow(
    color: black,
    offset: Offset(5, 5),
    blurRadius: 0,
    spreadRadius: 0,
  );

  static BoxDecoration brutalBox({
    Color bgColor = surface,
    Color borderColor = black,
    Color shadowColor = black,
    double radius = borderRadius,
    double width = borderWidth,
    Offset offset = const Offset(3.5, 3.5),
  }) {
    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: width),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          offset: offset,
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ],
    );
  }

  // --- TYPOGRAPHY STYLES ---
  static TextStyle headingLarge({Color color = black, double fontSize = 28}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      color: color,
      letterSpacing: -0.8,
      height: 1.1,
    );
  }

  static TextStyle headingMedium({Color color = black, double fontSize = 20}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: -0.4,
    );
  }

  static TextStyle headingSmall({Color color = black, double fontSize = 16}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: -0.2,
    );
  }

  static TextStyle mono({
    Color color = black,
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return GoogleFonts.ibmPlexMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: -0.2,
    );
  }

  static TextStyle label({
    Color color = black,
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.w800,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: 1.0,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: black,
        onPrimary: surface,
        secondary: blue,
        onSecondary: surface,
        tertiary: yellow,
        onTertiary: black,
        error: red,
        onError: surface,
        surface: surface,
        onSurface: black,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme().copyWith(
        bodyMedium: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodySmall: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: bg,
        foregroundColor: black,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: black,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: black, size: 22),
        shape: const Border(
          bottom: BorderSide(color: black, width: borderWidth),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: const BorderSide(color: black, width: borderWidth),
        ),
        color: surface,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: black,
          foregroundColor: yellow,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: const BorderSide(color: black, width: borderWidth),
          ),
          textStyle: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: surface,
          foregroundColor: black,
          elevation: 0,
          side: const BorderSide(color: black, width: borderWidth),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.ibmPlexMono(
          color: const Color(0xFF888888),
          fontSize: 13,
        ),
        labelStyle: GoogleFonts.spaceGrotesk(
          color: black,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: black, width: borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: black, width: borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: black, width: 3.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: red, width: borderWidth),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: black,
        thickness: borderWidth,
        space: 24,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: black,
        unselectedItemColor: Color(0xFF777777),
        elevation: 0,
      ),
    );
  }
}
