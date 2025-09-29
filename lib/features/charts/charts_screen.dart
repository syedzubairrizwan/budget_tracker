import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_tracker/core/constants.dart';
import 'package:budget_tracker/features/manage_budgets/budget_bloc.dart';
import 'package:budget_tracker/features/add_transaction/transaction_bloc.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:intl/intl.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Charts & Analytics'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SpendingOverviewCard(),
            const SizedBox(height: 20),
            const _BudgetProgressCard(),
            const SizedBox(height: 20),
            const _CategoryBreakdownCard(),
            const SizedBox(height: 20),
            const _MonthlyTrendsCard(),
          ],
        ),
      ),
    );
  }
}

class _SpendingOverviewCard extends StatelessWidget {
  const _SpendingOverviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state is TransactionLoaded) {
                final thisMonth = DateTime.now();
                final thisMonthTransactions = state.transactions
                    .where((t) => 
                        t.date.year == thisMonth.year && 
                        t.date.month == thisMonth.month)
                    .toList();
                
                final totalSpent = thisMonthTransactions
                    .where((t) => t.type == TransactionType.expense)
                    .fold<double>(0, (sum, t) => sum + t.amount);
                
                final totalIncome = thisMonthTransactions
                    .where((t) => t.type == TransactionType.income)
                    .fold<double>(0, (sum, t) => sum + t.amount);

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatItem(
                          label: 'Total Income',
                          value: '\$${totalIncome.toStringAsFixed(2)}',
                          color: Colors.green,
                        ),
                        _StatItem(
                          label: 'Total Expenses',
                          value: '\$${totalSpent.toStringAsFixed(2)}',
                          color: Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SimpleBarChart(
                      income: totalIncome,
                      expenses: totalSpent,
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  final double income;
  final double expenses;

  const _SimpleBarChart({
    required this.income,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = [income, expenses].reduce((a, b) => a > b ? a : b);
    final incomeHeight = maxValue > 0 ? (income / maxValue) * 100 : 0.0;
    final expensesHeight = maxValue > 0 ? (expenses / maxValue) * 100 : 0.0;

    return Container(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 40,
                height: incomeHeight,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Income',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 40,
                height: expensesHeight,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Expenses',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetProgressCard extends StatelessWidget {
  const _BudgetProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget Progress',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<BudgetBloc, BudgetState>(
            builder: (context, state) {
              if (state is BudgetLoaded) {
                return Column(
                  children: state.budgets.map((budget) {
                    final progress = budget.amount > 0 ? budget.spentAmount / budget.amount : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Budget ${budget.id.substring(0, 8)}',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '\$${budget.spentAmount.toStringAsFixed(2)} / \$${budget.amount.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress > 1.0 ? Colors.red : AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state is TransactionLoaded) {
                final thisMonth = DateTime.now();
                final thisMonthTransactions = state.transactions
                    .where((t) => 
                        t.date.year == thisMonth.year && 
                        t.date.month == thisMonth.month &&
                        t.type == TransactionType.expense)
                    .toList();

                final categoryTotals = <String, double>{};
                for (final transaction in thisMonthTransactions) {
                  categoryTotals[transaction.categoryId] = 
                      (categoryTotals[transaction.categoryId] ?? 0) + transaction.amount;
                }

                final sortedCategories = categoryTotals.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return Column(
                  children: sortedCategories.take(5).map((entry) {
                    final total = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
                    final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(entry.key),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            '\$${entry.value.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = [
      AppColors.primaryColor,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];
    return colors[category.hashCode % colors.length];
  }
}

class _MonthlyTrendsCard extends StatelessWidget {
  const _MonthlyTrendsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Trends',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state is TransactionLoaded) {
                final now = DateTime.now();
                final monthlyData = <String, double>{};
                
                // Get last 6 months data
                for (int i = 5; i >= 0; i--) {
                  final month = DateTime(now.year, now.month - i);
                  final monthKey = DateFormat('MMM yyyy').format(month);
                  
                  final monthTransactions = state.transactions
                      .where((t) => 
                          t.date.year == month.year && 
                          t.date.month == month.month &&
                          t.type == TransactionType.expense)
                      .toList();
                  
                  final monthTotal = monthTransactions
                      .fold<double>(0, (sum, t) => sum + t.amount);
                  
                  monthlyData[monthKey] = monthTotal;
                }

                return Container(
                  height: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: monthlyData.entries.map((entry) {
                      final maxValue = monthlyData.values.reduce((a, b) => a > b ? a : b);
                      final height = maxValue > 0 ? (entry.value / maxValue) * 100 : 0.0;
                      
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 30,
                            height: height,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.key.split(' ')[0], // Just the month
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }
}
