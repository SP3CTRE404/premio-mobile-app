import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/mock_data.dart';

/// Displays the list of filtered subscription action cards.
class ActionCardList extends StatelessWidget {
  final List<MockSub> subscriptions;
  final Set<String> paidItems;
  final String currencySymbol;
  final ValueChanged<String> onTogglePaid;

  const ActionCardList({
    super.key,
    required this.subscriptions,
    required this.paidItems,
    required this.currencySymbol,
    required this.onTogglePaid,
  });

  @override
  Widget build(BuildContext context) {
    if (subscriptions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'No subscriptions in this category.',
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
                isPaid: paidItems.contains(sub.name),
                currencySymbol: currencySymbol,
                onTogglePaid: () => onTogglePaid(sub.name),
              ))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────
// Individual action card
// ─────────────────────────────────────────

// ─────────────────────────────────────────
// Individual action card
// ─────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final MockSub sub;
  final bool isPaid;
  final String currencySymbol;
  final VoidCallback onTogglePaid;

  const _ActionCard({
    required this.sub,
    required this.isPaid,
    required this.currencySymbol,
    required this.onTogglePaid,
  });

  @override
  Widget build(BuildContext context) {
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
            color: isPaid ? Colors.green : sub.statusColor,
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isPaid ? Colors.green : sub.statusColor)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                sub.icon,
                color: isPaid ? Colors.green : sub.statusColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            
            // Text content (Title and Due Date)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    sub.name,
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
                    isPaid ? 'Paid ✓' : sub.due,
                    style: TextStyle(
                      color: isPaid ? Colors.green : sub.statusColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // ── Price (Now aligned vertically outside the Column) ──
            Text(
              formatCurrency(sub.price, currencySymbol),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Mark as Paid button
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