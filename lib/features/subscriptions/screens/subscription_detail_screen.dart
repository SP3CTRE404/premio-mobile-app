import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../dashboard/models/mock_data.dart';
import '../../settings/providers/currency_provider.dart';
import '../widgets/subscription_fab_menu.dart';
import './add_subscription_screen.dart';
import './history_screen.dart';

class SubscriptionDetailScreen extends ConsumerStatefulWidget {
  const SubscriptionDetailScreen({super.key});

  @override
  ConsumerState<SubscriptionDetailScreen> createState() =>
      _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends ConsumerState<SubscriptionDetailScreen> {
  final bool _isSingularUser = false; // Toggle this to switch between modes

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

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.cobaltBlue),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.pureWhite,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSubscriptionList(List<MockSub> subs, String currencySymbol, {required String tabPrefix, required bool showMadeBy}) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      // Top padding for custom App Bar, bottom padding prevents FAB overlap
      padding: EdgeInsets.only(
        top: _isSingularUser ? 120.0 : 160.0,
        bottom: 160.0,
        left: 16.0,
        right: 16.0,
      ),
      itemCount: subs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sub = subs[index];
        final cardKey = '${tabPrefix}_$index';
        final isExpanded = _expandedCards.contains(cardKey);

        final bool isOverdue = sub.due.toLowerCase().contains('overdue');
        final String paymentType = isOverdue ? 'Manual' : 'Auto-pay';
        final String billingCycle = 'Monthly';

        return Card(
          color: AppColors.darkSurface,
          surfaceTintColor: Colors.transparent,
          elevation: isExpanded ? 8 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isExpanded 
              ? BorderSide(color: AppColors.cobaltBlue.withOpacity(0.3), width: 1)
              : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _toggleCard(cardKey),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.trueBlack,
                        child: Icon(
                          sub.icon,
                          color: sub.statusColor,
                        ),
                      ),
                      title: Text(
                        sub.name,
                        style: const TextStyle(
                          color: AppColors.pureWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          sub.due,
                          style: TextStyle(
                            color: AppColors.pureWhite.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatCurrency(sub.price, currencySymbol),
                                style: const TextStyle(
                                  color: AppColors.cobaltBlue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sub.category,
                                style: TextStyle(
                                  color: AppColors.pureWhite.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.white54,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0, top: 4.0),
                        child: Column(
                          children: [
                            const Divider(color: Colors.white12, height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: showMadeBy
                                  ? Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: _buildDetailItem(
                                                'Billing Cycle',
                                                billingCycle,
                                                Icons.calendar_month_outlined,
                                              ),
                                            ),
                                            Expanded(
                                              child: _buildDetailItem(
                                                'Payment Type',
                                                paymentType,
                                                Icons.payment_outlined,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: _buildDetailItem(
                                                'Date',
                                                sub.purchaseDate,
                                                Icons.event_available_outlined,
                                              ),
                                            ),
                                            Expanded(
                                              child: _buildDetailItem(
                                                'Made By:',
                                                sub.madeBy,
                                                Icons.person_outline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: _buildDetailItem(
                                            'Billing Cycle',
                                            billingCycle,
                                            Icons.calendar_month_outlined,
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildDetailItem(
                                            'Payment Type',
                                            paymentType,
                                            Icons.payment_outlined,
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildDetailItem(
                                            'Date',
                                            sub.purchaseDate,
                                            Icons.event_available_outlined,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = ref.watch(currencySymbolProvider);

    Widget content;
    if (_isSingularUser) {
      content = _buildSubscriptionList(mockSubs, currencySymbol, tabPrefix: 'single', showMadeBy: false);
    } else {
      content = DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 100), // Height of CustomAppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25), // Creates the pill shape
                  color: AppColors.cobaltBlue,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: "My Subscriptions"),
                  Tab(text: "Household"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSubscriptionList(
                    mockSubs.where((s) => s.madeBy == 'Me').toList(),
                    currencySymbol,
                    tabPrefix: 'mine',
                    showMadeBy: false,
                  ),
                  _buildSubscriptionList(
                    mockSubs.where((s) => s.madeBy != 'Me').toList(),
                    currencySymbol,
                    tabPrefix: 'household',
                    showMadeBy: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: content,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: SubscriptionFabMenu(
          isSingularUser: _isSingularUser,
          onHistoryTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            );
          },
          onAddSubscriptionTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddSubscriptionScreen()),
            );
          },
          onAddHouseholdTap: () {
            // Placeholder for household logic
          },
        ),
      ),
    );
  }
}