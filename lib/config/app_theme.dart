import 'package:flutter/material.dart';

import 'app_config.dart';

class AppTheme {
  static ThemeData build(AppConfig config, String mode) {
    final brightness = config.string('theme.modes.$mode.brightness') == 'dark'
        ? Brightness.dark
        : Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: _color(
        config.color('theme.modes.$mode.background'),
      ),
      fontFamily: config.string('app.font_family'),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: _color(config.color('theme.modes.$mode.primary')),
        onPrimary: _color(config.color('theme.modes.$mode.text_on_primary')),
        secondary: _color(config.color('theme.modes.$mode.secondary')),
        onSecondary: _color(config.color('theme.modes.$mode.text_on_primary')),
        error: _color(config.color('theme.modes.$mode.accent')),
        onError: _color(config.color('theme.modes.$mode.text_on_primary')),
        surface: _color(config.color('theme.modes.$mode.surface')),
        onSurface: _color(config.color('theme.modes.$mode.text_primary')),
        surfaceContainerHighest: _color(
          config.color('theme.modes.$mode.surface_variant'),
        ),
        onSurfaceVariant: _color(
          config.color('theme.modes.$mode.text_secondary'),
        ),
        outline: _color(config.color('theme.modes.$mode.border')),
      ),
    );
  }

  static Color _color(String hex) => Color(int.parse(hex, radix: 16));
}
