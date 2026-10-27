import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

class ThemeController {
  static ThemeMode _themeMode = ThemeMode.light;
  static double _fontSize = 16.0;

  static ThemeMode get themeMode => _themeMode;
  static double get fontSize => _fontSize;

  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.toString() == 'ThemeMode.${prefs.getString('themeMode') ?? 'light'}',
      orElse: () => ThemeMode.light,
    );
    _fontSize = prefs.getDouble('fontSize') ?? 16.0;
  }

  static Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeMode == ThemeMode.dark ? 'dark' : 'light');
  }

  static Future<void> setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', _fontSize);
  }
}