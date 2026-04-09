import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../account/providers/account_provider.dart';
import '../../settings/providers/currency_provider.dart';
import '../../subscriptions/models/user_role.dart';
import '../../subscriptions/providers/user_role_provider.dart';
import '../../subscriptions/providers/subscription_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/action_card_list.dart';
import '../widgets/category_chips.dart';
import '../widgets/financial_hero_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedCategory = 'All';
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
              final roleBasedSubs = userRole == UserRole.admin 
                  ? allSubs 
                  : allSubs.where((s) => s.ownerName == userAsync.value?.fullName).toList();

              final filteredSubs = _selectedCategory == 'All' 
                  ? roleBasedSubs 
                  : roleBasedSubs; 

              final upToDate = roleBasedSubs.where((s) => _paidItems.contains(s.id)).length;
              final dueSoon = roleBasedSubs.where((s) => s.nextBillingDate.difference(DateTime.now()).inDays <= 7 && s.nextBillingDate.difference(DateTime.now()).inDays >= 0).length;
              final overdue = roleBasedSubs.where((s) => s.nextBillingDate.isBefore(DateTime.now())).length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  monthlyTotalAsync.when(
                    data: (monthly) {
                      return FinancialHeroCard(
                        monthly: monthly,
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

                  _sectionTitle(context, 'Categories'),
                  const SizedBox(height: 12),
                  CategoryChips(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
                  ),

                  const SizedBox(height: 28),

                  _sectionTitle(context, 'Action Needed'),
                  const SizedBox(height: 16),
                  
                  ActionCardList(
                    subscriptions: filteredSubs, 
                    paidItems: _paidItems.map((e) => e.toString()).toSet(), 
                    currencySymbol: currencySymbol,
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

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}