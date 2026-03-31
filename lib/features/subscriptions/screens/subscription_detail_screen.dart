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
  final bool _isSingularUser = true;

  // Track which cards are expanded
  final Set<int> _expandedCards = {};

  void _toggleCard(int index) {
    setState(() {
      if (_expandedCards.contains(index)) {
        _expandedCards.remove(index);
      } else {
        _expandedCards.add(index);
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

  @override
  Widget build(BuildContext context) {
    // Watch provider for currency preference
    final currencySymbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        // Top padding for custom App Bar, bottom padding prevents FAB overlap
        padding: const EdgeInsets.only(
          top: 120.0,
          bottom: 160.0,
          left: 16.0,
          right: 16.0,
        ),
        itemCount: mockSubs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final sub = mockSubs[index];
          final isExpanded = _expandedCards.contains(index);

          // Determine relevant details based on mock data
          final bool isOverdue = sub.due.toLowerCase().contains('overdue');
          final String paymentType = isOverdue ? 'Manual' : 'Auto-pay';
          final String billingCycle = 'Monthly'; // Defaulting for visual representation
          final String ownership = 'Personal';

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
              onTap: () => _toggleCard(index),
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
                            sub.icon, // Using the correct icon from mock data
                            color: sub.statusColor, // Adds a nice pop of color representing its status
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
                                  sub.category, // Using category in place of billing cycle for mock design
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
                      
                      // Expanded Details Section
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0, top: 4.0),
                          child: Column(
                            children: [
                              const Divider(color: Colors.white12, height: 24),
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
                                  Expanded(
                                    child: _buildDetailItem(
                                      'Ownership',
                                      ownership,
                                      Icons.person_outline,
                                    ),
                                  ),
                                ],
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
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Floating offset
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