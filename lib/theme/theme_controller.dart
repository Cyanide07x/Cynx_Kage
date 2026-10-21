
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'apptheme.dart';

class ThemeController extends ChangeNotifier {
  CynxThemeMode _selectedTheme = CynxThemeMode.forest;

  CynxThemeMode get selectedTheme => _selectedTheme;

  ThemeData get themeData => _selectedTheme == CynxThemeMode.forest
      ? AppTheme.forest
      : AppTheme.cynx;

  Future<void> setTheme(CynxThemeMode theme) async {
    if (_selectedTheme == theme) return;

    _selectedTheme = theme;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme', theme.name);
  }

  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('selected_theme');

    _selectedTheme = savedTheme == 'cynx'
        ? CynxThemeMode.cynx
        : CynxThemeMode.forest;

    notifyListeners();
  }
}

final ThemeController themeController = ThemeController();