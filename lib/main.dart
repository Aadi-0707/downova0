import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await AppConfig.load();
  runApp(DownovaApp(config: config));
}

class DownovaApp extends StatelessWidget {
  final AppConfig config;

  const DownovaApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final mode = config.string('theme.default_mode');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: config.string('app.name'),
      theme: AppTheme.build(config, mode),
      home: SplashScreen(config: config, mode: mode),
    );
  }
}
