import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/providers/currency_provider.dart';
import '../models/mock_data.dart';
import '../widgets/action_card_list.dart';
import '../widgets/calendar_strip.dart';
import '../widgets/category_chips.dart';
import '../widgets/financial_hero_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedCategory = 'All';
  final Set<String> _paidItems = {};

  List<MockSub> get _filteredSubs {
    if (_selectedCategory == 'All') return mockSubs;
    return mockSubs.where((s) => s.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = ref.watch(currencySymbolProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section 1: Financial Insights Hero ──
          FinancialHeroCard(
            monthly: 4250.00,
            upToDate: 5,
            dueSoon: 2,
            overdue: 1,
            currencySymbol: currencySymbol,
          ),

          const SizedBox(height: 28),

          // ── Section 2: Category Chips ──
          _sectionTitle(context, 'Categories'),
          const SizedBox(height: 12),
          CategoryChips(
            selectedCategory: _selectedCategory,
            onCategorySelected: (cat) =>
                setState(() => _selectedCategory = cat),
          ),

          const SizedBox(height: 28),

          // ── Section 3: Action Needed with Calendar ──
          _sectionTitle(context, 'Action Needed'),
          const SizedBox(height: 12),
          const CalendarStrip(),
          const SizedBox(height: 16),
          ActionCardList(
            subscriptions: _filteredSubs,
            paidItems: _paidItems,
            currencySymbol: currencySymbol,
            onTogglePaid: (name) {
              setState(() {
                if (_paidItems.contains(name)) {
                  _paidItems.remove(name);
                } else {
                  _paidItems.add(name);
                }
              });
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