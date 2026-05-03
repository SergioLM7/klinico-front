import 'package:flutter/material.dart';

/// Fuente única de verdad para todos los tokens de diseño de Klinico.
///
/// Usar siempre estos valores en lugar de colores/gradientes hardcodeados
/// para garantizar consistencia visual en toda la app.
abstract final class AppTheme {
  // ── Colores base ────────────────────────────────────────────────────────────
  static const Color primaryBlue = Color.fromARGB(221, 10, 27, 150);
  static const Color accentIndigo = Color(0xFF4C56AF);

  /// Color de inicio del degradado (esquina superior-izquierda)
  static const Color gradientStart = Color.fromARGB(255, 145, 180, 198);

  /// Color de fin del degradado (esquina inferior-derecha)
  static const Color gradientEnd = Color(0xFFFFFFFF);

  // ── Degradado principal (Login y fondo de toda la app) ─────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  // ── Decoración de fondo lista para usar en BoxDecoration ──────────────────
  static const BoxDecoration backgroundDecoration = BoxDecoration(
    gradient: backgroundGradient,
  );

  // ── ThemeData global de la app ─────────────────────────────────────────────
  static ThemeData get themeData => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: accentIndigo),
    useMaterial3: true,
    // AppBar transparente por defecto para que el gradiente se vea debajo
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Colors.black87,
    ),
  );
}
