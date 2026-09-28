import 'dart:convert';

import 'package:flutter/services.dart';

class AppConfig {
  final Map<String, dynamic> _data;

  AppConfig._(this._data);

  static Future<AppConfig> load() async {
    final raw = await rootBundle.loadString('assets/data.json');
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException(
        'assets/data.json must contain a JSON object.',
      );
    }
    return AppConfig._(Map<String, dynamic>.from(decoded));
  }

  dynamic _required(String path) {
    dynamic value = _data;
    for (final segment in path.split('.')) {
      if (value is! Map || !value.containsKey(segment)) {
        throw FormatException('Missing required JSON value: $path');
      }
      value = value[segment];
    }
    return value;
  }

  Map<String, dynamic> object(String path) {
    final value = _required(path);
    if (value is! Map) throw FormatException('Expected JSON object: $path');
    return Map<String, dynamic>.from(value);
  }

  List<dynamic> list(String path) {
    final value = _required(path);
    if (value is! List) throw FormatException('Expected JSON array: $path');
    return value;
  }

  String string(String path) {
    final value = _required(path);
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Expected non-empty JSON string: $path');
    }
    return value;
  }

  bool boolean(String path) {
    final value = _required(path);
    if (value is! bool) throw FormatException('Expected JSON boolean: $path');
    return value;
  }

  String color(String path) {
    final raw = string(path).replaceFirst('#', '');
    final argb = raw.length == 6 ? 'FF$raw' : raw;
    if (argb.length != 8) throw FormatException('Invalid color: $path');
    final value = int.tryParse(argb, radix: 16);
    if (value == null) throw FormatException('Invalid color: $path');
    return argb;
  }

  String modeAsset(String mode) => string('assets.splash.$mode');

  String homeAsset(String mode) => string('assets.home.$mode');

  Map<String, dynamic> theme(String mode) => object('theme.modes.$mode');

  String apiEndpoint(String platform) => string('api.endpoints.$platform');

  String apiBaseUrl() => string('api.base_url');
}
