/// Data Transfer Objects for authentication
/// These are used to parse API responses and encode API requests

/// DTO for login request
class LoginRequestDto {
  final String email;
  final String password;

  LoginRequestDto({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

/// DTO for register request
class RegisterRequestDto {
  final String tenantName;
  final String username;
  final String email;
  final String password;

  RegisterRequestDto({
    required this.tenantName,
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'tenantName': tenantName,
        'username': username,
        'email': email,
        'password': password,
      };
}

/// DTO for authentication response
class AuthResponseDto {
  final String accessToken;
  final String tokenType;
  final UserDto user;
  final String? apiKey;
  final String? tenantId;

  AuthResponseDto({
    required this.accessToken,
    required this.tokenType,
    required this.user,
    this.apiKey,
    this.tenantId,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    // Handle wrapped response { success: true, data: { ... } }
    final data = json['data'] != null ? json['data'] as Map<String, dynamic> : json;
    
    if (data['token'] == null) {
      throw FormatException('Missing required field: token');
    }
    if (data['user'] == null && data['admin'] == null) {
      throw FormatException('Missing required field: user or admin');
    }

    // Extract user data (for login it's 'user', for registration it's 'admin')
    final userData = data['user'] ?? data['admin'];
    
    return AuthResponseDto(
      accessToken: data['token'] as String,
      tokenType: 'Bearer',
      user: UserDto.fromJson(userData as Map<String, dynamic>),
      apiKey: data['apiKey'] as String?,
      tenantId: data['tenantId'] as String?,
    );
  }
}

/// DTO for user data
class UserDto {
  final String id;
  final String email;
  final String username;
  final String? tenantId;

  UserDto({
    required this.id,
    required this.email,
    required this.username,
    this.tenantId,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw FormatException('Missing required field: id');
    }
    if (json['email'] == null) {
      throw FormatException('Missing required field: email');
    }
    if (json['username'] == null) {
      throw FormatException('Missing required field: username');
    }

    return UserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      tenantId: json['tenantId'] as String?,
    );
  }
}
