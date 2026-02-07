import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wanderlog/data/payment_gateway_service.dart';
import 'package:wanderlog/domain/models.dart';
import 'package:wanderlog/theme.dart';
import 'package:wanderlog/widgets/common.dart';

enum AlertsFilter { all, unread }

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  late PaymentGatewayService _service;
  bool _loading = true;
  String? _error;
  List<Alert> _alerts = const [];
  AlertsFilter _filter = AlertsFilter.all;

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
      final items = await _service.getAlerts();
      if (!mounted) return;
      setState(() {
        _alerts = items;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Alerts load failed: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load alerts.';
      });
    }
  }

  List<Alert> get _filtered {
    return switch (_filter) {
      AlertsFilter.all => _alerts,
      AlertsFilter.unread => _alerts.where((a) => !a.isRead).toList(),
    };
  }

  int get _unreadCount => _alerts.where((a) => !a.isRead).length;

  Future<void> _toggleRead(Alert a) async {
    final next = !a.isRead;
    try {
      await _service.markAlertRead(a.id, next);
      await _load();
    } catch (e) {
      debugPrint('Toggle alert read failed: $e');
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _service.markAllAlertsRead();
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('All alerts marked as read'),
            backgroundColor: AppColors.success),
      );
    } catch (e) {
      debugPrint('Mark all read failed: $e');
    }
  }

  Future<void> _delete(Alert a) async {
    try {
      await _service.deleteAlert(a.id);
      await _load();
    } catch (e) {
      debugPrint('Delete alert failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _loading ? null : _markAllRead,
              child: Text('Mark all read',
                  style: TextStyle(
                      color: cs.primary, fontWeight: FontWeight.w700)),
            ),
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
              _AlertsHeader(
                  unreadCount: _unreadCount,
                  filter: _filter,
                  onFilterChanged: (v) => setState(() => _filter = v)),
              const SizedBox(height: AppSpacing.lg),
              if (_loading)
                const SizedBox(
                    height: 240,
                    child: AppLoadingState(label: 'Loading alerts…')),
              if (!_loading && _error != null)
                AppEmptyState(
                  title: 'Couldn\'t load alerts',
                  message: _error!,
                  icon: Icons.cloud_off_rounded,
                  actionLabel: 'Try again',
                  onAction: _load,
                ),
              if (!_loading && _error == null)
                if (_filtered.isEmpty)
                  AppEmptyState(
                    title: _filter == AlertsFilter.unread
                        ? 'You\'re all caught up'
                        : 'No alerts',
                    message: _filter == AlertsFilter.unread
                        ? 'Nothing new right now. We\'ll notify you when something needs attention.'
                        : 'Alerts about payouts, risk, and system events will appear here.',
                    icon: Icons.notifications_none_rounded,
                  )
                else
                  ..._filtered.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Dismissible(
                        key: ValueKey(a.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.22)),
                          ),
                          child: const Icon(Icons.delete_outline_rounded,
                              color: AppColors.error),
                        ),
                        onDismissed: (_) => _delete(a),
                        child:
                            _AlertCard(alert: a, onTap: () => _toggleRead(a)),
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

class _AlertsHeader extends StatelessWidget {
  const _AlertsHeader(
      {required this.unreadCount,
      required this.filter,
      required this.onFilterChanged});

  final int unreadCount;
  final AlertsFilter filter;
  final ValueChanged<AlertsFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppSectionCard(
      padding: AppSpacing.paddingLg,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(Icons.notifications_rounded, color: cs.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Inbox', style: context.textStyles.titleLarge),
                const SizedBox(height: 4),
                Text('$unreadCount unread',
                    style: context.textStyles.bodySmall),
              ],
            ),
          ),
          SegmentedButton<AlertsFilter>(
            selected: {filter},
            onSelectionChanged: (s) {
              if (s.isEmpty) return;
              onFilterChanged(s.first);
            },
            segments: const [
              ButtonSegment(value: AlertsFilter.all, label: Text('All')),
              ButtonSegment(value: AlertsFilter.unread, label: Text('Unread')),
            ],
            showSelectedIcon: false,
            style: ButtonStyle(
              padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999))),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert, required this.onTap});

  final Alert alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final time = DateFormat('MMM d, h:mm a').format(alert.timestamp);

    final bg = alert.isRead ? cs.surface : cs.primary.withValues(alpha: 0.06);
    final border = alert.isRead
        ? (Theme.of(context).dividerTheme.color?.withValues(alpha: 0.55) ??
            Colors.transparent)
        : cs.primary.withValues(alpha: 0.16);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Ink(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: border),
        ),
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(_iconFor(alert.severity),
                    color: _colorFor(alert.severity)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(alert.title,
                                style:
                                    context.textStyles.titleSmall?.semiBold)),
                        const SizedBox(width: AppSpacing.sm),
                        SeverityPill(severity: alert.severity),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(alert.message, style: context.textStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 16,
                            color: cs.onSurface.withValues(alpha: 0.6)),
                        const SizedBox(width: 6),
                        Text(time, style: context.textStyles.bodySmall),
                        const Spacer(),
                        Text(
                          alert.isRead ? 'Read' : 'Unread',
                          style: context.textStyles.labelSmall?.copyWith(
                            color: alert.isRead
                                ? cs.onSurface.withValues(alpha: 0.55)
                                : cs.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(AlertSeverity s) {
    return switch (s) {
      AlertSeverity.low => Icons.info_outline_rounded,
      AlertSeverity.medium => Icons.warning_amber_rounded,
      AlertSeverity.high => Icons.report_problem_outlined,
      AlertSeverity.critical => Icons.gpp_bad_outlined,
    };
  }

  Color _colorFor(AlertSeverity s) {
    return switch (s) {
      AlertSeverity.low => AppColors.info,
      AlertSeverity.medium => AppColors.warning,
      AlertSeverity.high => AppColors.action,
      AlertSeverity.critical => AppColors.error,
    };
  }
}
