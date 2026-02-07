/// Data Transfer Objects for merchant configuration

class MerchantConfigDto {
  final String id;
  final String tenantId;
  final String businessName;
  final String? businessRegistrationNumber;
  final String? taxId;
  final String? businessCategory;
  final String? websiteUrl;
  final String? businessAddress;
  final String? contactPersonName;
  final String? contactPersonPhone;
  final String? contactPersonEmail;
  
  // MTN Credentials
  final String? mtnCollectionSubscriptionKey;
  final String? mtnCollectionApiKey;
  final String? mtnCollectionXReferenceId;
  final String mtnCollectionTargetEnvironment;
  final String? mtnDisbursementSubscriptionKey;
  final String? mtnDisbursementApiKey;
  final String? mtnDisbursementXReferenceId;
  final String mtnDisbursementTargetEnvironment;
  final String? mtnAccountHolder;
  final bool mtnAccountActive;
  final DateTime? mtnLastVerified;
  
  // Airtel Credentials
  final String? airtelClientId;
  final String? airtelClientSecret;
  final String? airtelSigningSecret;
  final String? airtelEncryptionPublicKey;
  final String airtelEnvironment;
  final String airtelCountry;
  final String airtelCurrency;
  final String? airtelMerchantId;
  final bool airtelAccountActive;
  final DateTime? airtelLastVerified;
  
  // Bank Account
  final String? bankAccountHolder;
  final String? bankAccountNumber;
  final String? bankAccountType;
  final String? bankName;
  final String? bankBranchCode;
  final String? bankSwiftCode;
  final String bankAccountCurrency;
  final bool bankAccountVerified;
  final DateTime? bankAccountVerifiedDate;
  
  // KYC
  final String kycStatus;
  final DateTime? kycSubmittedDate;
  final DateTime? kycVerifiedDate;
  final String? kycRejectionReason;
  final String? directorName;
  final String? directorIdNumber;
  final String? directorIdType;
  final String? beneficialOwnerInfo;
  final String? complianceNotes;
  
  // Webhook
  final String? webhookUrl;
  final String? webhookSecret;
  final List<String> webhookEvents;
  final bool webhookEnabled;
  final DateTime? webhookLastTested;
  
  // Encryption
  final String encryptionStatus;
  final int encryptionKeyVersion;
  final DateTime? credentialsRotatedDate;
  
  // Rate Limits
  final int maxDailyCollections;
  final double? maxDailyDisbursementAmount;
  final double? maxTransactionAmount;
  final double? approvalThresholdAmount;
  
  // Audit
  final String? notes;
  final bool isActive;
  final String? lastUpdatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  MerchantConfigDto({
    required this.id,
    required this.tenantId,
    required this.businessName,
    this.businessRegistrationNumber,
    this.taxId,
    this.businessCategory,
    this.websiteUrl,
    this.businessAddress,
    this.contactPersonName,
    this.contactPersonPhone,
    this.contactPersonEmail,
    this.mtnCollectionSubscriptionKey,
    this.mtnCollectionApiKey,
    this.mtnCollectionXReferenceId,
    this.mtnCollectionTargetEnvironment = 'sandbox',
    this.mtnDisbursementSubscriptionKey,
    this.mtnDisbursementApiKey,
    this.mtnDisbursementXReferenceId,
    this.mtnDisbursementTargetEnvironment = 'sandbox',
    this.mtnAccountHolder,
    this.mtnAccountActive = false,
    this.mtnLastVerified,
    this.airtelClientId,
    this.airtelClientSecret,
    this.airtelSigningSecret,
    this.airtelEncryptionPublicKey,
    this.airtelEnvironment = 'staging',
    this.airtelCountry = 'ZM',
    this.airtelCurrency = 'ZMW',
    this.airtelMerchantId,
    this.airtelAccountActive = false,
    this.airtelLastVerified,
    this.bankAccountHolder,
    this.bankAccountNumber,
    this.bankAccountType,
    this.bankName,
    this.bankBranchCode,
    this.bankSwiftCode,
    this.bankAccountCurrency = 'ZMW',
    this.bankAccountVerified = false,
    this.bankAccountVerifiedDate,
    this.kycStatus = 'PENDING',
    this.kycSubmittedDate,
    this.kycVerifiedDate,
    this.kycRejectionReason,
    this.directorName,
    this.directorIdNumber,
    this.directorIdType,
    this.beneficialOwnerInfo,
    this.complianceNotes,
    this.webhookUrl,
    this.webhookSecret,
    this.webhookEvents = const [],
    this.webhookEnabled = true,
    this.webhookLastTested,
    this.encryptionStatus = 'UNENCRYPTED',
    this.encryptionKeyVersion = 1,
    this.credentialsRotatedDate,
    this.maxDailyCollections = 10000,
    this.maxDailyDisbursementAmount,
    this.maxTransactionAmount,
    this.approvalThresholdAmount,
    this.notes,
    this.isActive = true,
    this.lastUpdatedBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory MerchantConfigDto.fromJson(Map<String, dynamic> json) {
    return MerchantConfigDto(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      businessName: json['businessName'] as String,
      businessRegistrationNumber: json['businessRegistrationNumber'] as String?,
      taxId: json['taxId'] as String?,
      businessCategory: json['businessCategory'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      businessAddress: json['businessAddress'] as String?,
      contactPersonName: json['contactPersonName'] as String?,
      contactPersonPhone: json['contactPersonPhone'] as String?,
      contactPersonEmail: json['contactPersonEmail'] as String?,
      mtnCollectionSubscriptionKey: json['mtnCollectionSubscriptionKey'] as String?,
      mtnCollectionApiKey: json['mtnCollectionApiKey'] as String?,
      mtnCollectionXReferenceId: json['mtnCollectionXReferenceId'] as String?,
      mtnCollectionTargetEnvironment: json['mtnCollectionTargetEnvironment'] as String? ?? 'sandbox',
      mtnDisbursementSubscriptionKey: json['mtnDisbursementSubscriptionKey'] as String?,
      mtnDisbursementApiKey: json['mtnDisbursementApiKey'] as String?,
      mtnDisbursementXReferenceId: json['mtnDisbursementXReferenceId'] as String?,
      mtnDisbursementTargetEnvironment: json['mtnDisbursementTargetEnvironment'] as String? ?? 'sandbox',
      mtnAccountHolder: json['mtnAccountHolder'] as String?,
      mtnAccountActive: json['mtnAccountActive'] as bool? ?? false,
      mtnLastVerified: json['mtnLastVerified'] != null ? DateTime.parse(json['mtnLastVerified'] as String) : null,
      airtelClientId: json['airtelClientId'] as String?,
      airtelClientSecret: json['airtelClientSecret'] as String?,
      airtelSigningSecret: json['airtelSigningSecret'] as String?,
      airtelEncryptionPublicKey: json['airtelEncryptionPublicKey'] as String?,
      airtelEnvironment: json['airtelEnvironment'] as String? ?? 'staging',
      airtelCountry: json['airtelCountry'] as String? ?? 'ZM',
      airtelCurrency: json['airtelCurrency'] as String? ?? 'ZMW',
      airtelMerchantId: json['airtelMerchantId'] as String?,
      airtelAccountActive: json['airtelAccountActive'] as bool? ?? false,
      airtelLastVerified: json['airtelLastVerified'] != null ? DateTime.parse(json['airtelLastVerified'] as String) : null,
      bankAccountHolder: json['bankAccountHolder'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankAccountType: json['bankAccountType'] as String?,
      bankName: json['bankName'] as String?,
      bankBranchCode: json['bankBranchCode'] as String?,
      bankSwiftCode: json['bankSwiftCode'] as String?,
      bankAccountCurrency: json['bankAccountCurrency'] as String? ?? 'ZMW',
      bankAccountVerified: json['bankAccountVerified'] as bool? ?? false,
      bankAccountVerifiedDate: json['bankAccountVerifiedDate'] != null ? DateTime.parse(json['bankAccountVerifiedDate'] as String) : null,
      kycStatus: json['kycStatus'] as String? ?? 'PENDING',
      kycSubmittedDate: json['kycSubmittedDate'] != null ? DateTime.parse(json['kycSubmittedDate'] as String) : null,
      kycVerifiedDate: json['kycVerifiedDate'] != null ? DateTime.parse(json['kycVerifiedDate'] as String) : null,
      kycRejectionReason: json['kycRejectionReason'] as String?,
      directorName: json['directorName'] as String?,
      directorIdNumber: json['directorIdNumber'] as String?,
      directorIdType: json['directorIdType'] as String?,
      beneficialOwnerInfo: json['beneficialOwnerInfo'] as String?,
      complianceNotes: json['complianceNotes'] as String?,
      webhookUrl: json['webhookUrl'] as String?,
      webhookSecret: json['webhookSecret'] as String?,
      webhookEvents: List<String>.from(json['webhookEvents'] as List? ?? []),
      webhookEnabled: json['webhookEnabled'] as bool? ?? true,
      webhookLastTested: json['webhookLastTested'] != null ? DateTime.parse(json['webhookLastTested'] as String) : null,
      encryptionStatus: json['encryptionStatus'] as String? ?? 'UNENCRYPTED',
      encryptionKeyVersion: json['encryptionKeyVersion'] as int? ?? 1,
      credentialsRotatedDate: json['credentialsRotatedDate'] != null ? DateTime.parse(json['credentialsRotatedDate'] as String) : null,
      maxDailyCollections: json['maxDailyCollections'] as int? ?? 10000,
      maxDailyDisbursementAmount: json['maxDailyDisbursementAmount'] != null ? double.parse(json['maxDailyDisbursementAmount'].toString()) : null,
      maxTransactionAmount: json['maxTransactionAmount'] != null ? double.parse(json['maxTransactionAmount'].toString()) : null,
      approvalThresholdAmount: json['approvalThresholdAmount'] != null ? double.parse(json['approvalThresholdAmount'].toString()) : null,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      lastUpdatedBy: json['lastUpdatedBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'businessName': businessName,
      'businessRegistrationNumber': businessRegistrationNumber,
      'taxId': taxId,
      'businessCategory': businessCategory,
      'websiteUrl': websiteUrl,
      'businessAddress': businessAddress,
      'contactPersonName': contactPersonName,
      'contactPersonPhone': contactPersonPhone,
      'contactPersonEmail': contactPersonEmail,
      'mtnCollectionSubscriptionKey': mtnCollectionSubscriptionKey,
      'mtnCollectionApiKey': mtnCollectionApiKey,
      'mtnCollectionXReferenceId': mtnCollectionXReferenceId,
      'mtnCollectionTargetEnvironment': mtnCollectionTargetEnvironment,
      'mtnDisbursementSubscriptionKey': mtnDisbursementSubscriptionKey,
      'mtnDisbursementApiKey': mtnDisbursementApiKey,
      'mtnDisbursementXReferenceId': mtnDisbursementXReferenceId,
      'mtnDisbursementTargetEnvironment': mtnDisbursementTargetEnvironment,
      'mtnAccountHolder': mtnAccountHolder,
      'mtnAccountActive': mtnAccountActive,
      'mtnLastVerified': mtnLastVerified?.toIso8601String(),
      'airtelClientId': airtelClientId,
      'airtelClientSecret': airtelClientSecret,
      'airtelSigningSecret': airtelSigningSecret,
      'airtelEncryptionPublicKey': airtelEncryptionPublicKey,
      'airtelEnvironment': airtelEnvironment,
      'airtelCountry': airtelCountry,
      'airtelCurrency': airtelCurrency,
      'airtelMerchantId': airtelMerchantId,
      'airtelAccountActive': airtelAccountActive,
      'airtelLastVerified': airtelLastVerified?.toIso8601String(),
      'bankAccountHolder': bankAccountHolder,
      'bankAccountNumber': bankAccountNumber,
      'bankAccountType': bankAccountType,
      'bankName': bankName,
      'bankBranchCode': bankBranchCode,
      'bankSwiftCode': bankSwiftCode,
      'bankAccountCurrency': bankAccountCurrency,
      'bankAccountVerified': bankAccountVerified,
      'bankAccountVerifiedDate': bankAccountVerifiedDate?.toIso8601String(),
      'kycStatus': kycStatus,
      'kycSubmittedDate': kycSubmittedDate?.toIso8601String(),
      'kycVerifiedDate': kycVerifiedDate?.toIso8601String(),
      'kycRejectionReason': kycRejectionReason,
      'directorName': directorName,
      'directorIdNumber': directorIdNumber,
      'directorIdType': directorIdType,
      'beneficialOwnerInfo': beneficialOwnerInfo,
      'complianceNotes': complianceNotes,
      'webhookUrl': webhookUrl,
      'webhookSecret': webhookSecret,
      'webhookEvents': webhookEvents,
      'webhookEnabled': webhookEnabled,
      'webhookLastTested': webhookLastTested?.toIso8601String(),
      'encryptionStatus': encryptionStatus,
      'encryptionKeyVersion': encryptionKeyVersion,
      'credentialsRotatedDate': credentialsRotatedDate?.toIso8601String(),
      'maxDailyCollections': maxDailyCollections,
      'maxDailyDisbursementAmount': maxDailyDisbursementAmount,
      'maxTransactionAmount': maxTransactionAmount,
      'approvalThresholdAmount': approvalThresholdAmount,
      'notes': notes,
      'isActive': isActive,
      'lastUpdatedBy': lastUpdatedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}

/// Request/Update DTO for merchant configuration (only editable fields)
class UpdateMerchantConfigDto {
  final String? businessName;
  final String? businessRegistrationNumber;
  final String? taxId;
  final String? businessCategory;
  final String? websiteUrl;
  final String? businessAddress;
  final String? contactPersonName;
  final String? contactPersonPhone;
  final String? contactPersonEmail;
  final String? webhookUrl;
  final List<String>? webhookEvents;
  final bool? webhookEnabled;
  final String? notes;

  UpdateMerchantConfigDto({
    this.businessName,
    this.businessRegistrationNumber,
    this.taxId,
    this.businessCategory,
    this.websiteUrl,
    this.businessAddress,
    this.contactPersonName,
    this.contactPersonPhone,
    this.contactPersonEmail,
    this.webhookUrl,
    this.webhookEvents,
    this.webhookEnabled,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (businessName != null) json['businessName'] = businessName;
    if (businessRegistrationNumber != null) json['businessRegistrationNumber'] = businessRegistrationNumber;
    if (taxId != null) json['taxId'] = taxId;
    if (businessCategory != null) json['businessCategory'] = businessCategory;
    if (websiteUrl != null) json['websiteUrl'] = websiteUrl;
    if (businessAddress != null) json['businessAddress'] = businessAddress;
    if (contactPersonName != null) json['contactPersonName'] = contactPersonName;
    if (contactPersonPhone != null) json['contactPersonPhone'] = contactPersonPhone;
    if (contactPersonEmail != null) json['contactPersonEmail'] = contactPersonEmail;
    if (webhookUrl != null) json['webhookUrl'] = webhookUrl;
    if (webhookEvents != null) json['webhookEvents'] = webhookEvents;
    if (webhookEnabled != null) json['webhookEnabled'] = webhookEnabled;
    if (notes != null) json['notes'] = notes;
    return json;
  }
}
