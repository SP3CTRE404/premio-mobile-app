import 'subscription_model.dart';

/// DTO for creating/updating a subscription.
class SubscriptionRequest {
  final String serviceName;
  final double amount;
  final BillingCycle billingCycle;
  final int? customIntervalDays; // NEW
  final DateTime nextBillingDate;
  final bool isAutoPay;
  final int? householdId; // NEW: So you can link it to a household
  final int? userId;


  SubscriptionRequest({
    required this.serviceName,
    required this.amount,
    required this.billingCycle,
    this.customIntervalDays,
    required this.nextBillingDate,
    required this.isAutoPay,
    this.householdId,
    this.userId,
  });


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'serviceName': serviceName,
      'amount': amount,
      'billingCycle': billingCycle.name.toUpperCase(), // Backend expects uppercase
      'nextBillingDate': nextBillingDate.toIso8601String().split('T')[0], // Usually backend expects YYYY-MM-DD for LocalDate
      'isAutoPay': isAutoPay,
    };

    if (customIntervalDays != null) {
      map['customIntervalDays'] = customIntervalDays;
    }
    if (householdId != null) {
      map['householdId'] = householdId;
    }
    if (userId != null) {
      map['userId'] = userId;
    }


    return map;
  }
}