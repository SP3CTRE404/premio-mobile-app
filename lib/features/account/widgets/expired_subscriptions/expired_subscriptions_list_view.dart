import 'package:flutter/material.dart';
import '../../../subscriptions/models/subscription_model.dart';
import 'expired_subscription_card.dart';

class ExpiredSubscriptionsListView extends StatelessWidget {
  final List<Subscription> subscriptions;
  final String currencySymbol;
  final Set<String> expandedCards;
  final Function(String) onToggleCard;

  const ExpiredSubscriptionsListView({
    super.key,
    required this.subscriptions,
    required this.currencySymbol,
    required this.expandedCards,
    required this.onToggleCard,
  });

  @override
  Widget build(BuildContext context) {
    if (subscriptions.isEmpty) {
      return const Center(child: Text('No expired subscriptions found.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: subscriptions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = subscriptions[index];
        final cardKey = 'expired_${item.id}';
        final isExpanded = expandedCards.contains(cardKey);

        return ExpiredSubscriptionCard(
          subscription: item,
          currencySymbol: currencySymbol,
          isExpanded: isExpanded,
          onTap: () => onToggleCard(cardKey),
        );
      },
    );
  }
}
