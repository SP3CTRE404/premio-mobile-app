class SubscriptionHistory {
  final int id;
  final int subscriptionId;
  final String serviceName; // Needed for the UI icon and title
  final double amount;
  final DateTime paymentDate;
  final String status;

  SubscriptionHistory({
    required this.id,
    required this.subscriptionId,
    required this.serviceName,
    required this.amount,
    required this.paymentDate,
    this.status = 'Paid',
  });

  factory SubscriptionHistory.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistory(
      id: json['id'] as int,
      subscriptionId: json['subscriptionId'] as int? ?? 0,
      serviceName: json['serviceName'] as String? ?? 'Unknown Service',
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      status: json['status'] as String? ?? 'Paid',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subscriptionId': subscriptionId,
        'serviceName': serviceName,
        'amount': amount,
        'paymentDate': paymentDate.toIso8601String(),
        'status': status,
      };
}

