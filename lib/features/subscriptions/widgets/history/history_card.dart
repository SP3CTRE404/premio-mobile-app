// In lib/features/subscriptions/widgets/history/history_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../models/subscription_model.dart';
import '../../utils/subscription_ui_helper.dart';
import 'history_detail_item.dart';

class HistoryCard extends StatelessWidget {
  final Subscription historyItem; // Now uses Subscription
  final String currencySymbol;
  final bool isExpanded;
  final VoidCallback onTap;

  const HistoryCard({
    super.key,
    required this.historyItem,
    required this.currencySymbol,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final IconData icon = SubscriptionUIHelper.getIcon(historyItem.serviceName);
    final String formattedDate = DateFormat('MMM dd, yyyy').format(historyItem.nextBillingDate ?? historyItem.purchaseDate);
    final contentColor = colorScheme.onSurface.withValues(alpha: 0.6); // Grayed out

    return Card(
      color: theme.cardTheme.color ?? colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: isExpanded ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1), width: 1),
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
                    backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    child: Icon(icon, color: contentColor),
                  ),
                  title: Text(
                    historyItem.serviceName,
                    style: textTheme.titleMedium?.copyWith(
                      color: contentColor,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.lineThrough, // Strikethrough effect!
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text('Ended on $formattedDate', style: textTheme.bodySmall?.copyWith(color: contentColor.withValues(alpha: 0.7))),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatCurrency(historyItem.amount, currencySymbol),
                            style: textTheme.bodyLarge?.copyWith(
                              color: contentColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'EXPIRED',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.error.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 8.0, top: 4.0),
                    child: Column(
                      children: [
                        Divider(
                            color: colorScheme.onSurface.withValues(alpha: 0.08),
                            height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: HistoryDetailItem(
                                label: 'Final Billing Cycle',
                                value: historyItem.billingCycle.name.toUpperCase(),
                                icon: Icons.calendar_month_outlined,
                              ),
                            ),
                            Expanded(
                              child: HistoryDetailItem(
                                label: 'Subscription ID',
                                value: '#${historyItem.id.toString().padLeft(6, '0')}',
                                icon: Icons.tag,
                              ),
                            ),
                          ],
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
}