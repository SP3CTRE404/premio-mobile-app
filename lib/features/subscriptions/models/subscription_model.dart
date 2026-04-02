enum BillingCycle {
  monthly,
  quarterly,
  yearly;

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
  final DateTime nextBillingDate;
  final bool isAutoPay;
  final String ownerName;

  Subscription({
    required this.id,
    required this.serviceName,
    required this.amount,
    required this.billingCycle,
    required this.nextBillingDate,
    required this.isAutoPay,
    required this.ownerName,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as int,
      serviceName: json['serviceName'] as String,
      amount: (json['amount'] as num).toDouble(),
      billingCycle: BillingCycle.fromString(json['billingCycle'] as String),
      nextBillingDate: DateTime.parse(json['nextBillingDate'] as String),
      isAutoPay: json['isAutoPay'] as bool,
      ownerName: json['ownerName'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceName': serviceName,
        'amount': amount,
        'billingCycle': billingCycle.name,
        'nextBillingDate': nextBillingDate.toIso8601String(),
        'isAutoPay': isAutoPay,
        'ownerName': ownerName,
      };

  /// Returns a copy with updated fields.
  Subscription copyWith({
    int? id,
    String? serviceName,
    double? amount,
    BillingCycle? billingCycle,
    DateTime? nextBillingDate,
    bool? isAutoPay,
    String? ownerName,
  }) {
    return Subscription(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      amount: amount ?? this.amount,
      billingCycle: billingCycle ?? this.billingCycle,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      isAutoPay: isAutoPay ?? this.isAutoPay,
      ownerName: ownerName ?? this.ownerName,
    );
  }
}
