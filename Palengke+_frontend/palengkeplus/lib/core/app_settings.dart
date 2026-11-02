import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static final AppSettings instance = AppSettings._();
  AppSettings._();

  ThemeMode themeMode = ThemeMode.light;
  double fontSizeFactor = 1.0;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    fontSizeFactor = prefs.getDouble('fontSizeFactor') ?? 1.0;
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    notifyListeners();
  }

  Future<void> setFontSizeFactor(double factor) async {
    fontSizeFactor = factor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSizeFactor', factor);
    notifyListeners();
  }
}
