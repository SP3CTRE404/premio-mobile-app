import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/models/mock_data.dart';
import '../../settings/providers/currency_provider.dart';
import '../models/user_role.dart';
import '../providers/user_role_provider.dart';
import '../widgets/subscription_detail/subscription_fab_menu.dart';
import '../widgets/subscription_detail/subscription_list_view.dart';
import './add_subscription_screen.dart';
import './subscription_search_screen.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencySymbol = ref.watch(currencySymbolProvider);
    final userRole = ref.watch(userRoleProvider);

    Widget content;
    if (userRole != UserRole.admin) {
      content = SubscriptionListView(
        subscriptions: mockSubs.where((s) => s.madeBy == 'Me').toList(),
        currencySymbol: currencySymbol,
        expandedCards: _expandedCards,
        onToggleCard: _toggleCard,
        tabPrefix: 'single',
        showMadeBy: false,
      );
    } else {
      content = DefaultTabController(
        length: 2,
        child: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Only react to vertical scrolling from the internal lists
                if (notification.metrics.axis != Axis.vertical) {
                  return false;
                }

                if (notification is ScrollUpdateNotification) {
                  final delta = notification.scrollDelta ?? 0;
                  if (delta < 0 && !_isPillVisible) {
                    setState(() => _isPillVisible = true);
                  }
                }

                // If we reach the bottom, hide it
                if (notification.metrics.extentAfter == 0 && _isPillVisible) {
                  setState(() => _isPillVisible = false);
                }
                return false; // Let notification bubble up
              },
              child: TabBarView(
                children: [
                  SubscriptionListView(
                    subscriptions:
                        mockSubs.where((s) => s.madeBy == 'Me').toList(),
                    currencySymbol: currencySymbol,
                    expandedCards: _expandedCards,
                    onToggleCard: _toggleCard,
                    tabPrefix: 'mine',
                    showMadeBy: false,
                  ),
                  SubscriptionListView(
                    subscriptions:
                        mockSubs.where((s) => s.madeBy != 'Me').toList(),
                    currencySymbol: currencySymbol,
                    expandedCards: _expandedCards,
                    onToggleCard: _toggleCard,
                    tabPrefix: 'household',
                    showMadeBy: true,
                  ),
                ],
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: 0,
              right: 0,
              bottom: _isPillVisible ? 86 : -100,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Container(
                    width: 220, // Smaller fixed width to center it
                    height: 60, // Slightly taller for 2-row text
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.08),
                        width: 1.5,
                      ),
                    ),
                    child: TabBar(
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: colorScheme.primary,
                      ),
                      labelColor: colorScheme.onPrimary,
                      unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.54),
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
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          content,
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
}