import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../account/providers/account_provider.dart';
import '../../settings/providers/currency_provider.dart';
import '../../subscriptions/models/user_role.dart';
import '../../subscriptions/providers/user_role_provider.dart';
import '../../subscriptions/providers/subscription_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/action_card_list.dart';
import '../widgets/financial_hero_card.dart';

enum DashboardViewMode { personal, household }


class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DashboardViewMode _viewMode = DashboardViewMode.personal;

  final Set<int> _paidItems = {}; 


  @override
  Widget build(BuildContext context) {
    final currencySymbol = ref.watch(currencySymbolProvider);
    final userAsync = ref.watch(userProvider);
    final subscriptionsAsync = ref.watch(subscriptionProvider);
    final monthlyTotalAsync = ref.watch(monthlyTotalProvider);
    final userRole = ref.watch(userRoleProvider);
    
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight - 40;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          userAsync.when(
            data: (user) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${user?.fullName.split(' ').first ?? 'User'}!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Here is your subscription overview.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox(height: 60),
            error: (err, stack) => const SizedBox.shrink(),
          ),

          subscriptionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Failed to load subscriptions: $err'),
            data: (allSubs) {
              final isAdmin = userRole == UserRole.admin;
              final currentUserId = userAsync.value?.id;

              // What this user is ALLOWED to see on their dashboard
              final viewableSubs = isAdmin
                  ? allSubs // Admins see everything for the overview
                  : allSubs.where((s) => s.ownerId == currentUserId).toList(); // Members only see their own

              // Action Needed list filtering (Specific focus for Admins)
              final filteredSubs = (isAdmin && _viewMode == DashboardViewMode.personal)
                  ? viewableSubs.where((s) => s.ownerId == currentUserId).toList()
                  : (isAdmin && _viewMode == DashboardViewMode.household)
                      ? viewableSubs.where((s) => s.ownerId != currentUserId).toList()
                      : viewableSubs;

              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              
              final overdue = viewableSubs.where((s) {
                final billingDate = DateTime(s.nextBillingDate.year, s.nextBillingDate.month, s.nextBillingDate.day);
                return billingDate.isBefore(today);
              }).length;

              final dueSoon = viewableSubs.where((s) {
                final billingDate = DateTime(s.nextBillingDate.year, s.nextBillingDate.month, s.nextBillingDate.day);
                if (billingDate.isBefore(today)) return false;
                final diff = billingDate.difference(today).inDays;
                return diff >= 0 && diff <= 3;
              }).length;

              final upToDate = viewableSubs.length - overdue - dueSoon;






              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  monthlyTotalAsync.when(
                    data: (householdMonthly) {
                      // Members only see their own monthly total, Admins see the whole house
                      final displayMonthly = isAdmin 
                          ? householdMonthly 
                          : viewableSubs.fold(0.0, (sum, sub) => sum + sub.amount);
                          
                      return FinancialHeroCard(
                        monthly: displayMonthly,
                        upToDate: upToDate,
                        dueSoon: dueSoon,
                        overdue: overdue,
                        currencySymbol: currencySymbol,
                      );
                    },


                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, st) => const FinancialHeroCard(
                      monthly: 0,
                      upToDate: 0,
                      dueSoon: 0,
                      overdue: 0,
                      currencySymbol: '\$',
                    ),
                  ),

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle(context, 'Action Needed'),
                      if (isAdmin) _buildViewToggle(context),
                    ],
                  ),
                  const SizedBox(height: 16),

                  
                  ActionCardList(
                    subscriptions: filteredSubs.where((s) {
                      if (s.isAutoPay) return false;
                      final billingDate = DateTime(s.nextBillingDate.year, s.nextBillingDate.month, s.nextBillingDate.day);
                      final isOverdue = billingDate.isBefore(today);
                      final isUpcoming = !isOverdue && billingDate.difference(today).inDays <= 3;
                      return isOverdue || isUpcoming;
                    }).toList(), 
                    paidItems: _paidItems.map((e) => e.toString()).toSet(), 
                    currencySymbol: currencySymbol,
                    showOwner: _viewMode == DashboardViewMode.household,
                    onTogglePaid: (idString) {
                      final id = int.parse(idString);
                      setState(() {
                        if (_paidItems.contains(id)) {
                          _paidItems.remove(id);
                        } else {
                          _paidItems.add(id);
                        }
                      });
                    },
                  ),


                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 180, // Made it a small unit
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          _ViewModeButton(
            label: 'Personal',
            isSelected: _viewMode == DashboardViewMode.personal,
            onTap: () => setState(() => _viewMode = DashboardViewMode.personal),
          ),
          _ViewModeButton(
            label: 'Household',
            isSelected: _viewMode == DashboardViewMode.household,
            onTap: () => setState(() => _viewMode = DashboardViewMode.household),
          ),
        ],
      ),
    );
  }


  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),

      ),
    );
  }
}