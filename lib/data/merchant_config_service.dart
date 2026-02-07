import 'package:flutter/foundation.dart';
import 'package:wanderlog/data/merchant_config_dto.dart';
import 'package:wanderlog/data/payment_gateway_api.dart';

/// Service for managing merchant configuration
class MerchantConfigService {
  final PaymentGatewayApi _api;

  MerchantConfigService(this._api);

  /// Get merchant configuration
  Future<MerchantConfigDto> getConfiguration() async {
    try {
      debugPrint('[MerchantConfigService] Getting merchant configuration...');
      final response = await _api.getJson('/api/v1/merchant/configuration');
      
      // Handle wrapped response
      final data = response['data'] != null ? response['data'] as Map<String, dynamic> : response;
      final config = MerchantConfigDto.fromJson(data);
      
      debugPrint('[MerchantConfigService] Configuration loaded: ${config.businessName}');
      return config;
    } catch (e) {
      debugPrint('[MerchantConfigService] Error getting configuration: $e');
      rethrow;
    }
  }

  /// Create merchant configuration
  Future<MerchantConfigDto> createConfiguration(
    String businessName, {
    String? businessRegistrationNumber,
    String? taxId,
    String? businessCategory,
    String? websiteUrl,
    String? businessAddress,
    String? contactPersonName,
    String? contactPersonPhone,
    String? contactPersonEmail,
  }) async {
    try {
      final body = {
        'businessName': businessName,
        if (businessRegistrationNumber != null) 'businessRegistrationNumber': businessRegistrationNumber,
        if (taxId != null) 'taxId': taxId,
        if (businessCategory != null) 'businessCategory': businessCategory,
        if (websiteUrl != null) 'websiteUrl': websiteUrl,
        if (businessAddress != null) 'businessAddress': businessAddress,
        if (contactPersonName != null) 'contactPersonName': contactPersonName,
        if (contactPersonPhone != null) 'contactPersonPhone': contactPersonPhone,
        if (contactPersonEmail != null) 'contactPersonEmail': contactPersonEmail,
      };

      debugPrint('[MerchantConfigService] Creating merchant configuration: $businessName');
      final response = await _api.postJson(
        '/api/v1/merchant/configuration',
        body: body,
      );
      
      final data = response['data'] != null ? response['data'] as Map<String, dynamic> : response;
      final config = MerchantConfigDto.fromJson(data);
      
      debugPrint('[MerchantConfigService] Configuration created successfully');
      return config;
    } catch (e) {
      debugPrint('[MerchantConfigService] Error creating configuration: $e');
      rethrow;
    }
  }

  /// Update merchant configuration
  Future<MerchantConfigDto> updateConfiguration(UpdateMerchantConfigDto updateDto) async {
    try {
      debugPrint('[MerchantConfigService] Updating merchant configuration...');
      final response = await _api.patchJson(
        '/api/v1/merchant/configuration',
        body: updateDto.toJson(),
      );
      
      final data = response['data'] != null ? response['data'] as Map<String, dynamic> : response;
      final config = MerchantConfigDto.fromJson(data);
      
      debugPrint('[MerchantConfigService] Configuration updated successfully');
      return config;
    } catch (e) {
      debugPrint('[MerchantConfigService] Error updating configuration: $e');
      rethrow;
    }
  }

  /// Verify MTN credentials
  Future<Map<String, dynamic>> verifyMtnCredentials({
    required String subscriptionKey,
    required String apiKey,
    required String xReferenceId,
    String targetEnvironment = 'sandbox',
  }) async {
    try {
      debugPrint('[MerchantConfigService] Verifying MTN credentials...');
      final response = await _api.postJson(
        '/api/v1/merchant/configuration/verify/mtn',
        body: {
          'subscriptionKey': subscriptionKey,
          'apiKey': apiKey,
          'xReferenceId': xReferenceId,
          'targetEnvironment': targetEnvironment,
        },
      );
      
      debugPrint('[MerchantConfigService] MTN credentials verified');
      return response;
    } catch (e) {
      debugPrint('[MerchantConfigService] Error verifying MTN credentials: $e');
      rethrow;
    }
  }

  /// Verify Airtel credentials
  Future<Map<String, dynamic>> verifyAirtelCredentials({
    required String clientId,
    required String clientSecret,
    required String signingSecret,
    String environment = 'staging',
  }) async {
    try {
      debugPrint('[MerchantConfigService] Verifying Airtel credentials...');
      final response = await _api.postJson(
        '/api/v1/merchant/configuration/verify/airtel',
        body: {
          'clientId': clientId,
          'clientSecret': clientSecret,
          'signingSecret': signingSecret,
          'environment': environment,
        },
      );
      
      debugPrint('[MerchantConfigService] Airtel credentials verified');
      return response;
    } catch (e) {
      debugPrint('[MerchantConfigService] Error verifying Airtel credentials: $e');
      rethrow;
    }
  }

  /// Verify bank account
  Future<Map<String, dynamic>> verifyBankAccount({
    required String accountNumber,
    required String bankCode,
    String? accountHolder,
  }) async {
    try {
      debugPrint('[MerchantConfigService] Verifying bank account...');
      final response = await _api.postJson(
        '/api/v1/merchant/configuration/verify/bank',
        body: {
          'accountNumber': accountNumber,
          'bankCode': bankCode,
          if (accountHolder != null) 'accountHolder': accountHolder,
        },
      );
      
      debugPrint('[MerchantConfigService] Bank account verified');
      return response;
    } catch (e) {
      debugPrint('[MerchantConfigService] Error verifying bank account: $e');
      rethrow;
    }
  }

  /// Test webhook endpoint
  Future<Map<String, dynamic>> testWebhook({
    required String eventType,
    Map<String, dynamic>? payload,
  }) async {
    try {
      debugPrint('[MerchantConfigService] Testing webhook with eventType: $eventType');
      final response = await _api.postJson(
        '/api/v1/merchant/configuration/webhook/test',
        body: {
          'eventType': eventType,
          'payload': payload ?? {},
        },
      );
      
      debugPrint('[MerchantConfigService] Webhook test successful: ${response['message']}');
      return response;
    } catch (e) {
      debugPrint('[MerchantConfigService] Error testing webhook: $e');
      rethrow;
    }
  }
}
