import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zero/core/const_page.dart';

class ThemeController extends GetxController {
  final RxBool isDarkMode = true.obs;

  ThemeMode get theme => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  static const Color gold = Color(0xFFFFD700);

  final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: gold,
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.black87),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade200,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: gold, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      errorStyle: GoogleFonts.poppins(
        color: Colors.red,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: Colors.black,
      displayColor: Colors.black,
    ),
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      secondary: Colors.black,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
    ),
  );

  final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFF121212),
    primaryColor: Colors.black,
    cardColor: const Color(0xFF1C1C1E),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF121212),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white70),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.grey[600],
      foregroundColor: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorConst.secondaryButton,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white70),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1C1C1E),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      hintStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: gold),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      errorStyle: GoogleFonts.poppins(
        color: Colors.red,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    textButtonTheme:
        TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: gold)),
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Colors.black,
      secondary: Colors.black,
      surface: Color(0xFF1C1C1E),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
  );

  Color get primaryColor => Colors.black;
  Color get backgroundColor => const Color(0xFF121212);
  Color get surfaceColor => const Color(0xFF1C1C1E);
  Color get textColor => Colors.white;
}
