import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/providers/currency_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/history/payment_history_list_view.dart';

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  final int? memberId;
  final String? memberName;

  const PaymentHistoryScreen({
    super.key,
    this.memberId,
    this.memberName,
  });

  @override
  ConsumerState<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Only set up infinite scroll for personal history (paginated)
    if (widget.memberId == null) {
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Near the bottom — load next page
      ref.read(paginatedHistoryProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = ref.watch(currencySymbolProvider);

    if (widget.memberId != null) {
      // Member-specific view (admin only) — uses simple FutureProvider
      final historyAsync = ref.watch(memberHistoryProvider(widget.memberId!));
      
      final content = historyAsync.when(
        data: (historyList) {
          final sortedList = List.of(historyList)
            ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
          return PaymentHistoryListView(
            historyItems: sortedList,
            currencySymbol: currencySymbol,
            tabPrefix: 'history_member_${widget.memberId}',
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading history: $err')),
      );

      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.memberName}\'s History'),
          centerTitle: true,
        ),
        body: content,
      );
    }

    // Personal history — uses paginated notifier
    final paginatedState = ref.watch(paginatedHistoryProvider);
    final historyItems = paginatedState.items;

    if (historyItems.isEmpty && !paginatedState.hasMore) {
      return const Center(child: Text('No payment history found.'));
    }

    if (historyItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final sortedList = List.of(historyItems)
      ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

    return PaymentHistoryListView(
      historyItems: sortedList,
      currencySymbol: currencySymbol,
      tabPrefix: 'history_personal',
      scrollController: _scrollController,
      isLoadingMore: paginatedState.isLoadingMore,
      hasMore: paginatedState.hasMore,
    );
  }
}
