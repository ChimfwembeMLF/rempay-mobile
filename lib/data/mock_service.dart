import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:wanderlog/domain/models.dart';

class MockService {
  static final MockService _instance = MockService._internal();
  factory MockService() => _instance;
  MockService._internal();

  // Mock Data
  MerchantAccount _currentAccount = MerchantAccount(
    id: 'merch_001',
    name: 'Acme Corp',
    currency: 'USD',
    balance: Balance(
      available: 12450.00,
      pending: 3200.50,
    ),
  );

  final List<Transaction> _transactions = [
    Transaction(
      id: 'tx_101',
      reference: 'ORD-2024-001',
      amount: 120.00,
      currency: 'USD',
      status: TransactionStatus.completed,
      type: TransactionType.payment,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      counterparty: 'John Doe',
    ),
    Transaction(
      id: 'tx_102',
      reference: 'ORD-2024-002',
      amount: 450.50,
      currency: 'USD',
      status: TransactionStatus.completed,
      type: TransactionType.payment,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      counterparty: 'Sarah Smith',
    ),
    Transaction(
      id: 'tx_103',
      reference: 'PO-9921',
      amount: -2500.00,
      currency: 'USD',
      status: TransactionStatus.completed,
      type: TransactionType.payout,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      counterparty: 'Bank Transfer',
    ),
    Transaction(
      id: 'tx_104',
      reference: 'REF-8821',
      amount: -50.00,
      currency: 'USD',
      status: TransactionStatus.refunded,
      type: TransactionType.refund,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      counterparty: 'Mike Ross',
    ),
    Transaction(
      id: 'tx_105',
      reference: 'ORD-2024-003',
      amount: 89.99,
      currency: 'USD',
      status: TransactionStatus.pending,
      type: TransactionType.payment,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      counterparty: 'Jessica Pearson',
    ),
    Transaction(
      id: 'tx_106',
      reference: 'ORD-2024-004',
      amount: 210.00,
      currency: 'USD',
      status: TransactionStatus.failed,
      type: TransactionType.payment,
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
      counterparty: 'Louis Litt',
    ),
  ];

  final List<Alert> _alerts = [
    Alert(
      id: 'alt_001',
      title: 'High Fraud Risk',
      message: 'Transaction tx_106 flagged as high risk.',
      severity: AlertSeverity.high,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
    ),
    Alert(
      id: 'alt_002',
      title: 'Payout Settled',
      message: 'Your weekly payout has been settled.',
      severity: AlertSeverity.low,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  // Methods
  Future<MerchantAccount> getMerchantAccount() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate latency
    return _currentAccount;
  }

  Future<List<Transaction>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.unmodifiable(_transactions);
  }

  Future<List<Alert>> getAlerts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_alerts);
  }

  Future<Transaction> createPayout(
      {required double amount,
      required String currency,
      required String destinationLabel,
      String? note}) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (amount <= 0)
      throw ArgumentError.value(amount, 'amount', 'Amount must be > 0');

    // In a real system, payouts reduce available balance and may become pending.
    final id = 'po_${1000 + Random().nextInt(8999)}';
    final tx = Transaction(
      id: id,
      reference: id.toUpperCase(),
      amount: -amount,
      currency: currency,
      status: TransactionStatus.pending,
      type: TransactionType.payout,
      timestamp: DateTime.now(),
      counterparty: destinationLabel,
    );

    _transactions.insert(0, tx);

    final nextAvailable = (_currentAccount.balance.available - amount)
        .clamp(0, double.infinity)
        .toDouble();
    _currentAccount = MerchantAccount(
      id: _currentAccount.id,
      name: _currentAccount.name,
      currency: _currentAccount.currency,
      balance: Balance(
          available: nextAvailable,
          pending: _currentAccount.balance.pending + amount),
    );

    _alerts.insert(
      0,
      Alert(
        id: 'alt_${100 + Random().nextInt(899)}',
        title: 'Payout initiated',
        message:
            '${note?.trim().isNotEmpty == true ? '${note!.trim()} • ' : ''}Destination: $destinationLabel',
        severity: AlertSeverity.low,
        timestamp: DateTime.now(),
        isRead: false,
      ),
    );

    return tx;
  }

  Future<void> markAlertRead(String alertId, bool isRead) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index < 0) return;
    final a = _alerts[index];
    _alerts[index] = Alert(
      id: a.id,
      title: a.title,
      message: a.message,
      severity: a.severity,
      timestamp: a.timestamp,
      isRead: isRead,
    );
  }

  Future<void> markAllAlertsRead() async {
    await Future.delayed(const Duration(milliseconds: 350));
    for (var i = 0; i < _alerts.length; i++) {
      final a = _alerts[i];
      if (a.isRead) continue;
      _alerts[i] = Alert(
        id: a.id,
        title: a.title,
        message: a.message,
        severity: a.severity,
        timestamp: a.timestamp,
        isRead: true,
      );
    }
  }

  Future<void> deleteAlert(String alertId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _alerts.removeWhere((a) => a.id == alertId);
  }

  int get unreadAlertCount => _alerts.where((a) => !a.isRead).length;

  bool get isGatewayConfigured {
    // For mock service, always false; actual config lives in PaymentGatewayApi.
    // Keeping this for UI convenience.
    return false;
  }

  void debugDump() {
    debugPrint(
        'MockService: tx=${_transactions.length} alerts=${_alerts.length}');
  }
}
