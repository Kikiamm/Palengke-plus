import 'package:flutter/material.dart';
import 'app_settings.dart';

const navy = Color(0xFF1A2E20);
const navyDark = Color(0xFF13271B);
const canvas = Color(0xFFF4F8F2);
const canvasDark = Color(0xFF101612);
const cardDark = Color(0xFF19231B);
const green = Color(0xFF2F7A4E);
const greenBright = Color(0xFF4EAE72);
const red = Color(0xFFD15142);
const accent = Color(0xFFE9A53A);
const line = Color(0xFFDDEADF);
const lineDark = Color(0xFF28382C);

// Adaptive color helpers that react to the active ThemeMode
Color get adaptiveNavy => AppSettings.instance.isDarkMode ? Colors.white : navy;
Color get adaptiveSubtext => AppSettings.instance.isDarkMode ? const Color(0xFFA2B6A6) : Colors.blueGrey;
Color get adaptiveCardBg => AppSettings.instance.isDarkMode ? cardDark : Colors.white;
Color get adaptiveLine => AppSettings.instance.isDarkMode ? lineDark : line;
Color get adaptiveChipBg => AppSettings.instance.isDarkMode ? const Color(0xFF222F25) : const Color(0xFFE8F1E7);
