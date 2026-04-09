import 'package:flutter/material.dart';
import '../../models/subscription_model.dart';
import 'history_card.dart';

class HistoryListView extends StatelessWidget {
  final List<Subscription> historyItems;
  final String currencySymbol;
  final Set<String> expandedCards;
  final Function(String) onToggleCard;
  final String tabPrefix;

  const HistoryListView({
    super.key,
    required this.historyItems,
    required this.currencySymbol,
    required this.expandedCards,
    required this.onToggleCard,
    required this.tabPrefix,
  });


  @override
  Widget build(BuildContext context) {
    if (historyItems.isEmpty) {
      return const Center(child: Text('No payment history found.'));
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        top: 100.0,
        bottom: 130.0,
        left: 16.0,
        right: 16.0,
      ),
      itemCount: historyItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = historyItems[index];
        final cardKey = '${tabPrefix}_${item.id}';
        final isExpanded = expandedCards.contains(cardKey);

        return HistoryCard(
          historyItem: item,
          currencySymbol: currencySymbol,
          isExpanded: isExpanded,
          onTap: () => onToggleCard(cardKey),
        );
      },
    );
  }
}


