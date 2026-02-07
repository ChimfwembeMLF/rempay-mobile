import 'package:flutter/foundation.dart';
import 'package:wanderlog/data/auth_api_service.dart';
import 'package:wanderlog/domain/auth_repository.dart';
import 'package:wanderlog/domain/models.dart';

/// State management for authentication using ChangeNotifier
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider(this._repository);

  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AuthRepository get repository => _repository;

  /// Initialize auth state (restore credentials and check if already authenticated)
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First, restore credentials from storage
      // This is critical for API key and tenant ID restoration
      if (_repository is AuthApiService) {
        // ignore: unnecessary_cast
        final authService = _repository as AuthApiService;
        await authService.initialize();
        debugPrint('[AuthProvider.initialize] Repository credentials restored');
      }
      
      // Then check if authenticated
      _isAuthenticated = await _repository.isAuthenticated();
      if (_isAuthenticated) {
        _currentUser = await _repository.getCurrentUser();
        debugPrint('[AuthProvider.initialize] User authenticated: ${_currentUser?.email}');
      } else {
        debugPrint('[AuthProvider.initialize] User not authenticated');
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _currentUser = null;
      debugPrint('[AuthProvider.initialize] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.login(email, password);
      _currentUser = result.user;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _isAuthenticated = false;
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isAuthenticated = false;
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register a new user
  Future<bool> register({
    required String tenantName,
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.register(
        tenantName: tenantName,
        username: username,
        email: email,
        password: password,
      );
      _currentUser = result.user;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _isAuthenticated = false;
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isAuthenticated = false;
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
