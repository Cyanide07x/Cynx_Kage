
import 'package:flutter/material.dart';

import 'appcolors.dart';

/// Available visual themes for Cynx Kage.
enum CynxThemeMode {
  forest,
  cynx,
}

/// Builds the Material theme for the selected palette.
class AppTheme {
  AppTheme._();

  // Original Forest theme.
  static final ThemeData forest = _buildTheme(
    background: AppColors.forestBackground,
    surface: AppColors.forestSurface,
    border: AppColors.forestBorder,
    primary: AppColors.forestPrimary,
    secondary: AppColors.forestSecondary,
    text: AppColors.forestText,
    secondaryText: AppColors.forestTextSecondary,
    error: AppColors.forestError,
  );

  // New black-and-hot-pink Cynx theme.
  static final ThemeData cynx = _buildTheme(
    background: AppColors.cynxBackground,
    surface: AppColors.cynxSurface,
    border: AppColors.cynxBorder,
    primary: AppColors.cynxPrimary,
    secondary: AppColors.cynxSecondary,
    text: AppColors.cynxText,
    secondaryText: AppColors.cynxTextSecondary,
    error: AppColors.cynxError,
  );

  static ThemeData _buildTheme({
    required Color background,
    required Color surface,
    required Color border,
    required Color primary,
    required Color secondary,
    required Color text,
    required Color secondaryText,
    required Color error,
  }) {
    final colorScheme = ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: text,
      error: error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      dividerColor: border,

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
      ),

      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: text,
        displayColor: text,
      ),

      iconTheme: IconThemeData(color: text),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: secondaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: border),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? primary
              : secondaryText;
        }),
      ),
    );
  }
}