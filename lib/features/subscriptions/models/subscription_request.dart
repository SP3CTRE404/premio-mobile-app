import 'subscription_model.dart';

/// DTO for creating a new subscription via POST /api/subscriptions/add.
class SubscriptionRequest {
  final String serviceName;
  final double amount;
  final BillingCycle billingCycle;
  final DateTime nextBillingDate;
  final bool isAutoPay;

  SubscriptionRequest({
    required this.serviceName,
    required this.amount,
    required this.billingCycle,
    required this.nextBillingDate,
    required this.isAutoPay,
  });

  Map<String, dynamic> toJson() => {
        'serviceName': serviceName,
        'amount': amount,
        'billingCycle': billingCycle.name,
        'nextBillingDate': nextBillingDate.toIso8601String(),
        'isAutoPay': isAutoPay,
      };
}
