enum TransactionStatus {
  pending,
  completed,
  failed,
  refunded,
}

enum TransactionType {
  payment,
  payout,
  refund,
  adjustment,
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

class MerchantAccount {
  final String id;
  final String name;
  final String currency;
  final Balance balance;

  MerchantAccount({
    required this.id,
    required this.name,
    required this.currency,
    required this.balance,
  });
}

class Balance {
  final double available;
  final double pending;

  Balance({
    required this.available,
    required this.pending,
  });
}

class Transaction {
  final String id;
  final String reference;
  final double amount;
  final String currency;
  final TransactionStatus status;
  final TransactionType type;
  final DateTime timestamp;
  final String counterparty; // Name of person/entity paid or paying

  Transaction({
    required this.id,
    required this.reference,
    required this.amount,
    required this.currency,
    required this.status,
    required this.type,
    required this.timestamp,
    required this.counterparty,
  });
}

class Alert {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final bool isRead;

  Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    required this.isRead,
  });
}

/// Represents an authenticated user in the domain layer
class User {
  final String id;
  final String email;
  final String username;
  final String? tenantId;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.tenantId,
  });
}

/// Represents an authentication token
class AuthToken {
  final String accessToken;
  final String tokenType;

  AuthToken({
    required this.accessToken,
    this.tokenType = 'Bearer',
  });
}

/// Represents the result of authentication operations
class AuthResult {
  final User user;
  final AuthToken token;

  AuthResult({
    required this.user,
    required this.token,
  });
}
