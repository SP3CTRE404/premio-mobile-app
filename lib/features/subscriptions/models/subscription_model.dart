enum BillingCycle {
  monthly,
  quarterly,
  yearly,
  custom; // NEW: Gap 1

  /// Convert from backend string (e.g. "MONTHLY") to enum.
  static BillingCycle fromString(String value) {
    return BillingCycle.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => BillingCycle.monthly,
    );
  }
}

class Subscription {
  final int id;
  final String serviceName;
  final double amount;
  final BillingCycle billingCycle;
  final int? customIntervalDays; // NEW: Gap 12
  final DateTime nextBillingDate;
  final bool isAutoPay;
  final String? ownerName;
  final int? ownerId;
  final String? householdName; // NEW: Based on your backend SubscriptionResponse

  final int? householdId;
  final String status; // NEW: Status field (ACTIVE, EXPIRED, etc.)


  Subscription({
    required this.id,
    required this.serviceName,
    required this.amount,
    required this.billingCycle,
    this.customIntervalDays,
    required this.nextBillingDate,
    required this.isAutoPay,
    this.ownerName,
    this.ownerId,
    this.householdName,
    this.householdId,
    this.status = 'ACTIVE',
  });



  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as int,
      serviceName: json['serviceName'] as String,
      amount: (json['amount'] as num).toDouble(),
      billingCycle: BillingCycle.fromString(json['billingCycle'] as String),
      customIntervalDays: json['customIntervalDays'] as int?,
      nextBillingDate: DateTime.parse(json['nextBillingDate'] as String),
      isAutoPay: json['isAutoPay'] as bool,
      ownerName: json['ownerName'] as String?,
      ownerId: json['ownerId'] as int?,
      householdName: json['householdName'] as String?,
      householdId: json['householdId'] as int?,
      status: json['status'] as String? ?? 'ACTIVE',
    );

  }


  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceName': serviceName,
        'amount': amount,
        'billingCycle': billingCycle.name.toUpperCase(),
        'customIntervalDays': customIntervalDays,
        'nextBillingDate': nextBillingDate.toIso8601String(),
        'isAutoPay': isAutoPay,
        'ownerName': ownerName,
        'ownerId': ownerId,
        'householdName': householdName,
        'householdId': householdId,
        'status': status,
      };



  /// Returns a copy with updated fields.
  Subscription copyWith({
    int? id,
    String? serviceName,
    double? amount,
    BillingCycle? billingCycle,
    int? customIntervalDays,
    DateTime? nextBillingDate,
    bool? isAutoPay,
    String? ownerName,
    int? ownerId,
    String? householdName,
    int? householdId,
    String? status,
  }) {


    return Subscription(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      amount: amount ?? this.amount,
      billingCycle: billingCycle ?? this.billingCycle,
      customIntervalDays: customIntervalDays ?? this.customIntervalDays,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      isAutoPay: isAutoPay ?? this.isAutoPay,
      ownerName: ownerName ?? this.ownerName,
      ownerId: ownerId ?? this.ownerId,
      householdName: householdName ?? this.householdName,
      householdId: householdId ?? this.householdId,
      status: status ?? this.status,
    );

  }

}