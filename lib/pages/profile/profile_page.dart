import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wanderlog/data/payment_gateway_service.dart';
import 'package:wanderlog/domain/models.dart';
import 'package:wanderlog/nav.dart';
import 'package:wanderlog/theme.dart';
import 'package:wanderlog/utils/currency_formatter.dart';
import 'package:wanderlog/widgets/common.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final PaymentGatewayService _service = PaymentGatewayService();

  MerchantAccount? _account;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final acct = await _service.getMerchantAccount();
      if (!mounted) return;
      setState(() {
        _account = acct;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Profile load failed: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load profile.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: Icon(Icons.refresh_rounded, color: cs.onSurface),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: _load,
          child: ListView(
            padding: AppSpacing.paddingMd,
            children: [
              if (_loading) const SizedBox(height: 260, child: AppLoadingState(label: 'Loading profile…')),
              if (!_loading && _error != null)
                AppEmptyState(
                  title: 'Couldn\'t load profile',
                  message: _error!,
                  icon: Icons.cloud_off_rounded,
                  actionLabel: 'Try again',
                  onAction: _load,
                ),
              if (!_loading && _error == null && _account != null) ...[
                _ProfileHero(account: _account!, isConfigured: _service.isConfigured),
                const SizedBox(height: AppSpacing.lg),
                _QuickLinks(
                  onPayouts: () => context.go(AppRoutes.disbursements),
                  onAlerts: () => context.go(AppRoutes.alerts),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Account', style: context.textStyles.titleLarge),
                const SizedBox(height: AppSpacing.md),
                AppSectionCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingTile(
                        icon: Icons.storefront_outlined,
                        title: 'Merchant',
                        subtitle: _account!.name,
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => _MerchantDetailsSheet(account: _account!, isConfigured: _service.isConfigured),
                        ),
                      ),
                      _DividerLine(),
                      _SettingTile(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Available balance',
                        subtitle: CurrencyFormatter.format(_account!.balance.available, _account!.currency),
                      ),
                      _DividerLine(),
                      _SettingTile(
                        icon: Icons.access_time_rounded,
                        title: 'Pending balance',
                        subtitle: CurrencyFormatter.format(_account!.balance.pending, _account!.currency),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('System', style: context.textStyles.titleLarge),
                const SizedBox(height: AppSpacing.md),
                AppSectionCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingTile(
                        icon: Icons.link_rounded,
                        title: 'Payment gateway',
                        subtitle: _service.isConfigured ? 'Configured via environment' : 'Using mock fallback',
                        trailing: Icon(Icons.circle, size: 12, color: _service.isConfigured ? AppColors.success : AppColors.warning),
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => const _GatewayInfoSheet(),
                        ),
                      ),
                      _DividerLine(),
                      _SettingTile(
                        icon: Icons.cloud_rounded,
                        title: 'Backend (Firebase / Supabase)',
                        subtitle: 'Not connected in this project',
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => const _BackendInfoSheet(),
                        ),
                      ),
                      _DividerLine(),
                      _SettingTile(
                        icon: Icons.info_outline_rounded,
                        title: 'App version',
                        subtitle: '1.0.0',
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.account, required this.isConfigured});

  final MerchantAccount account;
  final bool isConfigured;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.name, style: context.textStyles.titleLarge?.withColor(Colors.white)),
                const SizedBox(height: 6),
                Text(
                  isConfigured ? 'Live gateway configured' : 'Running on mock data',
                  style: context.textStyles.bodyMedium?.withColor(Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks({required this.onPayouts, required this.onAlerts});

  final VoidCallback onPayouts;
  final VoidCallback onAlerts;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppSectionCard(
            onTap: onPayouts,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.action.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.payments_rounded, color: AppColors.action),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payouts', style: context.textStyles.titleSmall?.semiBold),
                      const SizedBox(height: 4),
                      Text('Create & track disbursements', style: context.textStyles.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppSectionCard(
            onTap: onAlerts,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.notifications_rounded, color: AppColors.info),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alerts', style: context.textStyles.titleSmall?.semiBold),
                      const SizedBox(height: 4),
                      Text('Risk, payout, system signals', style: context.textStyles.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: cs.primary),
      ),
      title: Text(title, style: context.textStyles.titleSmall?.semiBold),
      subtitle: Text(subtitle, style: context.textStyles.bodySmall),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: Theme.of(context).dividerTheme.color?.withValues(alpha: 0.6));
  }
}

class _MerchantDetailsSheet extends StatelessWidget {
  const _MerchantDetailsSheet({required this.account, required this.isConfigured});

  final MerchantAccount account;
  final bool isConfigured;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(AppRadius.xl), topRight: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Merchant details', style: context.textStyles.headlineSmall),
                  const Spacer(),
                  IconButton(onPressed: () => context.pop(), icon: Icon(Icons.close_rounded, color: cs.onSurface)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSectionCard(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.name, style: context.textStyles.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Merchant ID: ${account.id}', style: context.textStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Currency: ${account.currency}', style: context.textStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Gateway: ${isConfigured ? 'Configured' : 'Mock fallback'}', style: context.textStyles.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _GatewayInfoSheet extends StatelessWidget {
  const _GatewayInfoSheet();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(AppRadius.xl), topRight: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Payment gateway', style: context.textStyles.headlineSmall),
                  const Spacer(),
                  IconButton(onPressed: () => context.pop(), icon: Icon(Icons.close_rounded, color: cs.onSurface)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'This MVP can talk to a payment gateway API when configured with runtime environment variables. '
                'When not configured, it automatically falls back to local mock data so your UI remains fully usable in Dreamflow.',
                style: context.textStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Used variables', style: context.textStyles.titleSmall?.semiBold),
                    const SizedBox(height: AppSpacing.sm),
                    Text('PAYMENT_GATEWAY_BASE_URL', style: context.textStyles.bodyMedium),
                    Text('PAYMENT_GATEWAY_TENANT_ID', style: context.textStyles.bodyMedium),
                    Text('PAYMENT_GATEWAY_API_KEY', style: context.textStyles.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackendInfoSheet extends StatelessWidget {
  const _BackendInfoSheet();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(AppRadius.xl), topRight: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Backend connection', style: context.textStyles.headlineSmall),
                  const Spacer(),
                  IconButton(onPressed: () => context.pop(), icon: Icon(Icons.close_rounded, color: cs.onSurface)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No backend is connected right now. If you want Firebase or Supabase features (auth, database, push notifications), '
                'open the Firebase (or Supabase) panel in Dreamflow and complete setup there.',
                style: context.textStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dreamflow steps', style: context.textStyles.titleSmall?.semiBold),
                    const SizedBox(height: AppSpacing.sm),
                    Text('1) Open Firebase or Supabase panel', style: context.textStyles.bodyMedium),
                    Text('2) Sign in and select a project', style: context.textStyles.bodyMedium),
                    Text('3) Complete Project Setup', style: context.textStyles.bodyMedium),
                    Text('4) Ask me to add auth / database screens', style: context.textStyles.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
