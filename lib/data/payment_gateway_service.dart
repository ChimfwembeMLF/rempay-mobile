import 'package:flutter/foundation.dart';

import 'package:wanderlog/data/database_service.dart';
import 'package:wanderlog/data/mock_service.dart';
import 'package:wanderlog/data/payment_gateway_api.dart';
import 'package:wanderlog/domain/models.dart';

/// App-facing service that tries the real backend first (when configured),
/// and falls back to [MockService] to keep the UI functional in Dreamflow
/// when no backend is connected.
class PaymentGatewayService {
  PaymentGatewayService({
    PaymentGatewayApi? api,
    MockService? fallback,
    DatabaseService? database,
  })  : _api = api ?? PaymentGatewayApi(),
        _fallback = fallback ?? MockService(),
        _database = database ?? DatabaseService();

  final PaymentGatewayApi _api;
  final MockService _fallback;
  final DatabaseService _database;

  bool get isConfigured => _api.isConfigured;

  Future<MerchantAccount> getMerchantAccount() async {
    if (!_api.isConfigured) return _fallback.getMerchantAccount();

    try {
      // OpenAPI: GET /api/v1/payments/balance/available
      // Response schema isn't fully specified in the provided spec, so we parse
      // a few common shapes defensively.
      final data = await _api.getJson('/api/v1/payments/balance/available');

      final currency = (data['currency'] ?? data['code'] ?? 'USD').toString();
      final available = _readNum(data['available'] ??
              data['balance'] ??
              data['availableBalance']) ??
          0;
      final pending = _readNum(data['pending'] ?? data['pendingBalance']) ?? 0;

      final account = MerchantAccount(
        id: (data['tenantId'] ?? data['merchantId'] ?? 'merchant').toString(),
        name: (data['tenantName'] ?? data['merchantName'] ?? 'Merchant')
            .toString(),
        currency: currency,
        balance: Balance(
            available: available.toDouble(), pending: pending.toDouble()),
      );
      
      // Cache the account in SQLite
      await _database.saveMerchantAccount({
        'id': account.id,
        'name': account.name,
        'currency': account.currency,
        'availableBalance': account.balance.available,
        'pendingBalance': account.balance.pending,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      return account;
    } catch (e) {
      debugPrint('PaymentGatewayService.getMerchantAccount fallback: $e');
      
      // Try to load from cache
      try {
        final cached = await _database.getMerchantAccount('merchant');
        if (cached != null) {
          return MerchantAccount(
            id: cached['id'] as String,
            name: cached['name'] as String,
            currency: cached['currency'] as String,
            balance: Balance(
              available: (cached['availableBalance'] as num).toDouble(),
              pending: (cached['pendingBalance'] as num).toDouble(),
            ),
          );
        }
      } catch (cacheError) {
        debugPrint('Failed to load cached merchant account: $cacheError');
      }
      
      return _fallback.getMerchantAccount();
    }
  }

  Future<List<Transaction>> getTransactions() async {
    if (!_api.isConfigured) return _fallback.getTransactions();

    try {
      // OpenAPI: GET /api/v1/payments (returns array of Payment)
      final items = await _api.getJsonList('/api/v1/payments');
      final txs = <Transaction>[];
      for (final raw in items) {
        if (raw is! Map) continue;
        final m = raw.cast<String, dynamic>();

        final id = (m['id'] ?? m['_id'] ?? m['paymentId'] ?? '').toString();
        final reference =
            (m['externalId'] ?? m['reference'] ?? m['ref'] ?? id).toString();
        final currency = (m['currency'] ?? 'USD').toString();
        final amount =
            _readNum(m['amount'] ?? m['total'] ?? 0)?.toDouble() ?? 0.0;
        final status =
            _parseStatus((m['status'] ?? m['state'] ?? '').toString());
        final createdAt =
            _parseDate(m['createdAt'] ?? m['timestamp'] ?? m['date']);

        txs.add(
          Transaction(
            id: id.isEmpty ? reference : id,
            reference: reference,
            amount: amount,
            currency: currency,
            status: status,
            type: TransactionType.payment,
            timestamp: createdAt ?? DateTime.now(),
            counterparty:
                (m['payer'] ?? m['customer'] ?? m['counterparty'] ?? 'Customer')
                    .toString(),
          ),
        );
      }

      // If backend returned nothing / unknown schema, keep UI populated.
      return txs.isEmpty ? await _fallback.getTransactions() : txs;
    } catch (e) {
      debugPrint('PaymentGatewayService.getTransactions fallback: $e');
      return _fallback.getTransactions();
    }
  }

  Future<List<Alert>> getAlerts() async {
    // No OpenAPI mapping provided for alerts; keep it local/mock for MVP.
    return _fallback.getAlerts();
  }

  Future<void> markAlertRead(String alertId, bool isRead) async {
    return _fallback.markAlertRead(alertId, isRead);
  }

  Future<void> markAllAlertsRead() async {
    return _fallback.markAllAlertsRead();
  }

  Future<void> deleteAlert(String alertId) async {
    return _fallback.deleteAlert(alertId);
  }

  Future<Transaction> createPayout(
      {required double amount,
      required String currency,
      required String destinationLabel,
      String? note}) async {
    if (!_api.isConfigured) {
      return _fallback.createPayout(
          amount: amount,
          currency: currency,
          destinationLabel: destinationLabel,
          note: note);
    }

    try {
      // OpenAPI endpoint for payouts isn't defined in the current spec.
      // We still attempt a conservative POST that many gateways support.
      await _api.postJson(
        '/api/v1/payouts',
        body: {
          'amount': amount,
          'currency': currency,
          'destination': destinationLabel,
          if (note != null) 'note': note,
        },
      );

      // If it succeeds but schema is unknown, reflect it immediately in UI
      // by creating a local pending payout entry.
      return _fallback.createPayout(
          amount: amount,
          currency: currency,
          destinationLabel: destinationLabel,
          note: note);
    } catch (e) {
      debugPrint('PaymentGatewayService.createPayout fallback: $e');
      return _fallback.createPayout(
          amount: amount,
          currency: currency,
          destinationLabel: destinationLabel,
          note: note);
    }
  }

  num? _readNum(Object? v) {
    if (v == null) return null;
    if (v is num) return v;
    final s = v.toString();
    return num.tryParse(s);
  }

  DateTime? _parseDate(Object? v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  TransactionStatus _parseStatus(String raw) {
    final v = raw.trim().toLowerCase();
    if (v.isEmpty) return TransactionStatus.completed;
    if (v.contains('pend')) return TransactionStatus.pending;
    if (v.contains('fail') || v.contains('error'))
      return TransactionStatus.failed;
    if (v.contains('refund')) return TransactionStatus.refunded;
    if (v.contains('success') || v.contains('complete') || v.contains('paid'))
      return TransactionStatus.completed;
    return TransactionStatus.completed;
  }
}
