import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription_model.dart';
import '../models/subscription_request.dart';
import '../services/subscription_repository.dart';
import '../../account/providers/account_provider.dart';
import 'history_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';


/// Holds the list of due / active subscriptions.
class SubscriptionNotifier extends AsyncNotifier<List<Subscription>> {
  @override
  Future<List<Subscription>> build() async {
    // Watch userProvider so it re-fetches if the user joins/leaves a household
    ref.watch(userProvider);
    return _fetchAllActive();
  }

  Future<List<Subscription>> _fetchAllActive() async {
    final repo = ref.read(subscriptionRepositoryProvider);
    final user = ref.read(userProvider).value;

    if (user == null) return [];

    // 1. Fetch user's personal subscriptions (Now fetching ALL, not just Due)
    final userSubs = await repo.getAllSubscriptions();

    // 2. If user is in a household, fetch shared subscriptions
    List<Subscription> householdSubs = [];
    if (user.householdId != null) {
      try {
        householdSubs = await repo.getHouseholdSubscriptions(user.householdId!);
      } catch (e) {
        // Log error but continue with user subs
      }
    }

    // 3. Combine and remove duplicates based on ID
    final combined = [...userSubs, ...householdSubs];
    final seenIds = <int>{};
    return combined.where((s) => seenIds.add(s.id)).toList();
  }

  /// Pull latest subscriptions from the server and refresh dashboard totals.
  Future<void> refresh() async {
    // We do NOT set state = const AsyncValue.loading() here.
    // This allows the UI to keep displaying the old data while fetching the new data,
    // preventing the dashboard from "jumping" or "moving up".
    state = await AsyncValue.guard(_fetchAllActive);
    
    // Refresh dashboard-related providers instead of invalidating them 
    // so they also preserve their previous UI state while reloading.
    // ignore: unused_result
    ref.refresh(monthlyTotalProvider);
    // ignore: unused_result
    ref.refresh(dueSubscriptionsProvider);
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

  /// Update an existing subscription.
  Future<void> updateSubscription(int id, SubscriptionRequest request) async {
    final repo = ref.read(subscriptionRepositoryProvider);
    await repo.updateSubscription(id, request);
    await refresh();
  }

  /// Delete a subscription.
  Future<void> delete(int id) async {
    final repo = ref.read(subscriptionRepositoryProvider);
    await repo.deleteSubscription(id);
    await refresh();
  }

  /// Expire a subscription (move to history).
  Future<void> expire(int id) async {
    final repo = ref.read(subscriptionRepositoryProvider);
    await repo.expireSubscription(id);
    await refresh();
    // Invalidate the history provider so the History Tab refreshes immediately
    ref.invalidate(userHistoryProvider);
  }
}



final subscriptionProvider =
    AsyncNotifierProvider<SubscriptionNotifier, List<Subscription>>(
  SubscriptionNotifier.new,
);
