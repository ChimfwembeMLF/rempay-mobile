import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wanderlog/data/payment_gateway_service.dart';
import 'package:wanderlog/domain/models.dart';
import 'package:wanderlog/nav.dart';
import 'package:wanderlog/theme.dart';
import 'package:wanderlog/utils/currency_formatter.dart';
import 'package:wanderlog/widgets/common.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final PaymentGatewayService _service = PaymentGatewayService();
  
  MerchantAccount? _account;
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final account = await _service.getMerchantAccount();
      final transactions = await _service.getTransactions();
      
      if (mounted) {
        setState(() {
          _account = account;
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Dashboard load failed: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Could not load your dashboard.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: _loadData,
          child: ListView(
            padding: AppSpacing.paddingMd,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.lg),
              if (_isLoading) const SizedBox(height: 220, child: AppLoadingState(label: 'Loading dashboard…')),
              if (!_isLoading && _error != null)
                AppEmptyState(
                  title: 'Something went wrong',
                  message: _error!,
                  icon: Icons.cloud_off_rounded,
                  actionLabel: 'Try again',
                  onAction: _loadData,
                ),
              if (!_isLoading && _error == null && _account != null) ...[
                _buildBalanceCard(),
                const SizedBox(height: AppSpacing.lg),
                _buildQuickActions(),
                const SizedBox(height: AppSpacing.xl),
                _buildRecentTransactionsHeader(),
                const SizedBox(height: AppSpacing.md),
                if (_transactions.isEmpty)
                  const AppEmptyState(
                    title: 'No activity yet',
                    message: 'Once payments or payouts occur, they’ll show up here.',
                    icon: Icons.timeline_rounded,
                  )
                else
                  ..._transactions.take(6).map(
                        (tx) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: TransactionListItem(tx: tx, onTap: () {}),
                        ),
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: context.textStyles.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              _account?.name ?? '—',
              style: context.textStyles.headlineSmall,
            ),
          ],
        ),
        IconButton(
          tooltip: 'Alerts',
          onPressed: () => context.go(AppRoutes.alerts),
          icon: Container(
            padding: AppSpacing.paddingSm,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_outlined, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Balance',
                style: context.textStyles.bodyMedium?.withColor(Colors.white.withValues(alpha: 0.85)),
              ),
              Icon(Icons.account_balance_wallet_outlined, color: Colors.white.withValues(alpha: 0.85)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            CurrencyFormatter.format(_account!.balance.available, _account!.currency),
            style: context.textStyles.displaySmall?.withColor(Colors.white),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time_rounded, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Pending: ${CurrencyFormatter.format(_account!.balance.pending, _account!.currency)}',
                  style: context.textStyles.labelMedium?.withColor(Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          icon: Icons.arrow_upward_rounded,
          label: 'Payout',
          color: AppColors.action,
          onTap: () => context.go(AppRoutes.disbursements),
        ),
        _buildActionButton(
          icon: Icons.payments_rounded,
          label: 'Payouts',
          color: AppColors.primary,
          onTap: () => context.go(AppRoutes.disbursements),
        ),
        _buildActionButton(
          icon: Icons.notifications_rounded,
          label: 'Alerts',
          color: AppColors.secondary,
          onTap: () => context.go(AppRoutes.alerts),
        ),
        _buildActionButton(
          icon: Icons.person_rounded,
          label: 'Profile',
          color: AppColors.secondary,
          onTap: () => context.go(AppRoutes.profile),
        ),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    final bg = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: color.withValues(alpha: 0.14)),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: context.textStyles.labelMedium?.semiBold),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Activity',
          style: context.textStyles.titleLarge,
        ),
        TextButton(
          onPressed: () => context.go(AppRoutes.disbursements),
          child: const Text('See All'),
        ),
      ],
    );
  }
}
