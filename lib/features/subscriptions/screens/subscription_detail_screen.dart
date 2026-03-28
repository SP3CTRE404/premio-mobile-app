import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: const Center(child: Text('The Vault Content')),
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