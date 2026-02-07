import 'package:flutter/foundation.dart';
import 'package:wanderlog/data/merchant_config_dto.dart';
import 'package:wanderlog/data/merchant_config_service.dart';
import 'package:wanderlog/data/payment_gateway_api.dart';

/// Provider for managing merchant configuration state
class MerchantConfigProvider extends ChangeNotifier {
  final PaymentGatewayApi api;
  late final MerchantConfigService _service;

  MerchantConfigDto? _config;
  bool _loading = false;
  String? _error;

  MerchantConfigProvider({required this.api}) {
    _service = MerchantConfigService(api);
  }

  // Getters
  MerchantConfigDto? get config => _config;
  bool get loading => _loading;
  String? get error => _error;

  /// Load merchant configuration from API
  Future<void> loadConfiguration() async {
    try {
      _setLoading(true);
      _error = null;
      _config = await _service.getConfiguration();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Update business information
  Future<void> updateBusinessInfo({
    required String businessName,
    String? registrationNumber,
    String? taxId,
    String? category,
    String? website,
    String? address,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      await _service.updateConfiguration(
        UpdateMerchantConfigDto(
          businessName: businessName,
          businessRegistrationNumber: registrationNumber,
          taxId: taxId,
          businessCategory: category,
          websiteUrl: website,
          businessAddress: address,
          contactPersonName: contactName,
          contactPersonPhone: contactPhone,
          contactPersonEmail: contactEmail,
        ),
      );

      // Reload configuration
      await loadConfiguration();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Verify MTN credentials
  Future<void> verifyMtnCredentials({
    required String subscriptionKey,
    required String apiKey,
    required String xReferenceId,
    required String targetEnvironment,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      await _service.verifyMtnCredentials(
        subscriptionKey: subscriptionKey,
        apiKey: apiKey,
        xReferenceId: xReferenceId,
        targetEnvironment: targetEnvironment,
      );

      // Reload configuration
      await loadConfiguration();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Verify Airtel credentials
  Future<void> verifyAirtelCredentials({
    required String clientId,
    required String clientSecret,
    required String signingSecret,
    required String environment,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      await _service.verifyAirtelCredentials(
        clientId: clientId,
        clientSecret: clientSecret,
        signingSecret: signingSecret,
        environment: environment,
      );

      // Reload configuration
      await loadConfiguration();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Verify bank account
  Future<void> verifyBankAccount({
    required String accountNumber,
    required String bankCode,
    required String accountHolder,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      await _service.verifyBankAccount(
        accountNumber: accountNumber,
        bankCode: bankCode,
        accountHolder: accountHolder,
      );

      // Reload configuration
      await loadConfiguration();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Test webhook
  Future<void> testWebhook({
    required String eventType,
    Map<String, dynamic>? payload,
  }) async {
    try {
      await _service.testWebhook(
        eventType: eventType,
        payload: payload ?? {},
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void _setLoading(bool value) {
    if (_loading != value) {
      _loading = value;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
