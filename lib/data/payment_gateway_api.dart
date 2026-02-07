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
  PaymentGatewayApi(
      {http.Client? client, String? baseUrl, this.tenantId, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKey = apiKey,
        baseUrl = _resolveBaseUrl(baseUrl);

  static String _resolveBaseUrl(String? explicitBaseUrl) {
    if (explicitBaseUrl != null) return explicitBaseUrl.trim();

    final fromEnv =
        const String.fromEnvironment('PAYMENT_GATEWAY_BASE_URL').trim();
    if (fromEnv.isNotEmpty) return fromEnv;

    // Sensible defaults for Dreamflow development vs production builds.
    return kReleaseMode
        ? 'https://api.tekreminnovations.com'
        : 'http://localhost:3000';
  }

  final http.Client _client;
  final String baseUrl;
  String? tenantId;
  String? _apiKey;
  String? _bearerToken;

  bool get isConfigured => baseUrl.isNotEmpty;

  /// Set the bearer token for authentication
  void setBearerToken(String token) {
    _bearerToken = token;
    debugPrint('[PaymentGatewayApi.setBearerToken] Token set: ${token.substring(0, 20)}...');
  }

  /// Clear the bearer token
  void clearBearerToken() {
    _bearerToken = null;
    debugPrint('[PaymentGatewayApi.clearBearerToken] Token cleared');
  }

  /// Set the API key
  void setApiKey(String key) {
    _apiKey = key;
    debugPrint('[PaymentGatewayApi.setApiKey] API key set: ${key.substring(0, 20)}...');
  }

  /// Clear the API key
  void clearApiKey() {
    _apiKey = null;
    debugPrint('[PaymentGatewayApi.clearApiKey] API key cleared');
  }

  /// Get the current API key
  String? getApiKey() => _apiKey;

  /// Set the tenant ID
  void setTenantId(String id) {
    tenantId = id;
    debugPrint('[PaymentGatewayApi.setTenantId] Tenant ID set: $id');
  }

  /// Get the current tenant ID
  String? getTenantId() => tenantId;

  /// Clear the tenant ID
  void clearTenantId() {
    tenantId = null;
    debugPrint('[PaymentGatewayApi.clearTenantId] Tenant ID cleared');
  }

  Map<String, String> _headers({Map<String, String>? extra}) {
    final headers = <String, String>{'content-type': 'application/json'};
    final resolvedTenantId =
        (tenantId ?? const String.fromEnvironment('PAYMENT_GATEWAY_TENANT_ID'))
            .trim();
    final resolvedApiKey =
        (_apiKey ?? const String.fromEnvironment('PAYMENT_GATEWAY_API_KEY'))
            .trim();

    if (resolvedTenantId.isNotEmpty) {
      headers['x-tenant-id'] = resolvedTenantId;
      debugPrint('[PaymentGatewayApi._headers] ✓ x-tenant-id: $resolvedTenantId');
    } else {
      debugPrint('[PaymentGatewayApi._headers] ✗ WARNING: No tenant ID set (tenantId=$tenantId, env=${const String.fromEnvironment('PAYMENT_GATEWAY_TENANT_ID')})');
    }
    
    if (resolvedApiKey.isNotEmpty) {
      headers['x-api-key'] = resolvedApiKey;
      debugPrint('[PaymentGatewayApi._headers] ✓ x-api-key: ${resolvedApiKey.substring(0, 20)}...');
    } else {
      debugPrint('[PaymentGatewayApi._headers] ✗ WARNING: No API key set (_apiKey=$_apiKey, env=${const String.fromEnvironment('PAYMENT_GATEWAY_API_KEY')})');
    }
    
    if (_bearerToken != null && _bearerToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_bearerToken';
      debugPrint('[PaymentGatewayApi._headers] ✓ Authorization: Bearer ${_bearerToken!.substring(0, 20)}...');
    } else {
      debugPrint('[PaymentGatewayApi._headers] ✗ WARNING: No bearer token set (_bearerToken=$_bearerToken)');
    }

    if (extra != null) headers.addAll(extra);
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$normalizedBase$normalizedPath');
    return query == null
        ? uri
        : uri.replace(queryParameters: query.map((k, v) => MapEntry(k, '$v')));
  }

  Future<Map<String, dynamic>> getJson(String path,
      {Map<String, dynamic>? query}) async {
    final uri = _uri(path, query);
    final headers = _headers();
    debugPrint('════════════════════════════════════════════════════════════');
    debugPrint('[HTTP GET] $uri');
    debugPrint('[HEADERS] $headers');
    if (query != null) debugPrint('[QUERY] $query');
    debugPrint('════════════════════════════════════════════════════════════');
    try {
      final res = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));
      final bytes = res.bodyBytes;
      final body = utf8.decode(bytes);
      debugPrint('[HTTP RESPONSE] ${res.statusCode}: ${body.length > 500 ? body.substring(0, 500) + '...' : body}');

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw HttpException('Request failed',
            statusCode: res.statusCode, body: body);
      }

      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const FormatException('Expected JSON object');
    } on TimeoutException {
      debugPrint('[HTTP ERROR] GET $uri timed out');
      rethrow;
    } catch (e) {
      debugPrint('[HTTP ERROR] GET $uri: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getJsonList(String path,
      {Map<String, dynamic>? query}) async {
    final uri = _uri(path, query);
    final headers = _headers();
    debugPrint('════════════════════════════════════════════════════════════');
    debugPrint('[HTTP GET LIST] $uri');
    debugPrint('[HEADERS] $headers');
    if (query != null) debugPrint('[QUERY] $query');
    debugPrint('════════════════════════════════════════════════════════════');
    try {
      final res = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));
      final bytes = res.bodyBytes;
      final body = utf8.decode(bytes);
      debugPrint('[HTTP RESPONSE] ${res.statusCode}: ${body.length > 500 ? body.substring(0, 500) + '...' : body}');

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw HttpException('Request failed',
            statusCode: res.statusCode, body: body);
      }

      final decoded = jsonDecode(body);
      if (decoded is List) return decoded;
      throw const FormatException('Expected JSON array');
    } on TimeoutException {
      debugPrint('[HTTP ERROR] GET $uri timed out');
      rethrow;
    } catch (e) {
      debugPrint('[HTTP ERROR] GET $uri: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> postJson(String path,
      {Object? body, Map<String, String>? extraHeaders}) async {
    final uri = _uri(path);
    final headers = _headers(extra: extraHeaders);
    debugPrint('════════════════════════════════════════════════════════════');
    debugPrint('[HTTP POST] $uri');
    debugPrint('[HEADERS] $headers');
    if (body != null) debugPrint('[BODY] ${jsonEncode(body)}');
    debugPrint('════════════════════════════════════════════════════════════');
    try {
      final res = await _client
          .post(uri, headers: headers, body: body == null ? null : jsonEncode(body))
          .timeout(const Duration(seconds: 20));
      final bytes = res.bodyBytes;
      final decodedBody = utf8.decode(bytes);
      debugPrint('[HTTP RESPONSE] ${res.statusCode}: ${decodedBody.length > 500 ? decodedBody.substring(0, 500) + '...' : decodedBody}');

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw HttpException('Request failed',
            statusCode: res.statusCode, body: decodedBody);
      }

      if (decodedBody.trim().isEmpty) return <String, dynamic>{};

      final decoded = jsonDecode(decodedBody);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const FormatException('Expected JSON object');
    } on TimeoutException {
      debugPrint('[HTTP ERROR] POST $uri timed out');
      rethrow;
    } catch (e) {
      debugPrint('[HTTP ERROR] POST $uri: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> patchJson(String path,
      {Object? body, Map<String, String>? extraHeaders}) async {
    final uri = _uri(path);
    final headers = _headers(extra: extraHeaders);
    debugPrint('════════════════════════════════════════════════════════════');
    debugPrint('[HTTP PATCH] $uri');
    debugPrint('[HEADERS] $headers');
    if (body != null) debugPrint('[BODY] ${jsonEncode(body)}');
    debugPrint('════════════════════════════════════════════════════════════');
    try {
      final res = await _client
          .patch(uri, headers: headers, body: body == null ? null : jsonEncode(body))
          .timeout(const Duration(seconds: 20));
      final bytes = res.bodyBytes;
      final decodedBody = utf8.decode(bytes);
      debugPrint('[HTTP RESPONSE] ${res.statusCode}: ${decodedBody.length > 500 ? decodedBody.substring(0, 500) + '...' : decodedBody}');

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw HttpException('Request failed',
            statusCode: res.statusCode, body: decodedBody);
      }

      if (decodedBody.trim().isEmpty) return <String, dynamic>{};

      final decoded = jsonDecode(decodedBody);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const FormatException('Expected JSON object');
    } on TimeoutException {
      debugPrint('[HTTP ERROR] PATCH $uri timed out');
      rethrow;
    } catch (e) {
      debugPrint('[HTTP ERROR] PATCH $uri: $e');
      rethrow;
    }
  }
}

class HttpException implements Exception {
  const HttpException(this.message,
      {required this.statusCode, required this.body});
  final String message;
  final int statusCode;
  final String body;

  @override
  String toString() => 'HttpException($statusCode): $message';
}

