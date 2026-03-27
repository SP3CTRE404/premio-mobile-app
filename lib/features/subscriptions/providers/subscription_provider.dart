import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription_model.dart';
import '../models/subscription_request.dart';
import '../services/subscription_repository.dart';

/// Holds the list of due / active subscriptions.
class SubscriptionNotifier extends AsyncNotifier<List<Subscription>> {
  @override
  Future<List<Subscription>> build() async {
    return _fetchDue();
  }

  Future<List<Subscription>> _fetchDue() async {
    final repo = ref.read(subscriptionRepositoryProvider);
    return repo.getDueSubscriptions();
  }

  /// Pull latest subscriptions from the server.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchDue);
  }

  /// Add a new subscription and refresh.
  Future<void> add(SubscriptionRequest request) async {
    final repo = ref.read(subscriptionRepositoryProvider);
    await repo.addSubscription(request);
    await refresh();
  }

  /// Mark a subscription as paid.
  Future<void> pay(int id) async {
    final repo = ref.read(subscriptionRepositoryProvider);
    await repo.paySubscription(id);
    await refresh();
  }

  /// Toggle auto-pay for a subscription.
  Future<void> toggleAutoPay(int id) async {
    final repo = ref.read(subscriptionRepositoryProvider);
    await repo.toggleAutoPay(id);
    await refresh();
  }
}

final subscriptionProvider =
    AsyncNotifierProvider<SubscriptionNotifier, List<Subscription>>(
  SubscriptionNotifier.new,
);
