import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Minimal API client for the Payment Gateway OpenAPI spec found in `/backend.json`.
///
/// Configure at runtime via `--dart-define`:
/// - `PAYMENT_GATEWAY_BASE_URL` (e.g. https://api.example.com)
/// - `PAYMENT_GATEWAY_TENANT_ID`
/// - `PAYMENT_GATEWAY_API_KEY`
///
/// If `PAYMENT_GATEWAY_BASE_URL` is not provided, the client defaults to:
/// - Debug/Profile: http://localhost:3000
/// - Release: https://api.tekreminnovations.com
///
/// Set `PAYMENT_GATEWAY_BASE_URL` to an empty string to force the app to fall
/// back to mock/local data.
class PaymentGatewayApi {
  PaymentGatewayApi({http.Client? client, String? baseUrl, this.tenantId, this.apiKey})
      : _client = client ?? http.Client(),
        baseUrl = _resolveBaseUrl(baseUrl);

  static String _resolveBaseUrl(String? explicitBaseUrl) {
    if (explicitBaseUrl != null) return explicitBaseUrl.trim();

    final fromEnv = const String.fromEnvironment('PAYMENT_GATEWAY_BASE_URL').trim();
    if (fromEnv.isNotEmpty) return fromEnv;

    // Sensible defaults for Dreamflow development vs production builds.
    return kReleaseMode ? 'https://api.tekreminnovations.com' : 'http://localhost:3000';
  }

  final http.Client _client;
  final String baseUrl;
  final String? tenantId;
  final String? apiKey;

  bool get isConfigured => baseUrl.isNotEmpty;

  Map<String, String> _headers({Map<String, String>? extra}) {
    final headers = <String, String>{'content-type': 'application/json'};
    final resolvedTenantId = (tenantId ?? const String.fromEnvironment('PAYMENT_GATEWAY_TENANT_ID')).trim();
    final resolvedApiKey = (apiKey ?? const String.fromEnvironment('PAYMENT_GATEWAY_API_KEY')).trim();

    if (resolvedTenantId.isNotEmpty) headers['x-tenant-id'] = resolvedTenantId;
    if (resolvedApiKey.isNotEmpty) headers['x-api-key'] = resolvedApiKey;

    if (extra != null) headers.addAll(extra);
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$normalizedBase$normalizedPath');
    return query == null ? uri : uri.replace(queryParameters: query.map((k, v) => MapEntry(k, '$v')));
  }

  Future<Map<String, dynamic>> getJson(String path, {Map<String, dynamic>? query}) async {
    final uri = _uri(path, query);
    try {
      final res = await _client.get(uri, headers: _headers()).timeout(const Duration(seconds: 20));
      final bytes = res.bodyBytes;
      final body = utf8.decode(bytes);

      if (res.statusCode < 200 || res.statusCode >= 300) {
        debugPrint('GET $uri failed: ${res.statusCode} $body');
        throw HttpException('Request failed', statusCode: res.statusCode, body: body);
      }

      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const FormatException('Expected JSON object');
    } on TimeoutException {
      debugPrint('GET $uri timed out');
      rethrow;
    } catch (e) {
      debugPrint('GET $uri error: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getJsonList(String path, {Map<String, dynamic>? query}) async {
    final uri = _uri(path, query);
    try {
      final res = await _client.get(uri, headers: _headers()).timeout(const Duration(seconds: 20));
      final bytes = res.bodyBytes;
      final body = utf8.decode(bytes);

      if (res.statusCode < 200 || res.statusCode >= 300) {
        debugPrint('GET $uri failed: ${res.statusCode} $body');
        throw HttpException('Request failed', statusCode: res.statusCode, body: body);
      }

      final decoded = jsonDecode(body);
      if (decoded is List) return decoded;
      throw const FormatException('Expected JSON array');
    } on TimeoutException {
      debugPrint('GET $uri timed out');
      rethrow;
    } catch (e) {
      debugPrint('GET $uri error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> postJson(String path, {Object? body, Map<String, String>? extraHeaders}) async {
    final uri = _uri(path);
    try {
      final res = await _client
          .post(uri, headers: _headers(extra: extraHeaders), body: body == null ? null : jsonEncode(body))
          .timeout(const Duration(seconds: 20));
      final bytes = res.bodyBytes;
      final decodedBody = utf8.decode(bytes);

      if (res.statusCode < 200 || res.statusCode >= 300) {
        debugPrint('POST $uri failed: ${res.statusCode} $decodedBody');
        throw HttpException('Request failed', statusCode: res.statusCode, body: decodedBody);
      }

      if (decodedBody.trim().isEmpty) return <String, dynamic>{};

      final decoded = jsonDecode(decodedBody);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const FormatException('Expected JSON object');
    } on TimeoutException {
      debugPrint('POST $uri timed out');
      rethrow;
    } catch (e) {
      debugPrint('POST $uri error: $e');
      rethrow;
    }
  }
}

class HttpException implements Exception {
  const HttpException(this.message, {required this.statusCode, required this.body});
  final String message;
  final int statusCode;
  final String body;

  @override
  String toString() => 'HttpException($statusCode): $message';
}
