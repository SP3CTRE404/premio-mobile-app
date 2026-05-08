class SubscriptionHistory {
  final int id;
  final int subscriptionId;
  final String serviceName; // Needed for the UI icon and title
  final double amount;
  final DateTime paymentDate;
  final String status;
  final String? currency;

  SubscriptionHistory({
    required this.id,
    required this.subscriptionId,
    required this.serviceName,
    required this.amount,
    required this.paymentDate,
    this.status = 'Paid',
    this.currency,
  });

  factory SubscriptionHistory.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistory(
      id: json['id'] as int,
      subscriptionId: json['subscriptionId'] as int? ?? 0,
      serviceName: json['serviceName'] as String? ?? 'Unknown Service',
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      status: json['status'] as String? ?? 'Paid',
      currency: json['currency'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subscriptionId': subscriptionId,
        'serviceName': serviceName,
        'amount': amount,
        'paymentDate': paymentDate.toIso8601String(),
        'status': status,
        'currency': currency,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionHistory &&
        other.id == id &&
        other.subscriptionId == subscriptionId &&
        other.serviceName == serviceName &&
        other.amount == amount &&
        other.paymentDate == paymentDate &&
        other.status == status &&
        other.currency == currency;
  }

  @override
  int get hashCode => Object.hash(id, subscriptionId, serviceName, amount, paymentDate, status, currency);
}
