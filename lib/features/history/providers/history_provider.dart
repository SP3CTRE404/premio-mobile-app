import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_model.dart';
import '../services/history_repository.dart';

/// Fetches payment history for a given subscription ID.
/// Usage: `ref.watch(historyProvider(subscriptionId))`
final historyProvider =
    FutureProvider.autoDispose.family<List<SubscriptionHistory>, int>(
  (ref, subscriptionId) async {
    final repo = ref.read(historyRepositoryProvider);
    return repo.getHistory(subscriptionId);
  },
);
