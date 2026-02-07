import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing stored credentials (tokens and API keys)
class CredentialsStorage {
  static const String _tokenKey = 'auth_token';
  static const String _apiKeyKey = 'api_key';
  static const String _userIdKey = 'user_id';
  static const String _tenantIdKey = 'tenant_id';

  late final SharedPreferences _prefs;

  CredentialsStorage(this._prefs);

  /// Create instance with SharedPreferences
  static Future<CredentialsStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return CredentialsStorage(prefs);
  }

  /// Get stored auth token
  String? getToken() => _prefs.getString(_tokenKey);

  /// Save auth token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  /// Clear auth token
  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  /// Get stored API key
  String? getApiKey() => _prefs.getString(_apiKeyKey);

  /// Save API key
  Future<void> saveApiKey(String apiKey) async {
    await _prefs.setString(_apiKeyKey, apiKey);
  }

  /// Clear API key
  Future<void> clearApiKey() async {
    await _prefs.remove(_apiKeyKey);
  }

  /// Get stored tenant ID
  String? getTenantId() => _prefs.getString(_tenantIdKey);

  /// Save tenant ID
  Future<void> saveTenantId(String tenantId) async {
    await _prefs.setString(_tenantIdKey, tenantId);
  }

  /// Clear tenant ID
  Future<void> clearTenantId() async {
    await _prefs.remove(_tenantIdKey);
  }

  /// Get stored user ID
  String? getUserId() => _prefs.getString(_userIdKey);

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
  }

  /// Clear all credentials
  Future<void> clearAll() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_apiKeyKey);
    await _prefs.remove(_tenantIdKey);
    await _prefs.remove(_userIdKey);
  }
}
