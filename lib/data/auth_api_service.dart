import 'package:flutter/foundation.dart';
import 'package:wanderlog/data/auth_dto.dart';
import 'package:wanderlog/data/credentials_storage.dart';
import 'package:wanderlog/data/payment_gateway_api.dart';
import 'package:wanderlog/domain/auth_repository.dart';
import 'package:wanderlog/domain/models.dart';
import 'dart:convert';

/// Implementation of AuthRepository using the Payment Gateway API
class AuthApiService implements AuthRepository {
  final PaymentGatewayApi _api;
  final CredentialsStorage _storage;
  String? _cachedToken;
  User? _cachedUser;

  AuthApiService(this._api, this._storage);

  /// Get the underlying API client
  PaymentGatewayApi get api => _api;

  /// Get the credentials storage
  CredentialsStorage get storage => _storage;

  /// Initialize with stored credentials
  Future<void> initialize() async {
    final storedToken = _storage.getToken();
    final storedApiKey = _storage.getApiKey();
    final storedTenantId = _storage.getTenantId();

    debugPrint('[AuthApiService.initialize] Checking stored credentials...');
    if (storedToken != null) {
      _api.setBearerToken(storedToken);
      _cachedToken = storedToken;
      debugPrint('[AuthApiService.initialize] Bearer token restored');
    }

    if (storedApiKey != null && storedApiKey.isNotEmpty) {
      _api.setApiKey(storedApiKey);
      debugPrint('[AuthApiService.initialize] API key restored: ${storedApiKey.substring(0, 20)}...');
    } else {
      debugPrint('[AuthApiService.initialize] No API key found in storage');
    }

    if (storedTenantId != null && storedTenantId.isNotEmpty) {
      _api.setTenantId(storedTenantId);
      debugPrint('[AuthApiService.initialize] Tenant ID restored: $storedTenantId');
    } else {
      debugPrint('[AuthApiService.initialize] No tenant ID found in storage');
    }
  }
  Future<AuthResult> login(String email, String password) async {
    final requestDto = LoginRequestDto(email: email, password: password);

    try {
      final response = await _api.postJson(
        '/api/v1/auth/login',
        body: requestDto.toJson(),
      );

      final authDto = AuthResponseDto.fromJson(response);

      // Cache token and user
      _cachedToken = authDto.accessToken;
      _cachedUser = _mapUserDtoToDomain(authDto.user);

      // Save the new bearer token
      await _storage.saveToken(authDto.accessToken);
      await _storage.saveUserId(authDto.user.id);
      _api.setBearerToken(authDto.accessToken);
      debugPrint('[AuthApiService.login] Bearer token saved: ${authDto.accessToken.substring(0, 20)}...');

      // IMPORTANT: Preserve API key and tenant ID from storage during login
      // The login response doesn't include these, but they're stored from registration
      final storedApiKey = _storage.getApiKey();
      if (storedApiKey != null && storedApiKey.isNotEmpty) {
        _api.setApiKey(storedApiKey);
        debugPrint('[AuthApiService.login] API key restored from storage: ${storedApiKey.substring(0, 20)}...');
      } else {
        debugPrint('[AuthApiService.login] WARNING: No API key found in storage');
      }

      // Try to restore tenant ID from storage first
      final storedTenantId = _storage.getTenantId();
      if (storedTenantId != null && storedTenantId.isNotEmpty) {
        _api.setTenantId(storedTenantId);
        debugPrint('[AuthApiService.login] Tenant ID restored from storage: $storedTenantId');
      } else {
        // If not in storage, try to extract from JWT token
        final tokenTenantId = _extractTenantIdFromToken(authDto.accessToken);
        if (tokenTenantId != null && tokenTenantId.isNotEmpty) {
          await _storage.saveTenantId(tokenTenantId);
          _api.setTenantId(tokenTenantId);
          debugPrint('[AuthApiService.login] Tenant ID extracted from token and saved: $tokenTenantId');
        } else {
          debugPrint('[AuthApiService.login] WARNING: No tenant ID found in storage or token');
        }
      }

      return AuthResult(
        user: _cachedUser!,
        token: AuthToken(
          accessToken: authDto.accessToken,
          tokenType: authDto.tokenType,
        ),
      );
    } on FormatException catch (e) {
      throw AuthException('Invalid response format: ${e.message}');
    } on HttpException catch (e) {
      if (e.statusCode == 401) {
        throw AuthException('Invalid email or password');
      } else if (e.statusCode == 400) {
        throw AuthException('Invalid request: ${e.body}');
      }
      throw AuthException('Login failed: ${e.message}');
    } catch (e) {
      throw AuthException('Network error: $e');
    }
  }

  @override
  Future<AuthResult> register({
    required String tenantName,
    required String username,
    required String email,
    required String password,
  }) async {
    final requestDto = RegisterRequestDto(
      tenantName: tenantName,
      username: username,
      email: email,
      password: password,
    );

    try {
      final response = await _api.postJson(
        '/api/v1/auth/register',
        body: requestDto.toJson(),
      );

      final authDto = AuthResponseDto.fromJson(response);

      // Cache token and user
      _cachedToken = authDto.accessToken;
      _cachedUser = _mapUserDtoToDomain(authDto.user);

      // Persist token, API key, and tenant ID
      await _storage.saveToken(authDto.accessToken);
      await _storage.saveUserId(authDto.user.id);
      
      if (authDto.apiKey != null && authDto.apiKey!.isNotEmpty) {
        await _storage.saveApiKey(authDto.apiKey!);
        _api.setApiKey(authDto.apiKey!);
        debugPrint('[AuthApiService.register] API key saved and set: ${authDto.apiKey!.substring(0, 20)}...');
      } else {
        debugPrint('[AuthApiService.register] WARNING: API key is null or empty');
      }

      if (authDto.tenantId != null && authDto.tenantId!.isNotEmpty) {
        await _storage.saveTenantId(authDto.tenantId!);
        _api.setTenantId(authDto.tenantId!);
        debugPrint('[AuthApiService.register] Tenant ID saved and set: ${authDto.tenantId!}');
      } else {
        // If not in response, try to extract from JWT token
        final tokenTenantId = _extractTenantIdFromToken(authDto.accessToken);
        if (tokenTenantId != null && tokenTenantId.isNotEmpty) {
          await _storage.saveTenantId(tokenTenantId);
          _api.setTenantId(tokenTenantId);
          debugPrint('[AuthApiService.register] Tenant ID extracted from token and saved: $tokenTenantId');
        }
      }

      // Set the bearer token in the API client
      _api.setBearerToken(authDto.accessToken);
      debugPrint('[AuthApiService.register] Bearer token set for user: ${authDto.user.email}');

      return AuthResult(
        user: _cachedUser!,
        token: AuthToken(
          accessToken: authDto.accessToken,
          tokenType: authDto.tokenType,
        ),
      );
    } on FormatException catch (e) {
      throw AuthException('Invalid response format: ${e.message}');
    } on HttpException catch (e) {
      if (e.statusCode == 409) {
        throw AuthException('User already exists');
      } else if (e.statusCode == 400) {
        throw AuthException('Invalid request: ${e.body}');
      }
      throw AuthException('Registration failed: ${e.message}');
    } catch (e) {
      throw AuthException('Network error: $e');
    }
  }

  @override
  Future<User> getCurrentUser() async {
    if (_cachedUser != null) {
      return _cachedUser!;
    }

    if (_cachedToken == null) {
      throw AuthException('No authentication token available');
    }

    try {
      final response = await _api.getJson('/api/v1/auth/me');
      final userDto = UserDto.fromJson(response);

      _cachedUser = _mapUserDtoToDomain(userDto);
      return _cachedUser!;
    } on FormatException catch (e) {
      throw AuthException('Invalid response format: ${e.message}');
    } on HttpException catch (e) {
      if (e.statusCode == 401) {
        // Token expired or invalid
        _cachedToken = null;
        _cachedUser = null;
        throw AuthException('Session expired, please login again');
      }
      throw AuthException('Failed to get user: ${e.message}');
    } catch (e) {
      throw AuthException('Network error: $e');
    }
  }

  @override
  Future<void> logout() async {
    _cachedToken = null;
    _cachedUser = null;
    _api.clearBearerToken();
    _api.clearApiKey();
    _api.clearTenantId();
    await _storage.clearToken();
    await _storage.clearApiKey();
    await _storage.clearTenantId();
    debugPrint('[AuthApiService.logout] User logged out and credentials cleared');
  }

  @override
  Future<bool> isAuthenticated() async {
    return _cachedToken != null;
  }

  /// Map UserDto to Domain User model
  User _mapUserDtoToDomain(UserDto dto) {
    return User(
      id: dto.id,
      email: dto.email,
      username: dto.username,
      tenantId: dto.tenantId,
    );
  }

  /// Extract tenant ID from JWT token payload
  String? _extractTenantIdFromToken(String token) {
    try {
      // JWT format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint('[AuthApiService._extractTenantIdFromToken] Invalid token format');
        return null;
      }

      // Decode payload (add padding if needed)
      String payload = parts[1];
      // Add padding if necessary
      final padding = 4 - (payload.length % 4);
      if (padding != 4) {
        payload += '=' * padding;
      }

      final decoded = jsonDecode(utf8.decode(base64Url.decode(payload))) as Map<String, dynamic>;
      final tenantId = decoded['tenantId'] as String?;
      if (tenantId != null) {
        debugPrint('[AuthApiService._extractTenantIdFromToken] Extracted tenant ID from token: $tenantId');
      }
      return tenantId;
    } catch (e) {
      debugPrint('[AuthApiService._extractTenantIdFromToken] Failed to extract tenant ID: $e');
      return null;
    }
  }
}

/// Exception thrown during authentication operations
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
