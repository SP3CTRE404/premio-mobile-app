import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/models/mock_data.dart';
import '../../settings/providers/currency_provider.dart';
import '../models/user_role.dart';
import '../providers/user_role_provider.dart';
import '../widgets/history/history_list_view.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final Set<String> _expandedCards = {};
  bool _isPillVisible = true;

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
    final userRole = ref.watch(userRoleProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);

    Widget content;

    if (userRole != UserRole.admin) {
      content = HistoryListView(
        subscriptions: mockSubs.where((s) => s.madeBy == 'Me').toList(),
        currencySymbol: currencySymbol,
        expandedCards: _expandedCards,
        onToggleCard: _toggleCard,
        tabPrefix: 'history_single',
        showMadeBy: false,
      );
    } else {
      content = DefaultTabController(
        length: 2,
        child: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.axis != Axis.vertical) return false;

                if (notification is ScrollUpdateNotification) {
                  final delta = notification.scrollDelta ?? 0;
                  if (delta < 0 && !_isPillVisible) {
                    setState(() => _isPillVisible = true);
                  }
                }

                if (notification.metrics.extentAfter == 0 && _isPillVisible) {
                  setState(() => _isPillVisible = false);
                }
                return false;
              },
              child: TabBarView(
                children: [
                  HistoryListView(
                    subscriptions:
                        mockSubs.where((s) => s.madeBy == 'Me').toList(),
                    currencySymbol: currencySymbol,
                    expandedCards: _expandedCards,
                    onToggleCard: _toggleCard,
                    tabPrefix: 'history_personal',
                    showMadeBy: false,
                  ),
                  HistoryListView(
                    subscriptions:
                        mockSubs.where((s) => s.madeBy != 'Me').toList(),
                    currencySymbol: currencySymbol,
                    expandedCards: _expandedCards,
                    onToggleCard: _toggleCard,
                    tabPrefix: 'history_household',
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
                    width: 220,
                    height: 60,
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
                      unselectedLabelColor:
                          colorScheme.onSurface.withValues(alpha: 0.54),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        height: 1.1,
                      ),
                      tabs: const [
                        Tab(
                          child: Text(
                            "Personal",
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

    return content;
  }
}
