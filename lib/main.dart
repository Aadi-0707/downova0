import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Map<String, dynamic> _fallbackConfig() {
  return {
    'app': {'name': 'Downova', 'font_family': 'Roboto'},
    'theme': _defaultTheme(),
  };
}

Map<String, dynamic> _defaultTheme() {
  return {
    'default_mode': 'light',
    'modes': {
      'light': {'background': '#FFFFFF'},
      'dark': {'background': '#121212'},
    },
  };
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Map<String, dynamic> config;

  try {
    final String raw = await rootBundle.loadString('assets/data.json');
    final dynamic decoded = jsonDecode(raw);

    if (decoded is Map) {
      config = Map<String, dynamic>.from(decoded);
    } else {
      config = _fallbackConfig();
    }
  } catch (_) {
    config = _fallbackConfig();
  }

  runApp(DownovaApp(config: config));
}

class DownovaApp extends StatelessWidget {
  final Map<String, dynamic> config;

  const DownovaApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> app = _map(
      config['app'],
      'app',
      fallback: {'name': 'Downova'},
    );
    final Map<String, dynamic> theme = _map(
      config['theme'],
      'theme',
      fallback: _defaultTheme(),
    );
    final String mode = _string(
      theme['default_mode'],
      'theme.default_mode',
      fallback: 'light',
    );
    final Map<String, dynamic> modes = _map(
      theme['modes'],
      'theme.modes',
      fallback: _defaultTheme()['modes'],
    );
    final Map<String, dynamic> active = _map(
      modes[mode] ?? modes['light'],
      'theme.modes.$mode',
      fallback: _defaultTheme()['modes']['light'],
    );
    final String appName = _string(
      app['name'],
      'app.name',
      fallback: 'Downova',
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeData(
        brightness: mode == 'dark' ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: _color(
          active['background'],
          'theme.modes.$mode.background',
          fallback: mode == 'dark' ? '#121212' : '#FFFFFF',
        ),
        fontFamily: _string(
          app['font_family'],
          'app.font_family',
          fallback: 'Roboto',
        ),
        useMaterial3: true,
      ),
      home: Scaffold(body: Center(child: Text(appName))),
    );
  }

  static Map<String, dynamic> _map(
    dynamic value,
    String path, {
    Map<String, dynamic>? fallback,
  }) {
    if (value is Map) return Map<String, dynamic>.from(value);
    if (fallback != null) return fallback;
    throw FormatException('Expected JSON object at $path.');
  }

  static String _string(dynamic value, String path, {String fallback = ''}) {
    if (value is String && value.trim().isNotEmpty) return value;
    if (fallback.trim().isNotEmpty) return fallback;
    throw FormatException('Expected non-empty string at $path.');
  }

  static Color _color(
    dynamic value,
    String path, {
    String fallback = '#FFFFFF',
  }) {
    final String hex = _string(
      value,
      path,
      fallback: fallback,
    ).replaceFirst('#', '');
    final String argb = hex.length == 6 ? 'FF$hex' : hex;
    final int? valueInt = int.tryParse(argb, radix: 16);
    if (valueInt == null || argb.length != 8) {
      throw FormatException('Invalid color at $path.');
    }
    return Color(valueInt);
  }
}
