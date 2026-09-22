import 'dart:convert';
import 'dart:io';

import '../config/app_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({HttpClient? httpClient}) : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

  Future<Map<String, dynamic>> get(String path, {String? token}) {
    return _request('GET', path, token: token);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, Object?> body, {
    String? token,
  }) {
    return _request('POST', path, body: body, token: token);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, Object?>? body,
    String? token,
  }) async {
    if (!AppConfig.cloudEnabled) {
      throw const ApiException(
        'Cloud sync is not configured in this build. The offline app remains fully usable.',
      );
    }

    final base = AppConfig.apiBaseUrl.replaceFirst(RegExp(r'/+$'), '');
    final request = await _httpClient.openUrl(method, Uri.parse('$base$path'));
    request.headers.contentType = ContentType.json;
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (token != null) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    if (body != null) request.write(jsonEncode(body));

    final response = await request.close().timeout(const Duration(seconds: 20));
    final raw = await utf8.decoder.bind(response).join();
    final decoded = raw.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(raw) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        decoded['error'] as String? ?? 'The server returned an error.',
        statusCode: response.statusCode,
      );
    }
    return decoded;
  }
}
