import 'subscription_model.dart';

/// DTO for creating/updating a subscription.
class SubscriptionRequest {
  final String serviceName;
  final double amount;
  final BillingCycle billingCycle;
  final int? customIntervalDays;
  final String? customIntervalUnit;
  final DateTime? nextBillingDate;
  final DateTime purchaseDate;
  final bool isAutoPay;
  final int? householdId; // NEW: So you can link it to a household
  final int? userId;


  SubscriptionRequest({
    required this.serviceName,
    required this.amount,
    required this.billingCycle,
    this.customIntervalDays,
    this.customIntervalUnit,
    this.nextBillingDate,
    required this.purchaseDate,
    required this.isAutoPay,
    this.householdId,
    this.userId,
  });


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'serviceName': serviceName,
      'amount': amount,
      'billingCycle': billingCycle.toJsonString(), // Backend expects uppercase and ONE_TIME
      'purchaseDate': purchaseDate.toIso8601String().split('T')[0],
      'isAutoPay': isAutoPay,
    };

    if (nextBillingDate != null) {
      map['nextBillingDate'] = nextBillingDate!.toIso8601String().split('T')[0];
    }
    if (customIntervalDays != null) {
      map['customIntervalDays'] = customIntervalDays;
    }
    if (customIntervalUnit != null) {
      map['customIntervalUnit'] = customIntervalUnit;
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