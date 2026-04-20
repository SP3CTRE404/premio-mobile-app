import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/features/subscriptions/screens/add_subscription_screen.dart';
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
  
  Future<void> _handleRefresh() async {
    // We use the notifier's refresh method to preserve UI state 
    // instead of ref.invalidate() which destroys the state and causes UI jumps.
    await ref.read(subscriptionProvider.notifier).refresh();
    ref.refresh(userProvider);
  }


  @override
  Widget build(BuildContext context) {
    final currencySymbol = ref.watch(currencySymbolProvider);
    final userAsync = ref.watch(userProvider);
    final subscriptionsAsync = ref.watch(subscriptionProvider);
    final monthlyTotalAsync = ref.watch(monthlyTotalProvider);
    final userRole = ref.watch(userRoleProvider);
    
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight - 40;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      displacement: 100, // Move it below the transparent app bar area
      edgeOffset: topPadding,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
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
                      userRole == UserRole.single 
                          ? 'Keep your personal subscriptions in check.' 
                          : 'Here is your subscription overview.',
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
              skipLoadingOnReload: true,
              skipLoadingOnRefresh: true,
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
  
                final overdue = viewableSubs.where((s) => s.isOverdue).length;
  
                final dueSoon = viewableSubs.where((s) => s.isUpcoming).length;
  
                final upToDate = viewableSubs.length - overdue - dueSoon;
  
  
                final actionNeeded = filteredSubs.where((s) {
                  if (s.isAutoPay) return false;
                  return s.isOverdue || s.isUpcoming;
                }).toList();
  
                if (viewableSubs.isEmpty) {
                    return const _DashboardEmptyState();
                }
  
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    monthlyTotalAsync.when(
                      skipLoadingOnReload: true,
                      skipLoadingOnRefresh: true,
                      data: (householdMonthly) {
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
                      subscriptions: actionNeeded, 
                      paidItems: _paidItems.map((e) => e.toString()).toSet(), 
                      currencySymbol: currencySymbol,
                      showOwner: _viewMode == DashboardViewMode.household,
                      onTogglePaid: (idString) async {
                        final id = int.parse(idString);
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await ref.read(subscriptionProvider.notifier).pay(id);
                          
                          if (mounted) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Payment confirmed!')),
                            );
                            setState(() {
                              _paidItems.remove(id);
                            });
                          }
                        } catch (e) {
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(content: Text('Failed to confirm payment: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
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

class _DashboardEmptyState extends StatelessWidget {
  const _DashboardEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.cardTheme.color!,
            theme.cardTheme.color!.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.2),
                  theme.colorScheme.primary.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 56,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Ready to Track?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Add your first subscription to see your personal financial overview and insights.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddSubscriptionScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 28),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Add My First Subscription',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
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