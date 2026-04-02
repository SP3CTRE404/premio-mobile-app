import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/widgets/auth_background.dart';
import '../../dashboard/models/mock_data.dart';
import '../../settings/providers/currency_provider.dart';
import '../widgets/subscription_detail/subscription_card.dart';

class SubscriptionSearchScreen extends ConsumerStatefulWidget {
  const SubscriptionSearchScreen({super.key});

  @override
  ConsumerState<SubscriptionSearchScreen> createState() => _SubscriptionSearchScreenState();
}

class _SubscriptionSearchScreenState extends ConsumerState<SubscriptionSearchScreen> 
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol = ref.watch(currencySymbolProvider);
    
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final filtered = mockSubs
        .where((s) => s.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Search Subscriptions', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background
          const AuthBackground(),
          
          // Full-screen ListView that scrolls behind the search bar
          filtered.isEmpty && _query.isNotEmpty
              ? const Center(child: Text('No subscriptions found.'))
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 120, 16, 120 + bottomInset),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final sub = filtered[index];
                    final cardKey = 'search_$index';
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
                ),
          
          // Floating search bar overlay
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 0.8,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.05),
                        Colors.white.withValues(alpha: 0.01),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 24,
                        spreadRadius: -8,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Inner top highlight (bevel)
                      Positioned(
                        top: 1,
                        left: 16,
                        right: 16,
                        child: Container(
                          height: 1.2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.4),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            onChanged: (val) => setState(() => _query = val),
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.3,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search Subscriptions',
                              hintStyle: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              icon: Icon(
                                Icons.search,
                                color: AppColors.cobaltBlue.withValues(alpha: 0.9),
                                size: 22,
                              ),
                              suffixIcon: _query.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.close_rounded,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _query = '');
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}