import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_model.dart';
import '../models/subscription_model.dart';
import '../services/history_repository.dart';
import '../services/subscription_repository.dart';

/// Fetches payment history for a specific subscription ID.
final historyProvider = FutureProvider.autoDispose.family<List<SubscriptionHistory>, int>(
  (ref, subscriptionId) async {
    final repo = ref.read(historyRepositoryProvider);
    return repo.getHistory(subscriptionId);
  },
);

/// NEW: Fetches all expired subscriptions for the logged-in user.
final userHistoryProvider = FutureProvider.autoDispose<List<Subscription>>((ref) async {
  final repo = ref.read(subscriptionRepositoryProvider);
  return repo.getExpiredSubscriptions();
});


