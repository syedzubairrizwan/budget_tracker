enum TransactionType { income, expense }

enum SplitStatus { none, pending, settled, denied }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final TransactionType type;
  final String? details;

  // Split Bill fields (enhanced)
  final bool isSplit;
  final String? splitWith;
  final double? splitAmount;
  // New Firebase-backed split fields
  final String? splitWithUserId;
  final String? splitWithName;
  final String? splitWithAvatar;
  final String? splitGroupId;
  final SplitStatus splitStatus;
  final bool isCreator;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.type = TransactionType.expense,
    this.details,
    this.isSplit = false,
    this.splitWith,
    this.splitAmount,
    this.splitWithUserId,
    this.splitWithName,
    this.splitWithAvatar,
    this.splitGroupId,
    this.splitStatus = SplitStatus.none,
    this.isCreator = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'type': type.name,
      'details': details,
      'isSplit': isSplit ? 1 : 0,
      'splitWith': splitWith,
      'splitAmount': splitAmount,
      // New fields for split
      'splitWithUserId': splitWithUserId,
      'splitWithName': splitWithName,
      'splitWithAvatar': splitWithAvatar,
      'splitGroupId': splitGroupId,
      'splitStatus': splitStatus.name,
      'isCreator': isCreator ? 1 : 0,
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
      details: map['details'],
      isSplit: map['isSplit'] == 1,
      splitWith: map['splitWith'],
      splitAmount: map['splitAmount'],
      // New fields
      splitWithUserId: map['splitWithUserId'],
      splitWithName: map['splitWithName'],
      splitWithAvatar: map['splitWithAvatar'],
      splitGroupId: map['splitGroupId'],
      splitStatus: map['splitStatus'] != null
          ? SplitStatus.values.firstWhere(
              (e) => e.name == map['splitStatus'],
              orElse: () => SplitStatus.none,
            )
          : SplitStatus.none,
      isCreator: map['isCreator'] == null ? true : map['isCreator'] == 1,
    );
  }
}
