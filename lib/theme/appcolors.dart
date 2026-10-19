// ─────────────────────────────────────────────────────────────────────────────
// theme/appcolors.dart
// Central colour palette for the Cynx Kage app.
//
// All widgets reference these constants so that a design update only requires
// changing values in this one file.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

/// Static colour constants used throughout the app.
///
/// This class is intentionally non-instantiable; access colours through the
/// static fields (e.g. `AppColors.primary`).
class AppColors {
  AppColors._(); // prevent instantiation

  /// Pure black — default page/scaffold background.
  static const appBackground = Color(0xFF000000);

  /// Dark charcoal — cards, image placeholders, and elevated surfaces.
  static const surface = Color(0xFF1F1F1F);

  /// Mid grey — chip outlines, dividers, and inactive dot indicators.
  static const border = Color(0xFF3A3A3A);

  /// Soft lime — card borders and secondary highlights.
  static const secondary = Color(0xFFB7D98A);

  /// Lime green — primary brand accent (buttons, active icons, prices).
  static const primary = Color(0xFFC5E37A);

  /// Near-white — main body and heading text.
  static const text = Color(0xFFF5F5F5);

  /// Medium grey — hints, captions, inactive icons, and secondary labels.
  static const textSecondary = Color(0xFF9A9A9A);

  /// Dark charcoal — text-field fill colour.
  static const deepForest = Color(0xFF2A2A2A);

  /// Muted salmon — error states and destructive-action labels.
  static const error = Color(0xFFFFB4A2);

  /// Near-black — bottom navigation bar background.
  static const gradient = Color(0xFF0B0B0B);
}