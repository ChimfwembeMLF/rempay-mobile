import 'package:wanderlog/domain/models.dart';

/// Repository interface for authentication operations
/// Defined in the domain layer, implemented in the data layer
abstract class AuthRepository {
  /// Authenticate a user with email and password
  Future<AuthResult> login(String email, String password);

  /// Register a new user with tenant information
  Future<AuthResult> register({
    required String tenantName,
    required String username,
    required String email,
    required String password,
  });

  /// Get current authenticated user information
  Future<User> getCurrentUser();

  /// Log out the current user
  Future<void> logout();

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated();
}
