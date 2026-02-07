import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderlog/data/merchant_config_dto.dart';
import 'package:wanderlog/data/payment_gateway_api.dart';
import 'package:wanderlog/pages/settings/merchant_config_provider.dart';
import 'package:wanderlog/theme.dart';
import 'package:wanderlog/widgets/common.dart';

class MerchantConfigPage extends StatefulWidget {
  final PaymentGatewayApi api;

  const MerchantConfigPage({super.key, required this.api});

  @override
  State<MerchantConfigPage> createState() => _MerchantConfigPageState();
}

class _MerchantConfigPageState extends State<MerchantConfigPage> {
  @override
  void initState() {
    super.initState();
    // Load configuration when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MerchantConfigProvider>().loadConfiguration();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantConfigProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Merchant Configuration'),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: provider.loading
                    ? null
                    : () => provider.loadConfiguration(),
                icon: Icon(Icons.refresh_rounded,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator.adaptive(
              onRefresh: () => provider.loadConfiguration(),
              child: ListView(
                padding: AppSpacing.paddingMd,
                children: [
                  if (provider.loading)
                    const SizedBox(
                      height: 260,
                      child:
                          AppLoadingState(label: 'Loading configuration…'),
                    ),
                  if (!provider.loading && provider.error != null)
                    AppEmptyState(
                      title: 'Error',
                      message: provider.error!,
                      icon: Icons.error_outline_rounded,
                      actionLabel: 'Try again',
                      onAction: () => provider.loadConfiguration(),
                    ),
                  if (!provider.loading &&
                      provider.error == null &&
                      provider.config != null) ...[
                    Text('Business Information',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.md),
                    _BusinessInfoSection(
                      config: provider.config!,
                      provider: provider,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Payment Providers',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.md),
                    _PaymentProvidersSection(
                      config: provider.config!,
                      provider: provider,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Bank Account',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.md),
                    _BankAccountSection(
                      config: provider.config!,
                      provider: provider,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Webhook Configuration',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.md),
                    _WebhookSection(
                      config: provider.config!,
                      provider: provider,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('KYC Status',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.md),
                    _KycSection(config: provider.config!),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BusinessInfoSection extends StatefulWidget {
  final MerchantConfigDto config;
  final MerchantConfigProvider provider;

  const _BusinessInfoSection({
    required this.config,
    required this.provider,
  });

  @override
  State<_BusinessInfoSection> createState() => _BusinessInfoSectionState();
}

class _BusinessInfoSectionState extends State<_BusinessInfoSection> {
  late TextEditingController _businessNameController;
  late TextEditingController _businessRegController;
  late TextEditingController _taxIdController;
  late TextEditingController _categoryController;
  late TextEditingController _websiteController;
  late TextEditingController _addressController;
  late TextEditingController _contactNameController;
  late TextEditingController _contactPhoneController;
  late TextEditingController _contactEmailController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _businessNameController =
        TextEditingController(text: widget.config.businessName);
    _businessRegController =
        TextEditingController(text: widget.config.businessRegistrationNumber);
    _taxIdController = TextEditingController(text: widget.config.taxId);
    _categoryController =
        TextEditingController(text: widget.config.businessCategory);
    _websiteController =
        TextEditingController(text: widget.config.websiteUrl);
    _addressController =
        TextEditingController(text: widget.config.businessAddress);
    _contactNameController =
        TextEditingController(text: widget.config.contactPersonName);
    _contactPhoneController =
        TextEditingController(text: widget.config.contactPersonPhone);
    _contactEmailController =
        TextEditingController(text: widget.config.contactPersonEmail);
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessRegController.dispose();
    _taxIdController.dispose();
    _categoryController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      setState(() => _saving = true);
      await widget.provider.updateBusinessInfo(
        businessName: _businessNameController.text,
        registrationNumber: _businessRegController.text,
        taxId: _taxIdController.text,
        category: _categoryController.text,
        website: _websiteController.text,
        address: _addressController.text,
        contactName: _contactNameController.text,
        contactPhone: _contactPhoneController.text,
        contactEmail: _contactEmailController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        children: [
          _ConfigTextField(
            label: 'Business Name',
            controller: _businessNameController,
          ),
          const SizedBox(height: AppSpacing.md),
          _ConfigTextField(
            label: 'Registration Number',
            controller: _businessRegController,
          ),
          const SizedBox(height: AppSpacing.md),
          _ConfigTextField(
            label: 'Tax ID',
            controller: _taxIdController,
          ),
          const SizedBox(height: AppSpacing.md),
          _ConfigTextField(
            label: 'Business Category',
            controller: _categoryController,
          ),
          const SizedBox(height: AppSpacing.md),
          _ConfigTextField(
            label: 'Website URL',
            controller: _websiteController,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: AppSpacing.md),
          _ConfigTextField(
            label: 'Business Address',
            controller: _addressController,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.md),
          _ConfigTextField(
            label: 'Contact Person Name',
            controller: _contactNameController,
          ),
          const SizedBox(height: AppSpacing.md),
          _ConfigTextField(
            label: 'Contact Phone',
            controller: _contactPhoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.md),
          _ConfigTextField(
            label: 'Contact Email',
            controller: _contactEmailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentProvidersSection extends StatelessWidget {
  final MerchantConfigDto config;
  final MerchantConfigProvider provider;

  const _PaymentProvidersSection({
    required this.config,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProviderCard(
          name: 'MTN Money',
          isActive: config.mtnAccountActive,
          lastVerified: config.mtnLastVerified,
          onTap: () => _showMtnDialog(context),
        ),
        const SizedBox(height: AppSpacing.md),
        _ProviderCard(
          name: 'Airtel Money',
          isActive: config.airtelAccountActive,
          lastVerified: config.airtelLastVerified,
          onTap: () => _showAirtelDialog(context),
        ),
      ],
    );
  }

  void _showMtnDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _MtnConfigDialog(
        config: config,
        provider: provider,
      ),
    );
  }

  void _showAirtelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _AirtelConfigDialog(
        config: config,
        provider: provider,
      ),
    );
  }
}

class _BankAccountSection extends StatelessWidget {
  final MerchantConfigDto config;
  final MerchantConfigProvider provider;

  const _BankAccountSection({
    required this.config,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config.bankAccountVerified)
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: AppColors.success),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Verified',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.success)),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Not Verified',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.warning)),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          if (config.bankAccountNumber != null) ...[
            _InfoRow('Account Holder', config.bankAccountHolder ?? 'N/A'),
            _InfoRow('Account Number', config.bankAccountNumber ?? 'N/A'),
            _InfoRow('Bank Name', config.bankName ?? 'N/A'),
            _InfoRow('Branch Code', config.bankBranchCode ?? 'N/A'),
            _InfoRow('SWIFT Code', config.bankSwiftCode ?? 'N/A'),
          ] else
            Text('No bank account configured',
                style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () => _showBankDialog(context),
              child: const Text('Configure Bank Account'),
            ),
          ),
        ],
      ),
    );
  }

  void _showBankDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _BankConfigDialog(
        config: config,
        provider: provider,
      ),
    );
  }
}

class _WebhookSection extends StatelessWidget {
  final MerchantConfigDto config;
  final MerchantConfigProvider provider;

  const _WebhookSection({
    required this.config,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                config.webhookEnabled ? Icons.check_circle : Icons.cancel,
                color: config.webhookEnabled ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  config.webhookUrl ?? 'No webhook configured',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          if (config.webhookEvents.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Subscribed Events:',
                style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: config.webhookEvents
                  .map((event) => Chip(label: Text(event)))
                  .toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () => _showWebhookDialog(context),
              child: const Text('Configure Webhook'),
            ),
          ),
        ],
      ),
    );
  }

  void _showWebhookDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _WebhookConfigDialog(
        config: config,
        provider: provider,
      ),
    );
  }
}

class _KycSection extends StatelessWidget {
  final MerchantConfigDto config;

  const _KycSection({required this.config});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getKycStatusColor(config.kycStatus);
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(config.kycStatus,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          if (config.kycSubmittedDate != null) ...[
            const SizedBox(height: AppSpacing.md),
            _InfoRow('Submitted', _formatDate(config.kycSubmittedDate!)),
          ],
          if (config.kycVerifiedDate != null) ...[
            const SizedBox(height: AppSpacing.md),
            _InfoRow('Verified', _formatDate(config.kycVerifiedDate!)),
          ],
          if (config.kycRejectionReason != null) ...[
            const SizedBox(height: AppSpacing.md),
            _InfoRow('Rejection Reason', config.kycRejectionReason!),
          ],
        ],
      ),
    );
  }

  Color _getKycStatusColor(String status) {
    switch (status) {
      case 'VERIFIED':
        return AppColors.success;
      case 'REJECTED':
        return AppColors.error;
      case 'NEEDS_UPDATE':
        return AppColors.warning;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}

// Helper Widgets

class _ConfigTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;

  const _ConfigTextField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final String name;
  final bool isActive;
  final DateTime? lastVerified;
  final VoidCallback onTap;

  const _ProviderCard({
    required this.name,
    required this.isActive,
    this.lastVerified,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            color: isActive ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.bodyMedium),
                if (lastVerified != null)
                  Text(
                    'Last verified: ${_formatDate(lastVerified!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Configuration Dialogs

class _MtnConfigDialog extends StatefulWidget {
  final MerchantConfigDto config;
  final MerchantConfigProvider provider;

  const _MtnConfigDialog({
    required this.config,
    required this.provider,
  });

  @override
  State<_MtnConfigDialog> createState() => _MtnConfigDialogState();
}

class _MtnConfigDialogState extends State<_MtnConfigDialog> {
  late TextEditingController _subscriptionKeyController;
  late TextEditingController _apiKeyController;
  late TextEditingController _xReferenceIdController;
  late TextEditingController _environmentController;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _subscriptionKeyController =
        TextEditingController(text: widget.config.mtnCollectionSubscriptionKey);
    _apiKeyController =
        TextEditingController(text: widget.config.mtnCollectionApiKey);
    _xReferenceIdController =
        TextEditingController(text: widget.config.mtnCollectionXReferenceId);
    _environmentController = TextEditingController(
        text: widget.config.mtnCollectionTargetEnvironment);
  }

  @override
  void dispose() {
    _subscriptionKeyController.dispose();
    _apiKeyController.dispose();
    _xReferenceIdController.dispose();
    _environmentController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    try {
      setState(() => _verifying = true);
      await widget.provider.verifyMtnCredentials(
        subscriptionKey: _subscriptionKeyController.text,
        apiKey: _apiKeyController.text,
        xReferenceId: _xReferenceIdController.text,
        targetEnvironment: _environmentController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('MTN credentials verified')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e')),
        );
      }
    } finally {
      setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('MTN Configuration'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ConfigTextField(
              label: 'Subscription Key',
              controller: _subscriptionKeyController,
            ),
            const SizedBox(height: AppSpacing.md),
            _ConfigTextField(
              label: 'API Key',
              controller: _apiKeyController,
            ),
            const SizedBox(height: AppSpacing.md),
            _ConfigTextField(
              label: 'X-Reference ID',
              controller: _xReferenceIdController,
            ),
            const SizedBox(height: AppSpacing.md),
            _ConfigTextField(
              label: 'Environment',
              controller: _environmentController,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _verifying ? null : _verify,
          child: _verifying
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Verify'),
        ),
      ],
    );
  }
}

class _AirtelConfigDialog extends StatefulWidget {
  final MerchantConfigDto config;
  final MerchantConfigProvider provider;

  const _AirtelConfigDialog({
    required this.config,
    required this.provider,
  });

  @override
  State<_AirtelConfigDialog> createState() => _AirtelConfigDialogState();
}

class _AirtelConfigDialogState extends State<_AirtelConfigDialog> {
  late TextEditingController _clientIdController;
  late TextEditingController _clientSecretController;
  late TextEditingController _signingSecretController;
  late TextEditingController _environmentController;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _clientIdController =
        TextEditingController(text: widget.config.airtelClientId);
    _clientSecretController =
        TextEditingController(text: widget.config.airtelClientSecret);
    _signingSecretController =
        TextEditingController(text: widget.config.airtelSigningSecret);
    _environmentController =
        TextEditingController(text: widget.config.airtelEnvironment);
  }

  @override
  void dispose() {
    _clientIdController.dispose();
    _clientSecretController.dispose();
    _signingSecretController.dispose();
    _environmentController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    try {
      setState(() => _verifying = true);
      await widget.provider.verifyAirtelCredentials(
        clientId: _clientIdController.text,
        clientSecret: _clientSecretController.text,
        signingSecret: _signingSecretController.text,
        environment: _environmentController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Airtel credentials verified')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e')),
        );
      }
    } finally {
      setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Airtel Configuration'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ConfigTextField(
              label: 'Client ID',
              controller: _clientIdController,
            ),
            const SizedBox(height: AppSpacing.md),
            _ConfigTextField(
              label: 'Client Secret',
              controller: _clientSecretController,
            ),
            const SizedBox(height: AppSpacing.md),
            _ConfigTextField(
              label: 'Signing Secret',
              controller: _signingSecretController,
            ),
            const SizedBox(height: AppSpacing.md),
            _ConfigTextField(
              label: 'Environment',
              controller: _environmentController,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _verifying ? null : _verify,
          child: _verifying
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Verify'),
        ),
      ],
    );
  }
}

class _BankConfigDialog extends StatefulWidget {
  final MerchantConfigDto config;
  final MerchantConfigProvider provider;

  const _BankConfigDialog({
    required this.config,
    required this.provider,
  });

  @override
  State<_BankConfigDialog> createState() => _BankConfigDialogState();
}

class _BankConfigDialogState extends State<_BankConfigDialog> {
  late TextEditingController _accountNumberController;
  late TextEditingController _bankCodeController;
  late TextEditingController _accountHolderController;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _accountNumberController =
        TextEditingController(text: widget.config.bankAccountNumber);
    _bankCodeController =
        TextEditingController(text: widget.config.bankBranchCode);
    _accountHolderController =
        TextEditingController(text: widget.config.bankAccountHolder);
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _bankCodeController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    try {
      setState(() => _verifying = true);
      await widget.provider.verifyBankAccount(
        accountNumber: _accountNumberController.text,
        bankCode: _bankCodeController.text,
        accountHolder: _accountHolderController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank account verified')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e')),
        );
      }
    } finally {
      setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bank Account Verification'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ConfigTextField(
              label: 'Account Number',
              controller: _accountNumberController,
            ),
            const SizedBox(height: AppSpacing.md),
            _ConfigTextField(
              label: 'Bank Code',
              controller: _bankCodeController,
            ),
            const SizedBox(height: AppSpacing.md),
            _ConfigTextField(
              label: 'Account Holder',
              controller: _accountHolderController,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _verifying ? null : _verify,
          child: _verifying
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Verify'),
        ),
      ],
    );
  }
}

class _WebhookConfigDialog extends StatefulWidget {
  final MerchantConfigDto config;
  final MerchantConfigProvider provider;

  const _WebhookConfigDialog({
    required this.config,
    required this.provider,
  });

  @override
  State<_WebhookConfigDialog> createState() => _WebhookConfigDialogState();
}

class _WebhookConfigDialogState extends State<_WebhookConfigDialog> {
  late TextEditingController _urlController;
  late TextEditingController _secretController;
  String _selectedEvent = 'payment.success';
  bool _testing = false;
  final List<String> _availableEvents = [
    'payment.success',
    'payment.failed',
    'disbursement.complete',
    'disbursement.failed',
  ];

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.config.webhookUrl);
    _secretController =
        TextEditingController(text: widget.config.webhookSecret);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  Future<void> _testWebhook() async {
    try {
      setState(() => _testing = true);
      await widget.provider.testWebhook(
        eventType: _selectedEvent,
        payload: {},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Webhook test sent successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Webhook test failed: $e')),
        );
      }
    } finally {
      setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Webhook Configuration'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ConfigTextField(
              label: 'Webhook URL',
              controller: _urlController,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: AppSpacing.md),
            _ConfigTextField(
              label: 'Webhook Secret',
              controller: _secretController,
            ),
            const SizedBox(height: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Test Event Type',
                    style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: AppSpacing.sm),
                DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedEvent,
                  items: _availableEvents
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedEvent = v!),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: _testing ? null : _testWebhook,
                child: _testing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Test Event'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
