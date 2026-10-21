
import 'package:flutter/material.dart';

/// Central color palettes for Cynx Kage.
///
/// Forest is the original theme.
/// Cynx is the new black-and-hot-pink theme.
///
/// Existing AppColors references retain the original Forest colors.
/// Use AppColors.forest or AppColors.cynx when selecting a specific palette.
class AppColors {
  AppColors._();

  // ─────────────────────────────────────────────
  // Forest Theme — Original
  // ─────────────────────────────────────────────

  static const Color forestBackground = Color(0xFF000000);
  static const Color forestSurface = Color(0xFF1F1F1F);
  static const Color forestBorder = Color(0xFF3A3A3A);
  static const Color forestSecondary = Color(0xFFB7D98A);
  static const Color forestPrimary = Color(0xFFC5E37A);
  static const Color forestText = Color(0xFFF5F5F5);
  static const Color forestTextSecondary = Color(0xFF9A9A9A);
  static const Color forestDeepForest = Color(0xFF2A2A2A);
  static const Color forestError = Color(0xFFFFB4A2);
  static const Color forestGradient = Color(0xFF0B0B0B);

  // ─────────────────────────────────────────────
  // Cynx Theme — Black & Hot Pink
  // ─────────────────────────────────────────────

  static const Color cynxBackground = Color(0xFF080608);
  static const Color cynxSurface = Color(0xFF110D10);
  static const Color cynxBorder = Color(0xFF292329);
  static const Color cynxPrimary = Color(0xFFE50046);
  static const Color cynxSecondary = Color(0xFFA80034);
  static const Color cynxText = Color(0xFFF5F2F4);
  static const Color cynxTextSecondary = Color(0xFFAAA2A8);
  static const Color cynxDeepForest = Color(0xFF1A1519);
  static const Color cynxError = Color(0xFFFF6B81);
  static const Color cynxGradient = Color(0xFF080608);

  // ─────────────────────────────────────────────
  // Original aliases — backwards compatibility
  // ─────────────────────────────────────────────

  static const Color appBackground = forestBackground;
  static const Color surface = forestSurface;
  static const Color border = forestBorder;
  static const Color secondary = forestSecondary;
  static const Color primary = forestPrimary;
  static const Color text = forestText;
  static const Color textSecondary = forestTextSecondary;
  static const Color deepForest = forestDeepForest;
  static const Color error = forestError;
  static const Color gradient = forestGradient;
}
