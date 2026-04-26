import 'package:flutter/material.dart';
import '../../models/history_model.dart';
import 'payment_history_card.dart';

class PaymentHistoryListView extends StatelessWidget {
  final List<SubscriptionHistory> historyItems;
  final String currencySymbol;
  final String tabPrefix;
  final ScrollController? scrollController;
  final bool isLoadingMore;
  final bool hasMore;

  const PaymentHistoryListView({
    super.key,
    required this.historyItems,
    required this.currencySymbol,
    required this.tabPrefix,
    this.scrollController,
    this.isLoadingMore = false,
    this.hasMore = false,
  });

  @override
  Widget build(BuildContext context) {
    if (historyItems.isEmpty) {
      return const Center(child: Text('No payment history found.'));
    }

    return ListView.separated(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        top: 100.0,
        bottom: 130.0,
        left: 16.0,
        right: 16.0,
      ),
      // +1 for the loading indicator when there are more pages
      itemCount: historyItems.length + (hasMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        // Show a loading indicator at the bottom when fetching next page
        if (index == historyItems.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final item = historyItems[index];
        return PaymentHistoryCard(
          payment: item,
          currencySymbol: currencySymbol,
        );
      },
    );
  }
}
