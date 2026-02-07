import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wanderlog/data/payment_gateway_service.dart';
import 'package:wanderlog/domain/models.dart';
import 'package:wanderlog/nav.dart';
import 'package:wanderlog/theme.dart';
import 'package:wanderlog/utils/currency_formatter.dart';
import 'package:wanderlog/widgets/common.dart';

enum DisbursementFilter { all, payouts, refunds, failed }

class DisbursementsPage extends StatefulWidget {
  const DisbursementsPage({super.key});

  @override
  State<DisbursementsPage> createState() => _DisbursementsPageState();
}

class _DisbursementsPageState extends State<DisbursementsPage> {
  late PaymentGatewayService _service;
  MerchantAccount? _account;
  List<Transaction> _all = const [];
  bool _loading = true;
  String? _error;
  DisbursementFilter _filter = DisbursementFilter.all;

  @override
  void initState() {
    super.initState();
    _service = context.read<PaymentGatewayService>();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final account = await _service.getMerchantAccount();
      final tx = await _service.getTransactions();
      if (!mounted) return;
      setState(() {
        _account = account;
        _all = tx;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Disbursements load failed: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load payouts.';
      });
    }
  }

  List<Transaction> get _filtered {
    final payouts =
        _all.where((t) => t.type == TransactionType.payout).toList();
    final refunds =
        _all.where((t) => t.type == TransactionType.refund).toList();
    final failed =
        _all.where((t) => t.status == TransactionStatus.failed).toList();

    return switch (_filter) {
      DisbursementFilter.all => _all,
      DisbursementFilter.payouts => payouts,
      DisbursementFilter.refunds => refunds,
      DisbursementFilter.failed => failed,
    };
  }

  double get _payoutsTotal {
    final payouts = _all.where((t) => t.type == TransactionType.payout);
    return payouts.fold<double>(0, (sum, t) => sum + t.amount.abs());
  }

  Future<void> _openCreatePayout() async {
    if (_account == null) return;

    final created = await showModalBottomSheet<Transaction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          CreatePayoutSheet(account: _account!, service: _service),
    );

    if (created != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Payout created'),
          backgroundColor: AppColors.success,
        ),
      );
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disbursements'),
        actions: [
          IconButton(
            tooltip: 'Alerts',
            onPressed: () => context.go(AppRoutes.alerts),
            icon: Icon(Icons.notifications_outlined, color: cs.onSurface),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: Icon(Icons.refresh_rounded, color: cs.onSurface),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _openCreatePayout,
        backgroundColor: AppColors.action,
        icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
        label: const Text('New payout', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: _load,
          child: ListView(
            padding: AppSpacing.paddingMd,
            children: [
              _SummaryHeader(
                currency: _account?.currency ?? 'USD',
                available: _account?.balance.available,
                pending: _account?.balance.pending,
                payoutsTotal: _payoutsTotal,
                isConfigured: _service.isConfigured,
              ),
              const SizedBox(height: AppSpacing.lg),
              _FilterBar(
                  value: _filter,
                  onChanged: (v) => setState(() => _filter = v)),
              const SizedBox(height: AppSpacing.lg),
              if (_loading)
                const SizedBox(
                    height: 260,
                    child: AppLoadingState(label: 'Loading activity…')),
              if (!_loading && _error != null)
                AppEmptyState(
                  title: 'Couldn\'t load payouts',
                  message: _error!,
                  icon: Icons.cloud_off_rounded,
                  actionLabel: 'Try again',
                  onAction: _load,
                ),
              if (!_loading && _error == null)
                if (_filtered.isEmpty)
                  AppEmptyState(
                    title: 'No disbursements',
                    message: 'Create your first payout to start moving funds.',
                    icon: Icons.payments_outlined,
                    actionLabel: 'New payout',
                    onAction: _openCreatePayout,
                  )
                else
                  ..._filtered.map(
                    (tx) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: TransactionListItem(
                        tx: tx,
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => _TransactionDetailsSheet(tx: tx),
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.currency,
    required this.available,
    required this.pending,
    required this.payoutsTotal,
    required this.isConfigured,
  });

  final String currency;
  final double? available;
  final double? pending;
  final double payoutsTotal;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Payouts',
                  style:
                      context.textStyles.titleLarge?.withColor(Colors.white)),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.16)),
                ),
                child: Text(
                  isConfigured ? 'Gateway connected' : 'Mock data',
                  style: context.textStyles.labelSmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            CurrencyFormatter.format(payoutsTotal, currency),
            style: context.textStyles.displaySmall?.withColor(Colors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Total payouts (all time)',
            style: context.textStyles.bodyMedium
                ?.withColor(Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricPill(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Available',
                value: available == null
                    ? '—'
                    : CurrencyFormatter.format(available!, currency),
              ),
              _MetricPill(
                icon: Icons.access_time_rounded,
                label: 'Pending',
                value: pending == null
                    ? '—'
                    : CurrencyFormatter.format(pending!, currency),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.92), size: 18),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: context.textStyles.labelSmall
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.80))),
              const SizedBox(height: 2),
              Text(value,
                  style: context.textStyles.titleSmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.value, required this.onChanged});

  final DisbursementFilter value;
  final ValueChanged<DisbursementFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SegmentedButton<DisbursementFilter>(
          selected: {value},
          onSelectionChanged: (s) {
            if (s.isEmpty) return;
            onChanged(s.first);
          },
          segments: const [
            ButtonSegment(
                value: DisbursementFilter.all,
                label: Text('All'),
                icon: Icon(Icons.list_rounded)),
            ButtonSegment(
                value: DisbursementFilter.payouts,
                label: Text('Payouts'),
                icon: Icon(Icons.arrow_upward_rounded)),
            ButtonSegment(
                value: DisbursementFilter.refunds,
                label: Text('Refunds'),
                icon: Icon(Icons.undo_rounded)),
            ButtonSegment(
                value: DisbursementFilter.failed,
                label: Text('Failed'),
                icon: Icon(Icons.error_outline_rounded)),
          ],
          showSelectedIcon: false,
          style: ButtonStyle(
            visualDensity: VisualDensity.standard,
            padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg)),
            ),
          ),
        );
      },
    );
  }
}

class CreatePayoutSheet extends StatefulWidget {
  const CreatePayoutSheet(
      {super.key, required this.account, required this.service});

  final MerchantAccount account;
  final PaymentGatewayService service;

  @override
  State<CreatePayoutSheet> createState() => _CreatePayoutSheetState();
}

class _CreatePayoutSheetState extends State<CreatePayoutSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _destCtrl = TextEditingController(text: 'Bank Transfer');
  final _noteCtrl = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _destCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final rawAmount = _amountCtrl.text.trim().replaceAll(',', '');
    final amount = double.tryParse(rawAmount);
    if (amount == null || amount <= 0) return;

    setState(() => _submitting = true);
    try {
      final tx = await widget.service.createPayout(
        amount: amount,
        currency: widget.account.currency,
        destinationLabel: _destCtrl.text.trim(),
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
      if (!mounted) return;
      context.pop(tx);
    } catch (e) {
      debugPrint('Create payout failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Could not create payout'),
            backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('New payout',
                          style: context.textStyles.headlineSmall),
                      const Spacer(),
                      IconButton(
                        onPressed: _submitting ? null : () => context.pop(),
                        icon: Icon(Icons.close_rounded, color: cs.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Available: ${CurrencyFormatter.format(widget.account.balance.available, widget.account.currency)}',
                    style: context.textStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount (${widget.account.currency})',
                      prefixIcon:
                          Icon(Icons.attach_money_rounded, color: cs.primary),
                      filled: true,
                      fillColor: cs.primary.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide.none),
                    ),
                    validator: (v) {
                      final s = (v ?? '').trim().replaceAll(',', '');
                      final amt = double.tryParse(s);
                      if (amt == null || amt <= 0)
                        return 'Enter a valid amount';
                      if (amt > widget.account.balance.available)
                        return 'Amount exceeds available balance';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _destCtrl,
                    decoration: InputDecoration(
                      labelText: 'Destination',
                      prefixIcon: Icon(Icons.account_balance_rounded,
                          color: cs.primary),
                      filled: true,
                      fillColor: cs.primary.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide.none),
                    ),
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? 'Destination required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _noteCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Note (optional)',
                      prefixIcon:
                          Icon(Icons.sticky_note_2_outlined, color: cs.primary),
                      filled: true,
                      fillColor: cs.primary.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitting ? null : _submit,
                      icon: const Icon(Icons.arrow_upward_rounded,
                          color: Colors.white),
                      label: Text(_submitting ? 'Creating…' : 'Create payout',
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionDetailsSheet extends StatelessWidget {
  const _TransactionDetailsSheet({required this.tx});

  final Transaction tx;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl)),
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
                  Text('Details', style: context.textStyles.headlineSmall),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.close_rounded, color: cs.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSectionCard(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx.counterparty, style: context.textStyles.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Reference: ${tx.reference}',
                        style: context.textStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Status: ${tx.status.name}',
                        style: context.textStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Type: ${tx.type.name}',
                        style: context.textStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text('When: ${tx.timestamp}',
                        style: context.textStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      CurrencyFormatter.format(tx.amount, tx.currency),
                      style: context.textStyles.displaySmall
                          ?.copyWith(color: cs.primary),
                    ),
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
