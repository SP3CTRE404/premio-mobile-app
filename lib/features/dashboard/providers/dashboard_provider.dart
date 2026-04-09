import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../subscriptions/models/subscription_model.dart';
import '../../subscriptions/services/subscription_repository.dart';
import '../../auth/providers/auth_provider.dart';


/// Monthly total spending fetched from the backend.
final monthlyTotalProvider = FutureProvider<double>((ref) async {
  ref.watch(authProvider); // Reset on logout/login
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getMonthlyTotal();
});


/// Due / upcoming subscriptions for the dashboard ring chart & list.
final dueSubscriptionsProvider =
    FutureProvider<List<Subscription>>((ref) async {
  ref.watch(authProvider); // Reset on logout/login
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getDueSubscriptions();
});

