import 'package:flutter/material.dart';

import '../../models/subscription_model.dart';
import 'subscription_list_view.dart';

class RegularSubscriptionContent extends StatelessWidget {
  final List<Subscription> subscriptions;
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

