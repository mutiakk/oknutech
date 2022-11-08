class History {
  History({
    this.transactionId,
    this.transactionTime,
    this.type,
    this.amount,
  });

  String? transactionId;
  DateTime? transactionTime;
  String? type;
  int? amount;

  factory History.fromJson(Map<String, dynamic> json) => History(
    transactionId: json["transaction_id"],
    transactionTime: DateTime.parse(json["transaction_time"]),
    type: json["transaction_type"],
    amount: json["amount"],
  );

  Map<String, dynamic> toJson() => {
    "transaction_id": transactionId,
    "transaction_time": transactionTime?.toIso8601String(),
    "transaction_type": type,
    "amount": amount,
  };
}
