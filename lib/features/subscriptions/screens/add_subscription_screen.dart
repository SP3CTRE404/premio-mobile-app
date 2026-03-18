import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddSubscriptionScreen extends ConsumerWidget {
  const AddSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Text(
        'Add Subscription',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
