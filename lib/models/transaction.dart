enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final TransactionType type;

  // Split Bill fields
  final bool isSplit;
  final String? splitWith;
  final double? splitAmount;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.type = TransactionType.expense,
    this.isSplit = false,
    this.splitWith,
    this.splitAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'type': type.name,
      'isSplit': isSplit ? 1 : 0,
      'splitWith': splitWith,
      'splitAmount': splitAmount,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      categoryId: map['categoryId'],
      type: TransactionType.values.byName(map['type'] ?? 'expense'),
      isSplit: map['isSplit'] == 1,
      splitWith: map['splitWith'],
      splitAmount: map['splitAmount'],
    );
  }
}
