import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../dashboard/models/mock_data.dart';
import 'subscription_detail_item.dart';

class SubscriptionCard extends StatelessWidget {
  final MockSub subscription;
  final String currencySymbol;
  final bool isExpanded;
  final VoidCallback onTap;
  final bool showMadeBy;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.currencySymbol,
    required this.isExpanded,
    required this.onTap,
    this.showMadeBy = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final bool isOverdue = subscription.due.toLowerCase().contains('overdue');
    final String paymentType = isOverdue ? 'Manual' : 'Auto-pay';
    const String billingCycle = 'Monthly';

    return Card(
      color: theme.cardTheme.color ?? colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: isExpanded ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isExpanded
            ? BorderSide(color: colorScheme.primary.withValues(alpha: 0.3), width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      subscription.icon,
                      color: subscription.statusColor,
                    ),
                  ),
                  title: Text(
                    subscription.name,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      subscription.due,
                      style: textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(subscription.due),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatCurrency(subscription.price, currencySymbol),
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subscription.category,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: colorScheme.onSurface.withValues(alpha: 0.54),
                        size: 20,
                      ),
                    ],
                  ),
                ),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 8.0,
                      top: 4.0,
                    ),
                    child: Column(
                      children: [
                        Divider(
                          color: colorScheme.onSurface.withValues(alpha: 0.12),
                          height: 24,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: showMadeBy
                              ? Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: SubscriptionDetailItem(
                                            label: 'Billing Cycle',
                                            value: billingCycle,
                                            icon: Icons.calendar_month_outlined,
                                          ),
                                        ),
                                        Expanded(
                                          child: SubscriptionDetailItem(
                                            label: 'Payment Type',
                                            value: paymentType,
                                            icon: Icons.payment_outlined,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: SubscriptionDetailItem(
                                            label: 'Date',
                                            value: subscription.purchaseDate,
                                            icon:
                                                Icons.event_available_outlined,
                                          ),
                                        ),
                                        Expanded(
                                          child: SubscriptionDetailItem(
                                            label: 'Made By:',
                                            value: subscription.madeBy,
                                            icon: Icons.person_outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SubscriptionDetailItem(
                                        label: 'Billing Cycle',
                                        value: billingCycle,
                                        icon: Icons.calendar_month_outlined,
                                      ),
                                    ),
                                    Expanded(
                                      child: SubscriptionDetailItem(
                                        label: 'Payment Type',
                                        value: paymentType,
                                        icon: Icons.payment_outlined,
                                      ),
                                    ),
                                    Expanded(
                                      child: SubscriptionDetailItem(
                                        label: 'Date',
                                        value: subscription.purchaseDate,
                                        icon: Icons.event_available_outlined,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String due) {
    final status = due.toLowerCase();

    if (status.contains('paid')) return Colors.greenAccent;
    if (status.contains('overdue')) return Colors.redAccent;

    if (status.contains('due')) {
      if (status.contains('today') || status.contains('tomorrow')) {
        return Colors.yellow;
      }

      final match = RegExp(r'due in (\d+) day').firstMatch(status);
      if (match != null) {
        final days = int.tryParse(match.group(1) ?? '');
        if (days != null && days <= 3) {
          return Colors.yellow;
        }
      }
    }

    return Colors.white;
  }
}
