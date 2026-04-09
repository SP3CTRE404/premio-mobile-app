import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/widgets/auth_background.dart';
import '../../settings/providers/currency_provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/subscription_detail/subscription_card.dart';
import '../widgets/edit_subscription/subscription_search_bar.dart';

class SubscriptionSearchScreen extends ConsumerStatefulWidget {
  const SubscriptionSearchScreen({super.key});

  @override
  ConsumerState<SubscriptionSearchScreen> createState() => _SubscriptionSearchScreenState();
}

class _SubscriptionSearchScreenState extends ConsumerState<SubscriptionSearchScreen> 
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _query = '';
  final Set<String> _expandedCards = {}; 
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
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = ref.watch(currencySymbolProvider);
    final subscriptionsAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Search Subscriptions', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                offset: const Offset(0, 1),
                blurRadius: 8,
              ),
            ],
          ),
        ),
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
                      Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
                      Theme.of(context).colorScheme.surface.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const AuthBackground(),
          
          subscriptionsAsync.when(
            data: (allSubs) {
              final filtered = allSubs
                  .where((s) => s.serviceName.toLowerCase().contains(_query.toLowerCase()))
                  .toList();

              if (filtered.isEmpty && _query.isNotEmpty) {
                return const Center(child: Text('No subscriptions found.'));
              }

              return ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(16, 120, 16, 120 + MediaQuery.of(context).viewInsets.bottom),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final sub = filtered[index];
                  final cardKey = 'search_${sub.id}';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: SubscriptionCard(
                      subscription: sub,
                      currencySymbol: currencySymbol,
                      isExpanded: _expandedCards.contains(cardKey),
                      onTap: () => _toggleCard(cardKey),
                      showMadeBy: true,
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
          
          SubscriptionSearchBar(
            controller: _searchController,
            query: _query,
            autofocus: true,
            onChanged: (val) => setState(() => _query = val),
          ),
        ],
      ),
    );
  }
}

