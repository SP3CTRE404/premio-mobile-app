import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../subscriptions/models/subscription_model.dart';

/// Displays the list of filtered subscription action cards.
class ActionCardList extends StatelessWidget {
  final List<Subscription> subscriptions;
  final Set<String> paidItems;
  final String currencySymbol;
  final ValueChanged<String> onTogglePaid;
  final bool showOwner;

  const ActionCardList({
    super.key,
    required this.subscriptions,
    required this.paidItems,
    required this.currencySymbol,
    required this.onTogglePaid,
    this.showOwner = false,
  });


  @override
  Widget build(BuildContext context) {
    if (subscriptions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'All Caught Up!',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }

    return Column(
      children: subscriptions
          .map((sub) => _ActionCard(
                sub: sub,
                isPaid: paidItems.contains(sub.id.toString()),
                currencySymbol: currencySymbol,
                onTogglePaid: () => onTogglePaid(sub.id.toString()),
                showOwner: showOwner,
              ))
          .toList(),

    );
  }
}

class _ActionCard extends StatelessWidget {
  final Subscription sub;
  final bool isPaid;
  final String currencySymbol;
  final VoidCallback onTogglePaid;
  final bool showOwner;

  const _ActionCard({
    required this.sub,
    required this.isPaid,
    required this.currencySymbol,
    required this.onTogglePaid,
    required this.showOwner,
  });


  IconData _getIconForService(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('youtube') || lower.contains('netflix') || lower.contains('prime') || lower.contains('disney')) {
      return Icons.play_circle_fill_rounded;
    }
    if (lower.contains('amazon') || lower.contains('ebay') || lower.contains('cart')) return Icons.shopping_cart_rounded;
    if (lower.contains('spotify') || lower.contains('apple music') || lower.contains('music')) return Icons.music_note_rounded;
    if (lower.contains('gym') || lower.contains('fitness')) return Icons.fitness_center_rounded;
    if (lower.contains('cloud') || lower.contains('drive') || lower.contains('icloud')) return Icons.cloud_rounded;
    return Icons.subscriptions_rounded;
  }

  Color _getStatusColor(Subscription sub) {
    if (sub.isOverdue || sub.daysUntilDue < 0) return Colors.redAccent;
    if (sub.daysUntilDue == 0) return Colors.amber;
    if (sub.isUpcoming) return Colors.amber;
    return Colors.blueAccent;
  }


  String _getDueStatus(Subscription sub) {
    if (sub.isOverdue || sub.daysUntilDue < 0) {
      final absDays = sub.daysUntilDue.abs();
      return 'Overdue by $absDays ${absDays == 1 ? 'day' : 'days'}';
    }
    if (sub.daysUntilDue == 0) return 'Due today';
    if (sub.isUpcoming) return 'Due in ${sub.daysUntilDue} ${sub.daysUntilDue == 1 ? 'day' : 'days'}';
    return 'Upcoming';
  }


  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(sub);
    final icon = _getIconForService(sub.serviceName);
    final due = _getDueStatus(sub);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isPaid
            ? Theme.of(context).cardTheme.color?.withValues(alpha: 0.5)
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: isPaid ? Colors.green : statusColor,
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isPaid ? Colors.green : statusColor)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isPaid ? Colors.green : AppColors.cobaltBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    sub.serviceName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      decoration: isPaid
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPaid ? 'Paid ✓' : due,
                    style: TextStyle(
                      color: isPaid ? Colors.green : statusColor,
                      fontSize: 13,
                    ),
                  ),
                  if (showOwner) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub.ownerName ?? 'Unknown',

                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],


                ],
              ),
            ),
            const SizedBox(width: 12),
            
            Text(
              formatCurrency(sub.amount, currencySymbol),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 16),
            
            GestureDetector(
              onTap: onTogglePaid,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPaid
                        ? Colors.green
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.15),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.check,
                  size: 18,
                  color: isPaid
                      ? Colors.white
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}