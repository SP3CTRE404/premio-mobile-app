import 'dart:ui';
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
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final isScrolled = _scrollController.offset > 10;
        if (isScrolled != _isScrolled) {
          setState(() {
            _isScrolled = isScrolled;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
    final currencySymbol = ref.watch(nativeCurrencyProvider);
    final theme = Theme.of(context);
    
    // Determine which provider to use
    final expiredAsync = widget.memberId != null
        ? ref.watch(memberExpiredSubscriptionsProvider(widget.memberId!))
        : ref.watch(expiredSubscriptionsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.memberId != null ? '${widget.memberName}\'s Expired Plans' : 'Expired Subscriptions',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: AnimatedOpacity(
          opacity: _isScrolled ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.surface.withValues(alpha: 0.3),
                      theme.colorScheme.surface.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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
            controller: _scrollController,
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
