import 'package:flutter/material.dart';
import 'screens/shell.dart';
import 'services/api_service.dart';

export 'core/theme.dart';
export 'core/utils.dart';
export 'screens/shell.dart';
export 'screens/palengke_splash.dart';
export 'screens/home_tab.dart';
export 'screens/analytics_tab.dart';
export 'screens/markets_tab.dart';
export 'screens/budget_tab.dart';
export 'screens/profile_tab.dart';
export 'screens/forecast_screen.dart';
export 'screens/vendor/vendor_dashboard.dart';
export 'services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.initialize();
  runApp(const PalengkePlusApp());
}
