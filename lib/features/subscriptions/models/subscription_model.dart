enum BillingCycle {
  monthly,
  quarterly,
  yearly,
  custom,
  oneTime; // NEW

  /// Convert from backend string (e.g. "MONTHLY") to enum.
  static BillingCycle fromString(String value) {
    if (value.toUpperCase() == 'ONE_TIME') return BillingCycle.oneTime;
    return BillingCycle.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => BillingCycle.monthly,
    );
  }

  /// Convert to backend string format
  String toJsonString() {
    if (this == BillingCycle.oneTime) return 'ONE_TIME';
    return name.toUpperCase();
  }
}

class Subscription {
  final int id;
  final String serviceName;
  final double amount;
  final BillingCycle billingCycle;
  final int? customIntervalDays;
  final String? customIntervalUnit;
  final DateTime? nextBillingDate;
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
    this.customIntervalUnit,
    this.nextBillingDate,
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
      customIntervalUnit: json['customIntervalUnit'] as String?,
      nextBillingDate: json['nextBillingDate'] != null ? DateTime.parse(json['nextBillingDate'] as String) : null,
      purchaseDate: json['purchaseDate'] != null 
          ? DateTime.parse(json['purchaseDate'] as String)
          : (json['nextBillingDate'] != null ? DateTime.parse(json['nextBillingDate'] as String) : DateTime.now()), // Fallback
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
        'billingCycle': billingCycle.toJsonString(),
        'customIntervalDays': customIntervalDays,
        'customIntervalUnit': customIntervalUnit,
        'nextBillingDate': nextBillingDate?.toIso8601String(),
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
    String? customIntervalUnit,
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
      customIntervalUnit: customIntervalUnit ?? this.customIntervalUnit,
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Subscription &&
        other.id == id &&
        other.serviceName == serviceName &&
        other.amount == amount &&
        other.billingCycle == billingCycle &&
        other.customIntervalDays == customIntervalDays &&
        other.customIntervalUnit == customIntervalUnit &&
        other.nextBillingDate == nextBillingDate &&
        other.purchaseDate == purchaseDate &&
        other.isAutoPay == isAutoPay &&
        other.ownerName == ownerName &&
        other.ownerId == ownerId &&
        other.householdName == householdName &&
        other.householdId == householdId &&
        other.status == status &&
        other.isOverdue == isOverdue &&
        other.isUpcoming == isUpcoming &&
        other.daysUntilDue == daysUntilDue;
  }

  @override
  int get hashCode => Object.hash(
        id, serviceName, amount, billingCycle,
        customIntervalDays, customIntervalUnit,
        nextBillingDate, purchaseDate, isAutoPay,
        ownerName, ownerId, householdName,
        householdId, status, isOverdue, isUpcoming,
      );
}