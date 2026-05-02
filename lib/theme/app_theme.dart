import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFFF5F1E8);
  static const bgRaised = Color(0xFFFBF8F1);
  static const bgSunken = Color(0xFFEDE7D8);
  static const border = Color(0xFFE0D8C2);
  static const divider = Color(0xFFEDE6D2);

  static const primary = Color(0xFF3B3F8F);
  static const primaryDeep = Color(0xFF2A2D6B);
  static const primarySoft = Color(0xFFE5E4F2);

  static const ink = Color(0xFF18140D);
  static const inkSoft = Color(0xFF3D3830);
  static const inkMuted = Color(0xFF5A5244);

  static const accent = Color(0xFFB8541C);
  static const accentSoft = Color(0xFFF4E4D6);

  static const success = Color(0xFF5C7A3A);
  static const successSoft = Color(0xFFE4ECCD);

  static const error = Color(0xFFB00020);
  static const errorSoft = Color(0xFFFCE8EC);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.bg,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.bg,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: AppColors.ink,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w400,
            color: AppColors.ink,
            letterSpacing: -0.8,
          ),
          headlineMedium: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w400,
            color: AppColors.ink,
            letterSpacing: -0.5,
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: AppColors.ink,
            letterSpacing: -0.3,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColors.ink,
            height: 1.55,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColors.inkSoft,
            height: 1.5,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: AppColors.inkMuted,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: AppColors.inkMuted,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: AppColors.bgRaised,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          hintStyle: TextStyle(color: AppColors.inkMuted, fontSize: 15),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.bgRaised,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            side: BorderSide(color: AppColors.border),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.bgRaised,
          selectedColor: AppColors.primary,
          labelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          shape: const StadiumBorder(),
          side: const BorderSide(color: AppColors.border),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.bgRaised,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.inkMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 0,
        ),
      );
}
