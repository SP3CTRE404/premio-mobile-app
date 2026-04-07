import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/models/mock_data.dart';
import '../../settings/providers/currency_provider.dart';
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

    return HistoryListView(
      subscriptions: mockSubs.where((s) => s.madeBy == 'Me').toList(),
      currencySymbol: currencySymbol,
      expandedCards: _expandedCards,
      onToggleCard: _toggleCard,
      tabPrefix: 'history_personal',
      showMadeBy: false,
    );
  }
}
