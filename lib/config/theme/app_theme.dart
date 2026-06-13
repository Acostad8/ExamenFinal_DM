import 'package:flutter/material.dart';

// Colores disponibles para el tema primario de la app
final List<Color> colorsTheme = [Colors.green, Colors.blue];

// Clase que genera el ThemeData según el color e modo seleccionados
class AppTheme {
  final int selectColor; // Índice del color en colorsTheme
  AppTheme({required this.selectColor});

  // Construye el tema de Material 3
  // bandera: 1 = modo oscuro, 0 = modo claro
  ThemeData themeData(int bandera) {
    return ThemeData(
      useMaterial3: true,
      // Genera toda la paleta de colores a partir del color semilla
      colorSchemeSeed: colorsTheme[selectColor],
      brightness: bandera == 1 ? Brightness.dark : Brightness.light,
      appBarTheme: AppBarTheme(
        backgroundColor: colorsTheme[selectColor],
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
