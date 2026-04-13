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
  final DateTime purchaseDate;
  final bool isAutoPay;
  final String? ownerName;
  final int? ownerId;
  final String? householdName; // NEW: Based on your backend SubscriptionResponse

  final int? householdId;
  final String status; // NEW: Status field (ACTIVE, EXPIRED, etc.)
  final bool isOverdue;
  final bool isUpcoming;
  final int daysUntilDue;


  Subscription({
    required this.id,
    required this.serviceName,
    required this.amount,
    required this.billingCycle,
    this.customIntervalDays,
    required this.nextBillingDate,
    required this.purchaseDate,
    required this.isAutoPay,
    this.ownerName,
    this.ownerId,
    this.householdName,
    this.householdId,
    this.status = 'ACTIVE',
    this.isOverdue = false,
    this.isUpcoming = false,
    this.daysUntilDue = 0,
  });



  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as int,
      serviceName: json['serviceName'] as String,
      amount: (json['amount'] as num).toDouble(),
      billingCycle: BillingCycle.fromString(json['billingCycle'] as String),
      customIntervalDays: json['customIntervalDays'] as int?,
      nextBillingDate: DateTime.parse(json['nextBillingDate'] as String),
      purchaseDate: json['purchaseDate'] != null 
          ? DateTime.parse(json['purchaseDate'] as String)
          : DateTime.parse(json['nextBillingDate'] as String), // Fallback to nextBillingDate if null
      isAutoPay: json['isAutoPay'] as bool,
      ownerName: json['ownerName'] as String?,
      ownerId: json['ownerId'] as int?,
      householdName: json['householdName'] as String?,
      householdId: json['householdId'] as int?,
      status: json['status'] as String? ?? 'ACTIVE',
      isOverdue: json['isOverdue'] as bool? ?? false,
      isUpcoming: json['isUpcoming'] as bool? ?? false,
      daysUntilDue: json['daysUntilDue'] as int? ?? 0,
    );

  }


  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceName': serviceName,
        'amount': amount,
        'billingCycle': billingCycle.name.toUpperCase(),
        'customIntervalDays': customIntervalDays,
        'nextBillingDate': nextBillingDate.toIso8601String(),
        'purchaseDate': purchaseDate.toIso8601String(),
        'isAutoPay': isAutoPay,
        'ownerName': ownerName,
        'ownerId': ownerId,
        'householdName': householdName,
        'householdId': householdId,
        'status': status,
        'isOverdue': isOverdue,
        'isUpcoming': isUpcoming,
        'daysUntilDue': daysUntilDue,
      };



  /// Returns a copy with updated fields.
  Subscription copyWith({
    int? id,
    String? serviceName,
    double? amount,
    BillingCycle? billingCycle,
    int? customIntervalDays,
    DateTime? nextBillingDate,
    DateTime? purchaseDate,
    bool? isAutoPay,
    String? ownerName,
    int? ownerId,
    String? householdName,
    int? householdId,
    String? status,
    bool? isOverdue,
    bool? isUpcoming,
    int? daysUntilDue,
  }) {


    return Subscription(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      amount: amount ?? this.amount,
      billingCycle: billingCycle ?? this.billingCycle,
      customIntervalDays: customIntervalDays ?? this.customIntervalDays,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      isAutoPay: isAutoPay ?? this.isAutoPay,
      ownerName: ownerName ?? this.ownerName,
      ownerId: ownerId ?? this.ownerId,
      householdName: householdName ?? this.householdName,
      householdId: householdId ?? this.householdId,
      status: status ?? this.status,
      isOverdue: isOverdue ?? this.isOverdue,
      isUpcoming: isUpcoming ?? this.isUpcoming,
      daysUntilDue: daysUntilDue ?? this.daysUntilDue,
    );

  }

}