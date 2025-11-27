import 'package:flutter/material.dart';

/// Paleta principal do Estud.ai inspirada no guia visual disponível em `paleta.html`.
class AppColors {
  AppColors._();

  // Base
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundSoft = Color(0xFFF5F7FA); // Softer, slightly cool grey
  static const Color borderSoft = Color(0xFFE1E4E8);

  // Texto
  static const Color textMain = Color(0xFF2D3436); // Softer black
  static const Color textSecondary = Color(0xFF636E72);

  // Ações
  static const Color primary = Color(0xFF00B894); // Minty Green (Modern & Friendly)
  static const Color primaryDark = Color(0xFF00A884);
  static const Color secondary = Color(0xFF55EFC4); // Lighter Green

  // Feedback
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFFCC00);
  static const Color error = Color(0xFFFF7675); // Softer Red

  // Utilidades
  static const Color overlay = Color(0x14000000);
}
