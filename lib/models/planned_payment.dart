import 'package:budget_tracker/models/transaction.dart';

enum PlannedFrequency { oneTime, monthly, weekly }

class PlannedPayment {
  final String id;
  final String title;
  final TransactionType type;
  final String categoryId;
  final double amount;
  final String paymentMethod;
  final String payee;
  final PlannedFrequency frequency;
  final DateTime dueDate;
  final bool notificationEnabled;
  final String? notes;
  final bool isPaid;
  final DateTime? paidDate;

  PlannedPayment({
    required this.id,
    required this.title,
    required this.type,
    required this.categoryId,
    required this.amount,
    this.paymentMethod = 'Cash',
    this.payee = '',
    this.frequency = PlannedFrequency.oneTime,
    required this.dueDate,
    this.notificationEnabled = false,
    this.notes,
    this.isPaid = false,
    this.paidDate,
  });

  bool get isOverdue =>
      !isPaid && dueDate.isBefore(DateTime.now().subtract(const Duration(days: 0)));

  bool get isDueToday {
    final now = DateTime.now();
    return !isPaid &&
        dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  PlannedPayment copyWith({
    String? id,
    String? title,
    TransactionType? type,
    String? categoryId,
    double? amount,
    String? paymentMethod,
    String? payee,
    PlannedFrequency? frequency,
    DateTime? dueDate,
    bool? notificationEnabled,
    String? notes,
    bool? isPaid,
    DateTime? paidDate,
  }) {
    return PlannedPayment(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      payee: payee ?? this.payee,
      frequency: frequency ?? this.frequency,
      dueDate: dueDate ?? this.dueDate,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notes: notes ?? this.notes,
      isPaid: isPaid ?? this.isPaid,
      paidDate: paidDate ?? this.paidDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'categoryId': categoryId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'payee': payee,
      'frequency': frequency.name,
      'dueDate': dueDate.toIso8601String(),
      'notificationEnabled': notificationEnabled,
      'notes': notes,
      'isPaid': isPaid,
      'paidDate': paidDate?.toIso8601String(),
    };
  }

  factory PlannedPayment.fromJson(Map<String, dynamic> json) {
    return PlannedPayment(
      id: json['id'],
      title: json['title'],
      type: TransactionType.values.byName(json['type'] ?? 'expense'),
      categoryId: json['categoryId'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'Cash',
      payee: json['payee'] ?? '',
      frequency: PlannedFrequency.values.byName(json['frequency'] ?? 'oneTime'),
      dueDate: DateTime.parse(json['dueDate']),
      notificationEnabled: json['notificationEnabled'] ?? false,
      notes: json['notes'],
      isPaid: json['isPaid'] ?? false,
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'categoryId': categoryId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'payee': payee,
      'frequency': frequency.name,
      'dueDate': dueDate.toIso8601String(),
      'notificationEnabled': notificationEnabled ? 1 : 0,
      'notes': notes,
      'isPaid': isPaid ? 1 : 0,
      'paidDate': paidDate?.toIso8601String(),
    };
  }

  factory PlannedPayment.fromMap(Map<String, dynamic> map) {
    return PlannedPayment(
      id: map['id'],
      title: map['title'],
      type: TransactionType.values.byName(map['type'] ?? 'expense'),
      categoryId: map['categoryId'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      payee: map['payee'] ?? '',
      frequency: PlannedFrequency.values.byName(map['frequency'] ?? 'oneTime'),
      dueDate: DateTime.parse(map['dueDate']),
      notificationEnabled: map['notificationEnabled'] == 1,
      notes: map['notes'],
      isPaid: map['isPaid'] == 1,
      paidDate: map['paidDate'] != null ? DateTime.parse(map['paidDate']) : null,
    );
  }
}
