import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../subscriptions/models/subscription_model.dart';
import '../../subscriptions/services/subscription_repository.dart';
import '../../auth/providers/auth_provider.dart';


import '../../settings/providers/currency_provider.dart';
import '../../../core/utils/currency_converter.dart';
import '../../subscriptions/providers/subscription_provider.dart';

/// Monthly total spending calculated locally to support dynamic currency conversion.
final monthlyTotalProvider = FutureProvider<double>((ref) async {
  final subscriptions = await ref.watch(subscriptionProvider.future);
  final globalCurrency = ref.watch(displayCurrencyProvider);
  
  double totalMonthly = 0.0;
  for (final sub in subscriptions) {
    if (sub.status == 'EXPIRED') continue;

    // Convert to monthly equivalent
    double monthlyEquivalent = sub.amount;
    switch (sub.billingCycle) {
      case BillingCycle.yearly:
        monthlyEquivalent = sub.amount / 12;
        break;
      case BillingCycle.quarterly:
        monthlyEquivalent = sub.amount / 3;
        break;
      case BillingCycle.oneTime:
        continue; // One-time payments don't count towards regular monthly estimates
      case BillingCycle.custom:
        if (sub.customIntervalUnit == 'MONTHS') {
          monthlyEquivalent = sub.amount / (sub.customIntervalDays ?? 1);
        } else if (sub.customIntervalUnit == 'DAYS') {
          monthlyEquivalent = sub.amount * (30 / (sub.customIntervalDays ?? 30));
        } else if (sub.customIntervalUnit == 'WEEKS') {
          monthlyEquivalent = sub.amount * (4 / (sub.customIntervalDays ?? 1));
        }
        break;
      case BillingCycle.monthly:
        monthlyEquivalent = sub.amount;
        break;
    }

    // Convert to global currency
    final subCurrency = sub.currency ?? '\$'; // Default to USD if missing
    final convertedAmount = CurrencyConverter.convert(
      amount: monthlyEquivalent,
      fromCurrency: subCurrency,
      toCurrency: globalCurrency,
    );

    totalMonthly += convertedAmount;
  }
  
  return totalMonthly;
});


/// Due / upcoming subscriptions for the dashboard ring chart & list.
final dueSubscriptionsProvider =
    FutureProvider<List<Subscription>>((ref) async {
  ref.watch(authProvider); // Reset on logout/login
  ref.watch(subscriptionProvider); // Automatically refresh when subscriptions change
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getDueSubscriptions();
});

