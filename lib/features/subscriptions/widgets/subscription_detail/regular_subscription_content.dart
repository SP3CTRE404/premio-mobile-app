import 'package:flutter/material.dart';
import '../../../dashboard/models/mock_data.dart';
import 'subscription_list_view.dart';

class RegularSubscriptionContent extends StatelessWidget {
  final List<MockSub> subscriptions;
  final String currencySymbol;
  final Set<String> expandedCards;
  final Function(String) onToggleCard;

  const RegularSubscriptionContent({
    super.key,
    required this.subscriptions,
    required this.currencySymbol,
    required this.expandedCards,
    required this.onToggleCard,
  });

  @override
  Widget build(BuildContext context) {
    return SubscriptionListView(
      subscriptions: subscriptions,
      currencySymbol: currencySymbol,
      expandedCards: expandedCards,
      onToggleCard: onToggleCard,
      tabPrefix: 'single',
      showMadeBy: false,
    );
  }
}
