import 'dart:math';

import 'package:budget_tracker/models/category.dart';
import 'package:budget_tracker/models/transaction.dart';

class Subscription {
  final String name;
  final double averageAmount;
  final DateTime nextDueDate;

  Subscription({
    required this.name,
    required this.averageAmount,
    required this.nextDueDate,
  });
}

class Insight {
  final String title;
  final String description;

  Insight({required this.title, required this.description});
}

class TransactionAnalysisService {
  /// Checks if a new transaction is a potential duplicate of an existing one.
  Future<bool> isPotentialDuplicate(
    Transaction newTransaction,
    List<Transaction> existingTransactions,
  ) async {
    // ... (existing implementation)
    for (final existingTransaction in existingTransactions) {
      if (existingTransaction.id == newTransaction.id) {
        continue; // Don't compare with itself
      }

      final amountMatches = existingTransaction.amount == newTransaction.amount;
      final categoryMatches =
          existingTransaction.categoryId == newTransaction.categoryId;

      if (amountMatches && categoryMatches) {
        final timeDifference =
            newTransaction.date.difference(existingTransaction.date).inMinutes;
        if (timeDifference.abs() <= 2) {
          return true; // Found a potential duplicate
        }
      }
    }
    return false;
  }

  /// Detects potential subscriptions from a list of transactions.
  Future<List<Subscription>> detectSubscriptions(
      List<Transaction> transactions) async {
    // ... (existing implementation)
    final potentialSubscriptions = <String, List<Transaction>>{};

    // Group transactions by title
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) continue;
      final title = transaction.title.toLowerCase();
      if (!potentialSubscriptions.containsKey(title)) {
        potentialSubscriptions[title] = [];
      }
      potentialSubscriptions[title]!.add(transaction);
    }

    final subscriptions = <Subscription>[];

    potentialSubscriptions.forEach((title, transactionList) {
      if (transactionList.length < 2) {
        return;
      }

      transactionList.sort((a, b) => a.date.compareTo(b.date));

      final intervals = <int>[];
      for (int i = 0; i < transactionList.length - 1; i++) {
        final interval =
            transactionList[i + 1].date.difference(transactionList[i].date).inDays;
        intervals.add(interval);
      }

      final averageInterval =
          intervals.reduce((a, b) => a + b) / intervals.length;

      // Check for monthly subscriptions (28-32 day intervals)
      if (averageInterval >= 28 && averageInterval <= 32) {
        final amounts = transactionList.map((t) => t.amount).toList();
        final averageAmount = amounts.reduce((a, b) => a + b) / amounts.length;

        // Check if amounts are consistent (e.g., within 10% of the average)
        final maxDeviation = amounts.map((a) => (a - averageAmount).abs()).reduce(max);
        if (maxDeviation / averageAmount < 0.1) {
          final lastTransaction = transactionList.last;
          final nextDueDate = lastTransaction.date.add(Duration(days: averageInterval.round()));

          subscriptions.add(Subscription(
            name: lastTransaction.title,
            averageAmount: averageAmount,
            nextDueDate: nextDueDate,
          ));
        }
      }
    });

    return subscriptions;
  }

  /// Generates personalized spending insights from the transaction history.
  Future<List<Insight>> getSpendingInsights(
      List<Transaction> transactions, List<Category> categories) async {
    final insights = <Insight>[];

    // Insight 1: Highest spending category last month
    final now = DateTime.now();
    final startOfThisMonth = DateTime(now.year, now.month, 1);
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);

    final lastMonthExpenses = transactions.where((t) =>
        t.type == TransactionType.expense &&
        !t.date.isBefore(startOfLastMonth) &&
        t.date.isBefore(startOfThisMonth));

    if (lastMonthExpenses.isNotEmpty) {
      final spendingByCategory = <String, double>{};
      for (final expense in lastMonthExpenses) {
        spendingByCategory[expense.categoryId] =
            (spendingByCategory[expense.categoryId] ?? 0) + expense.amount;
      }

      if (spendingByCategory.isNotEmpty) {
        final topCategoryEntry = spendingByCategory.entries
            .reduce((a, b) => a.value > b.value ? a : b);

        final topCategory = categories.firstWhere(
            (c) => c.id == topCategoryEntry.key,
            orElse: () => Category(id: '', name: 'Unknown', icon: ''));

        insights.add(Insight(
          title: 'Top Spending Last Month',
          description:
              'You spent the most on ${topCategory.name} last month. Consider reviewing your budget for this category.',
        ));
      }
    }

    return insights;
  }
}