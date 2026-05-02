import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuart,
      left: 0,
      right: 0,
      bottom: _isPillVisible ? 86 : -100,
      child: Center(
        child: Container(
          width: 230,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isDark 
                      ? theme.colorScheme.surface.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.1),
                    width: 0.5,
                  ),
                ),
                child: Stack(
                  children: [
                    // Inner highlight (top)
                    Positioned(
                      top: 0,
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: isDark ? 0.2 : 0.4),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    TabBar(
                      onTap: (_) => HapticFeedback.lightImpact(),
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.cobaltBlue,
                            Color(0xFF4A90E2), // Lighter shade for liquid effect
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cobaltBlue.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                          // Subtle inner highlight on indicator
                          const BoxShadow(
                            color: Colors.white24,
                            blurRadius: 1,
                            offset: Offset(0, 1),
                            spreadRadius: -0.5,
                          ),
                        ],
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.5),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        height: 1.1,
                        letterSpacing: -0.2,
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}