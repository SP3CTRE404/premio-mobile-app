import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/providers/currency_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/history/history_list_view.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final Set<String> _expandedCards = {};

  void _toggleCard(String cardKey) {
    setState(() {
      if (_expandedCards.contains(cardKey)) {
        _expandedCards.remove(cardKey);
      } else {
        _expandedCards.add(cardKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = ref.watch(currencySymbolProvider);
    final historyAsync = ref.watch(userHistoryProvider);

    return historyAsync.when(
      data: (historyList) {
        // Sort history by most recent "expiry" (nextBillingDate)
        final sortedList = List.of(historyList)
          ..sort((a, b) {
            final dateA = a.nextBillingDate ?? a.purchaseDate;
            final dateB = b.nextBillingDate ?? b.purchaseDate;
            return dateB.compareTo(dateA);
          });

        return HistoryListView(
          historyItems: sortedList,
          currencySymbol: currencySymbol,
          expandedCards: _expandedCards,
          onToggleCard: _toggleCard,
          tabPrefix: 'history_personal',
        );
      },

      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading history: $err')),
    );
  }
}


