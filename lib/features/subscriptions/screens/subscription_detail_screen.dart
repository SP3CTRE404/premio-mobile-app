import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/providers/account_provider.dart';
import '../../settings/providers/currency_provider.dart';
import '../models/user_role.dart';
import '../providers/user_role_provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/subscription_detail/subscription_fab_menu.dart';
import '../widgets/subscription_detail/subscription_list_view.dart';
import './add_subscription_screen.dart';
import './subscription_search_screen.dart';
import '../../../core/theme/app_colors.dart';

class SubscriptionDetailScreen extends ConsumerStatefulWidget {
  const SubscriptionDetailScreen({super.key});

  @override
  ConsumerState<SubscriptionDetailScreen> createState() =>
      _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState
    extends ConsumerState<SubscriptionDetailScreen> {
  bool _isPillVisible = true;
  bool _isFabMenuOpen = false;

  final GlobalKey<SubscriptionFabMenuState> _fabKey = GlobalKey();

  // Track which cards are expanded by a combination of key prefix ("mine_" or "all_") and index
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
    final userRole = ref.watch(userRoleProvider);
    final userAsync = ref.watch(userProvider);
    final subscriptionsAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          subscriptionsAsync.when(
            data: (allSubs) {
              final userFullName = userAsync.value?.fullName ?? '';
              final mySubs = allSubs.where((s) => s.ownerName == userFullName).toList();
              final householdSubs = allSubs.where((s) => s.ownerName != userFullName).toList();

              if (userRole != UserRole.admin) {
                return SubscriptionListView(
                  subscriptions: mySubs,
                  currencySymbol: currencySymbol,
                  expandedCards: _expandedCards,
                  onToggleCard: _toggleCard,
                  tabPrefix: 'single',
                  showMadeBy: false,
                );
              }

              return DefaultTabController(
                length: 2,
                child: Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.axis != Axis.vertical) return false;
                        if (notification is ScrollUpdateNotification) {
                          final delta = notification.scrollDelta ?? 0;
                          // Show when scrolling up
                          if (delta < -10 && !_isPillVisible) {
                            setState(() => _isPillVisible = true);
                          } 
                          // Hide when scrolling down significantly
                          else if (delta > 10 && _isPillVisible && notification.metrics.pixels > 50) {
                            setState(() => _isPillVisible = false);
                          }
                        }
                        return false;
                      },

                      child: TabBarView(
                        children: [
                          SubscriptionListView(
                            subscriptions: mySubs,
                            currencySymbol: currencySymbol,
                            expandedCards: _expandedCards,
                            onToggleCard: _toggleCard,
                            tabPrefix: 'mine',
                            showMadeBy: false,
                          ),
                          SubscriptionListView(
                            subscriptions: householdSubs,
                            currencySymbol: currencySymbol,
                            expandedCards: _expandedCards,
                            onToggleCard: _toggleCard,
                            tabPrefix: 'household',
                            showMadeBy: true,
                          ),
                        ],
                      ),
                    ),
                    _buildTabPill(context),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),

          // FAB Backdrop (Dim & Blur)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_isFabMenuOpen,
              child: GestureDetector(
                onTap: () => _fabKey.currentState?.closeAll(),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: _isFabMenuOpen ? 1.0 : 0.0,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: SubscriptionFabMenu(
          key: _fabKey,
          onMenuToggle: (isOpen) => setState(() => _isFabMenuOpen = isOpen),
          onSearchTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubscriptionSearchScreen()),
            );
          },
          onAddSubscriptionTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddSubscriptionScreen()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabPill(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: 0,
      right: 0,
      bottom: _isPillVisible ? 86 : -100,
      child: Center(
        child: Container(
          width: 220,
          height: 60,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.12),
              width: 0.8,
            ),
            color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                spreadRadius: -10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TabBar(
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: AppColors.cobaltBlue,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.6)
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              height: 1.1,
            ),
            tabs: const [
              Tab(
                child: Text(
                  "My\nSubscriptions",
                  textAlign: TextAlign.center,
                ),
              ),
              Tab(text: "Household"),
            ],
          ),
        ),
      ),
    );
  }
}