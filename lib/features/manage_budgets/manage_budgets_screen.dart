import 'package:budget_tracker/core/constants.dart';
import 'package:budget_tracker/features/manage_budgets/add_budget_screen.dart';
import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/features/add_transaction/transaction_bloc.dart';
import 'package:budget_tracker/models/budget.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_tracker/features/manage_budgets/budget_bloc.dart';

class ManageBudgetsScreen extends StatelessWidget {
  const ManageBudgetsScreen({super.key});

  void _showTemplatesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final templates = BudgetTemplate.templates;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Budget Templates',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: templates.length,
              itemBuilder: (itemContext, index) {
                final template = templates[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      template.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          template.description,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: template.items.map((item) {
                            String emoji = '📌';
                            if (item.categoryId == 'health') {
                              emoji = '💊';
                            }
                            if (item.categoryId == 'food') {
                              emoji = '🍔';
                            }
                            if (item.categoryId == 'bills') {
                              emoji = '💡';
                            }
                            if (item.categoryId == 'shopping') {
                              emoji = '🛍️';
                            }
                            if (item.categoryId == 'transport') {
                              emoji = '🚗';
                            }
                            if (item.categoryId == 'entertainment') {
                              emoji = '🍿';
                            }
                            if (item.categoryId == 'education') {
                              emoji = '🎓';
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$emoji Rs.${item.amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(dialogContext);
                      _confirmTemplateApplication(context, template);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  void _confirmTemplateApplication(
    BuildContext context,
    BudgetTemplate template,
  ) {
    // Capture references while context is still valid to avoid
    // "Looking up a deactivated widget's ancestor" crash
    final budgetBloc = context.read<BudgetBloc>();
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Confirm Overwrite'),
          content: Text(
            'Applying the "${template.name}" template will delete all your current budget configurations. Are you sure you want to proceed?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                budgetBloc.add(ApplyTemplate(template: template));
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Applied "${template.name}" template successfully!'),
                  ),
                );
              },
              child: const Text('Overwrite'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Manage Budgets',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Apply Template',
            icon: const Icon(Icons.auto_awesome, color: Colors.amber),
            onPressed: () => _showTemplatesDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, budgetState) {
          return BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, transactionState) {
              return BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, categoryState) {
                  if (budgetState is BudgetLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (budgetState is BudgetLoaded) {
                    if (budgetState.budgets.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No budgets configured.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _showTemplatesDialog(context),
                              icon: const Icon(Icons.auto_awesome),
                              label: const Text('Use a Template'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Get transactions for current month to calculate spent amount dynamically
                    final List<Transaction> currentMonthExpenses =
                        transactionState is TransactionLoaded
                        ? transactionState.transactions
                              .where(
                                (t) =>
                                    t.type == TransactionType.expense &&
                                    t.date.year == now.year &&
                                    t.date.month == now.month,
                              )
                              .toList()
                        : [];

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: budgetState.budgets.length,
                      itemBuilder: (context, index) {
                        final budget = budgetState.budgets[index];
                        final category = categoryState is CategoryLoaded
                            ? categoryState.categories.firstWhere(
                                (c) => c.id == budget.categoryId,
                                orElse: () => Category(
                                  id: budget.categoryId,
                                  name: budget.categoryId,
                                  icon: '📌',
                                  color: '#888888',
                                ),
                              )
                            : Category(
                                id: budget.categoryId,
                                //name: budget.categoryId,
                                name: budget.categoryId == 'overall'
                                    ? 'Overall'
                                    : budget.categoryId,
                                icon: budget.categoryId == 'overall'
                                    ? '💰'
                                    : '📌',
                                color: '#888888',
                              );

                        // Dynamic spentAmount calculation
                        final spentAmount = budget.categoryId == 'overall'
                            ? currentMonthExpenses.fold<double>(
                                0.0,
                                (sum, t) => sum + t.amount,
                              )
                            : currentMonthExpenses
                                  .where(
                                    (t) => t.categoryId == budget.categoryId,
                                  )
                                  .fold<double>(
                                    0.0,
                                    (sum, t) => sum + t.amount,
                                  );

                        final progress = budget.amount > 0
                            ? spentAmount / budget.amount
                            : 0.0;

                        // Priority styling
                        Color priorityBg = Colors.grey.withValues(alpha: 0.1);
                        Color priorityText = Colors.grey;
                        String priorityLabel = 'Low';
                        if (budget.priority == 'High') {
                          priorityBg = Colors.red.withValues(alpha: 0.1);
                          priorityText = Colors.red;
                          priorityLabel = '🔥 High';
                        } else if (budget.priority == 'Medium') {
                          priorityBg = Colors.orange.withValues(alpha: 0.1);
                          priorityText = Colors.orange;
                          priorityLabel = '⚡ Medium';
                        }

                        // Status messages
                        String statusText = '';
                        Color statusColor = Colors.green;
                        if (progress > 1.0) {
                          statusText =
                              'Overspent: Rs. ${spentAmount.toStringAsFixed(0)} / Rs. ${budget.amount.toStringAsFixed(0)}';
                          statusColor = Colors.red;
                        } else if (progress >= 0.8) {
                          statusText =
                              'Risk of overspending: Rs. ${spentAmount.toStringAsFixed(0)} / Rs. ${budget.amount.toStringAsFixed(0)}';
                          statusColor = Colors.orange;
                        } else {
                          statusText =
                              'Expense: Rs. ${spentAmount.toStringAsFixed(0)} / Rs. ${budget.amount.toStringAsFixed(0)}';
                          statusColor = Colors.green;
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Color(
                                          int.parse(
                                                category.color.replaceAll(
                                                  '#',
                                                  '',
                                                ),
                                                radix: 16,
                                              ) +
                                              0xFF000000,
                                        ).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        category.icon,
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                category.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: priorityBg,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  priorityLabel,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: priorityText,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            statusText,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 12,
                                              fontWeight: progress >= 0.8
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.errorColor,
                                      ),
                                      onPressed: () {
                                        context.read<BudgetBloc>().add(
                                          DeleteBudget(id: budget.id),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Budget deleted'),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress.clamp(0.0, 1.0),
                                    minHeight: 6,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  if (budgetState is BudgetError) {
                    return Center(
                      child: Text(
                        budgetState.message,
                        style: const TextStyle(color: AppColors.errorColor),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBudgetScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
