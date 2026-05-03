import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Provider para gestionar el modo del tema (Light, Dark, System)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class JadeColors {
  static const Color primary = Color(0xFF0A6B51);
  static const Color primaryContainer = Color(0xFFA0F3D1);

  // Colores Modo Claro
  static const Color surface = Color(0xFFF8FAF9);
  static const Color surfaceContainerLow = Color(0xFFF0F4F3);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF2A3434);

  // Colores Modo Oscuro (Evitando negro puro #000000 según DESIGN.md)
  static const Color darkSurface = Color(
    0xFF0B0F0F,
  ); // inverse_surface de Stitch
  static const Color darkSurfaceContainer = Color(0xFF1A1C1C);
  static const Color darkOnSurface = Color(0xFFE1EAE9);

  static const Color error = Color(0xFF9F403D);
  static const Color outlineVariant = Color(0xFFA9B4B3);
}

class JadeTheme {
  static ThemeData get lightTheme {
    return _buildTheme(
      Brightness.light,
      JadeColors.surface,
      JadeColors.onSurface,
      JadeColors.surfaceContainerLowest,
    );
  }

  static ThemeData get darkTheme {
    return _buildTheme(
      Brightness.dark,
      JadeColors.darkSurface,
      JadeColors.darkOnSurface,
      JadeColors.darkSurfaceContainer,
    );
  }

  static ThemeData _buildTheme(
    Brightness brightness,
    Color background,
    Color onBackground,
    Color cardColor,
  ) {
    final baseTextTheme = brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        brightness: brightness,
        seedColor: JadeColors.primary,
        primary: JadeColors.primary,
        onPrimary: Colors.white,
        primaryContainer: JadeColors.primaryContainer,
        surface: background,
        onSurface: onBackground,
        error: JadeColors.error,
      ),
      scaffoldBackgroundColor: background,
      // Configuramos GoogleFonts para que use la base correcta (blanca o negra)
      textTheme: GoogleFonts.interTextTheme(baseTextTheme).copyWith(
        displayLarge: GoogleFonts.manrope(
          textStyle: baseTextTheme.displayLarge,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.02,
          color: onBackground,
        ),
        headlineMedium: GoogleFonts.manrope(
          textStyle: baseTextTheme.headlineMedium,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.02,
          color: onBackground,
        ),
        headlineSmall: GoogleFonts.manrope(
          textStyle: baseTextTheme.headlineSmall,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onBackground,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: onBackground),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: onBackground),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: onBackground),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: onBackground),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: onBackground),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JadeColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: onBackground),
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onBackground,
        ),
      ),
    );
  }
}
