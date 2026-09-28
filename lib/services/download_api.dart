import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../config/ui_values.dart';

class DownloadApi {
  final AppConfig config;

  const DownloadApi(this.config);

  Future<Map<String, dynamic>> download({
    required String platform,
    required String url,
  }) async {
    final endpoint = config.apiEndpoint(platform);
    final base = config.apiBaseUrl();
    final response = await http
        .post(
          Uri.parse('$base$endpoint'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'url': url}),
        )
        .timeout(Duration(seconds: UiValues.integer('api.timeout_seconds')));

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('API response must be a JSON object.');
    }

    final result = Map<String, dynamic>.from(decoded);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Download API request failed: ${response.statusCode}');
    }
    return result;
  }
}
