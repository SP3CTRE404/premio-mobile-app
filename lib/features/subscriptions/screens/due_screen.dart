import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DueScreen extends ConsumerWidget {
  const DueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Text(
        'Due Subscriptions',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
