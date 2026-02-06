import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wanderlog/domain/models.dart';
import 'package:wanderlog/theme.dart';
import 'package:wanderlog/utils/currency_formatter.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({super.key, this.label});
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),
          const CircularProgressIndicator(),
          if (label != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(label!, style: context.textStyles.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(icon, color: cs.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: context.textStyles.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(message, style: context.textStyles.bodyMedium, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: Text(actionLabel!, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppSectionCard extends StatelessWidget {
  const AppSectionCard({super.key, required this.child, this.padding, this.onTap});
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerTheme.color?.withValues(alpha: 0.55);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: borderColor ?? Colors.transparent),
        ),
        child: Padding(padding: padding ?? AppSpacing.paddingMd, child: child),
      ),
    );
  }
}

class SeverityPill extends StatelessWidget {
  const SeverityPill({super.key, required this.severity});
  final AlertSeverity severity;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (severity) {
      AlertSeverity.low => ('Low', AppColors.info),
      AlertSeverity.medium => ('Medium', AppColors.warning),
      AlertSeverity.high => ('High', AppColors.action),
      AlertSeverity.critical => ('Critical', AppColors.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: context.textStyles.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({super.key, required this.tx, this.onTap});

  final Transaction tx;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isPositive = tx.amount > 0;
    final isFailed = tx.status == TransactionStatus.failed;

    Color iconColor;
    IconData icon;

    if (isFailed) {
      iconColor = AppColors.error;
      icon = Icons.error_outline_rounded;
    } else if (tx.type == TransactionType.payout) {
      iconColor = AppColors.action;
      icon = Icons.arrow_outward_rounded;
    } else if (tx.type == TransactionType.refund) {
      iconColor = AppColors.warning;
      icon = Icons.undo_rounded;
    } else {
      iconColor = AppColors.success;
      icon = isPositive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    }

    final subtitle = '${DateFormat('MMM d, h:mm a').format(tx.timestamp)} • ${tx.reference}';

    final amountColor = isFailed
        ? AppColors.error
        : (isPositive ? AppColors.success : Theme.of(context).colorScheme.onSurface);

    return AppSectionCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: AppSpacing.paddingSm,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.counterparty, style: context.textStyles.titleSmall?.semiBold),
                const SizedBox(height: 4),
                Text(subtitle, style: context.textStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}${CurrencyFormatter.format(tx.amount, tx.currency)}',
                style: context.textStyles.titleSmall?.semiBold.copyWith(color: amountColor),
              ),
              const SizedBox(height: 4),
              _TransactionStatusPill(status: tx.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionStatusPill extends StatelessWidget {
  const _TransactionStatusPill({required this.status});
  final TransactionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TransactionStatus.completed => ('Completed', AppColors.success),
      TransactionStatus.pending => ('Pending', AppColors.warning),
      TransactionStatus.failed => ('Failed', AppColors.error),
      TransactionStatus.refunded => ('Refunded', AppColors.info),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(label, style: context.textStyles.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}
