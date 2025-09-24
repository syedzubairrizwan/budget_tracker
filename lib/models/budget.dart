class Budget {
  final String id;
  final String categoryId;
  final double amount;
  final double spentAmount;

  Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.spentAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'spentAmount': spentAmount,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      categoryId: map['categoryId'],
      amount: map['amount'],
      spentAmount: map['spentAmount'],
    );
  }
}
