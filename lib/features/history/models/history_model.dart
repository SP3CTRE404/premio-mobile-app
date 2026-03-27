class SubscriptionHistory {
  final int id;
  final double amount;
  final DateTime paymentDate;

  SubscriptionHistory({
    required this.id,
    required this.amount,
    required this.paymentDate,
  });

  factory SubscriptionHistory.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistory(
      id: json['id'] as int,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'paymentDate': paymentDate.toIso8601String(),
      };
}
