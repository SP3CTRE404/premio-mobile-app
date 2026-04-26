import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/providers/currency_provider.dart';
import '../../subscriptions/providers/history_provider.dart';
import '../widgets/expired_subscriptions/expired_subscriptions_list_view.dart';

class ExpiredSubscriptionsScreen extends ConsumerStatefulWidget {
  final int? memberId;
  final String? memberName;

  const ExpiredSubscriptionsScreen({
    super.key,
    this.memberId,
    this.memberName,
  });

  @override
  ConsumerState<ExpiredSubscriptionsScreen> createState() => _ExpiredSubscriptionsScreenState();
}

class _ExpiredSubscriptionsScreenState extends ConsumerState<ExpiredSubscriptionsScreen> {
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
    
    // Determine which provider to use
    final expiredAsync = widget.memberId != null
        ? ref.watch(memberExpiredSubscriptionsProvider(widget.memberId!))
        : ref.watch(expiredSubscriptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.memberId != null ? '${widget.memberName}\'s Expired Plans' : 'Expired Subscriptions'),
        centerTitle: true,
      ),
      body: expiredAsync.when(
        data: (subscriptions) {
          final sortedList = List.of(subscriptions)
            ..sort((a, b) {
              final dateA = a.nextBillingDate ?? a.purchaseDate;
              final dateB = b.nextBillingDate ?? b.purchaseDate;
              return dateB.compareTo(dateA);
            });
          return ExpiredSubscriptionsListView(
            subscriptions: sortedList,
            currencySymbol: currencySymbol,
            expandedCards: _expandedCards,
            onToggleCard: _toggleCard,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
