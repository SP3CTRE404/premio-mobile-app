import 'package:flutter/material.dart';

import '../../dashboard/models/mock_data.dart';
import './subscription_card.dart';

class SubscriptionListView extends StatelessWidget {
  final List<MockSub> subscriptions;
  final String currencySymbol;
  final Set<String> expandedCards;
  final Function(String) onToggleCard;
  final String tabPrefix;
  final bool showMadeBy;
  final bool isSingularUser;

  const SubscriptionListView({
    super.key,
    required this.subscriptions,
    required this.currencySymbol,
    required this.expandedCards,
    required this.onToggleCard,
    required this.tabPrefix,
    required this.showMadeBy,
    required this.isSingularUser,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        top: 100.0,
        bottom: 130.0,
        left: 16.0,
        right: 16.0,
      ),
      itemCount: subscriptions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sub = subscriptions[index];
        final cardKey = '${tabPrefix}_$index';
        final isExpanded = expandedCards.contains(cardKey);

        return SubscriptionCard(
          subscription: sub,
          currencySymbol: currencySymbol,
          isExpanded: isExpanded,
          onTap: () => onToggleCard(cardKey),
          showMadeBy: showMadeBy,
        );
      },
    );
  }
}
