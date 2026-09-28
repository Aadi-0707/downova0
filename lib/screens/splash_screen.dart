import 'dart:async';

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../config/ui_values.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final AppConfig config;
  final String mode;

  const SplashScreen({super.key, required this.config, required this.mode});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(
      Duration(milliseconds: UiValues.integer('splash.duration_ms')),
      _openHome,
    );
  }

  void _openHome() {
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => HomeScreen(config: widget.config, mode: widget.mode),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final mode = widget.mode;
    final screenImage = config.modeAsset(mode);
    final textPrimary = _color(config.color('theme.modes.$mode.text_primary'));
    final textSecondary = _color(
      config.color('theme.modes.$mode.text_secondary'),
    );
    final secondary = _color(config.color('theme.modes.$mode.secondary'));
    final size = MediaQuery.sizeOf(context);
    final logoSize = size.width * UiValues.value('splash.logo_size_factor');

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            screenImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              final background = config.color(
                'theme.background_when_image_missing.$mode',
              );
              return ColoredBox(color: _color(background));
            },
          ),
          SafeArea(
            child: Column(
              children: [
                Spacer(flex: UiValues.integer('splash.top_spacer_flex')),
                Image.asset(
                  config.string('assets.app_logo'),
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  height:
                      size.height * UiValues.value('splash.title_gap_factor'),
                ),
                Text(
                  config.string('splash.title'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize:
                        size.width * UiValues.value('splash.title_size_factor'),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(
                  height:
                      size.height * UiValues.value('splash.tagline_gap_factor'),
                ),
                Text(
                  config.string('splash.tagline'),
                  style: TextStyle(
                    color: textSecondary,
                    fontSize:
                        size.width *
                        UiValues.value('splash.tagline_size_factor'),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(flex: UiValues.integer('splash.middle_spacer_flex')),
                if (config.boolean('splash.show_loading_indicator'))
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          size.width *
                          UiValues.value('splash.progress_horizontal_factor'),
                    ),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          minHeight: UiValues.value('splash.progress_height')
                              .toDouble(),
                          borderRadius: BorderRadius.circular(
                            UiValues.value('splash.progress_radius'),
                          ),
                          backgroundColor: textSecondary.withValues(
                            alpha: UiValues.value(
                              'splash.progress_background_alpha',
                            ).toDouble(),
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(secondary),
                        ),
                        SizedBox(
                          height:
                              size.height *
                              UiValues.value('splash.loading_gap_factor'),
                        ),
                        Text(
                          config.string('splash.loading_text'),
                          style: TextStyle(
                            color: textSecondary,
                            fontSize:
                                size.width *
                                UiValues.value(
                                  'splash.loading_text_size_factor',
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                Text(
                  config.string('splash.version_text'),
                  style: TextStyle(
                    color: textSecondary.withValues(
                      alpha: UiValues.value('splash.version_alpha').toDouble(),
                    ),
                    fontSize:
                        size.width *
                        UiValues.value('splash.version_text_size_factor'),
                  ),
                ),
                SizedBox(
                  height:
                      size.height * UiValues.value('splash.bottom_gap_factor'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _color(String hex) => Color(int.parse(hex, radix: 16));
}
