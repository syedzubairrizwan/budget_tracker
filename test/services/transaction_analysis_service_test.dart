import 'package:budget_tracker/models/category.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/services/transaction_analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionAnalysisService', () {
    late TransactionAnalysisService analysisService;

    setUp(() {
      analysisService = TransactionAnalysisService();
    });

    group('isPotentialDuplicate', () {
      final t1 = Transaction(
        id: '1',
        title: 'Coffee',
        amount: 5.0,
        date: DateTime.now(),
        categoryId: 'food',
        type: TransactionType.expense,
      );

      test('should return true for a duplicate transaction', () async {
        final t2 = Transaction(
          id: '2',
          title: 'Coffee',
          amount: 5.0,
          date: DateTime.now().add(const Duration(seconds: 30)),
          categoryId: 'food',
          type: TransactionType.expense,
        );
        final result = await analysisService.isPotentialDuplicate(t2, [t1]);
        expect(result, isTrue);
      });

      test('should return false for a non-duplicate transaction', () async {
        final t2 = Transaction(
          id: '2',
          title: 'Lunch',
          amount: 15.0,
          date: DateTime.now().add(const Duration(days: 1)),
          categoryId: 'food',
          type: TransactionType.expense,
        );
        final result = await analysisService.isPotentialDuplicate(t2, [t1]);
        expect(result, isFalse);
      });
    });

    group('detectSubscriptions', () {
      test('should detect a monthly subscription', () async {
        final transactions = [
          Transaction(id: '1', title: 'Netflix', amount: 15.99, date: DateTime(2023, 1, 15), categoryId: 'entertainment', type: TransactionType.expense),
          Transaction(id: '2', title: 'Netflix', amount: 15.99, date: DateTime(2023, 2, 15), categoryId: 'entertainment', type: TransactionType.expense),
          Transaction(id: '3', title: 'Netflix', amount: 15.99, date: DateTime(2023, 3, 15), categoryId: 'entertainment', type: TransactionType.expense),
        ];
        final subscriptions = await analysisService.detectSubscriptions(transactions);
        expect(subscriptions, hasLength(1));
        expect(subscriptions.first.name, 'Netflix');
      });

      test('should not detect non-recurring transactions as subscriptions', () async {
        final transactions = [
          Transaction(id: '1', title: 'Coffee', amount: 5.0, date: DateTime(2023, 1, 15), categoryId: 'food', type: TransactionType.expense),
          Transaction(id: '2', title: 'Lunch', amount: 12.0, date: DateTime(2023, 2, 1), categoryId: 'food', type: TransactionType.expense),
        ];
        final subscriptions = await analysisService.detectSubscriptions(transactions);
        expect(subscriptions, isEmpty);
      });
    });

    group('getSpendingInsights', () {
      test('should identify the highest spending category from last month', () async {
        final now = DateTime.now();
        final lastMonth = DateTime(now.year, now.month - 1);
        final categories = [
          Category(id: 'food', name: 'Food & Dining', icon: ''),
          Category(id: 'shopping', name: 'Shopping', icon: ''),
        ];
        final transactions = [
          Transaction(id: '1', title: 'Groceries', amount: 100.0, date: lastMonth, categoryId: 'food', type: TransactionType.expense),
          Transaction(id: '2', title: 'Dinner', amount: 50.0, date: lastMonth, categoryId: 'food', type: TransactionType.expense),
          Transaction(id: '3', title: 'Clothes', amount: 80.0, date: lastMonth, categoryId: 'shopping', type: TransactionType.expense),
        ];

        final insights = await analysisService.getSpendingInsights(transactions, categories);
        expect(insights, hasLength(1));
        expect(insights.first.title, 'Top Spending Last Month');
        expect(insights.first.description, contains('Food & Dining'));
      });
    });
  });
}