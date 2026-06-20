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
import 'package:intl/intl.dart';

class MonthlyBudgetsScreen extends StatefulWidget {
  const MonthlyBudgetsScreen({super.key});

  @override
  State<MonthlyBudgetsScreen> createState() => _MonthlyBudgetsScreenState();
}

class _MonthlyBudgetsScreenState extends State<MonthlyBudgetsScreen> {
  String _selectedCategoryId = 'overall'; // Defaults to overall, or first category if overall isn't set

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
                setState(() {
                  _selectedCategoryId = 'overall';
                });
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
          'Monthly Budgets',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Budget',
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddBudgetScreen()),
              );
            },
          ),
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

                    // Adjust selected category if not present in budgets
                    final budgetCategoryIds = budgetState.budgets.map((b) => b.categoryId).toList();
                    if (!budgetCategoryIds.contains(_selectedCategoryId) && budgetState.budgets.isNotEmpty) {
                      _selectedCategoryId = budgetCategoryIds.first;
                    }

                    // Find active budget
                    final activeBudget = budgetState.budgets.firstWhere(
                      (b) => b.categoryId == _selectedCategoryId,
                      orElse: () => budgetState.budgets.first,
                    );

                    // Category scroll catalogue data
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Scroll catalogue of selected budget categories
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: budgetState.budgets.length,
                              itemBuilder: (context, index) {
                                final budget = budgetState.budgets[index];
                                final isSelected = budget.categoryId == _selectedCategoryId;

                                final category = categoryState is CategoryLoaded
                                    ? categoryState.categories.firstWhere(
                                        (c) => c.id == budget.categoryId,
                                        orElse: () => Category(
                                          id: budget.categoryId,
                                          name: budget.categoryId == 'overall'
                                              ? 'Overall'
                                              : budget.categoryId,
                                          icon: budget.categoryId == 'overall'
                                              ? '💰'
                                              : '📌',
                                          color: '#888888',
                                        ),
                                      )
                                    : Category(
                                        id: budget.categoryId,
                                        name: budget.categoryId == 'overall'
                                            ? 'Overall'
                                            : budget.categoryId,
                                        icon: budget.categoryId == 'overall'
                                            ? '💰'
                                            : '📌',
                                        color: '#888888',
                                      );

                                final double spentAmount = budget.categoryId == 'overall'
                                    ? currentMonthExpenses.fold<double>(
                                        0.0,
                                        (sum, t) => sum + t.amount,
                                      )
                                    : currentMonthExpenses
                                        .where((t) => t.categoryId == budget.categoryId)
                                        .fold<double>(
                                          0.0,
                                          (sum, t) => sum + t.amount,
                                        );

                                final progress = budget.amount > 0
                                    ? (spentAmount / budget.amount)
                                    : 0.0;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryId = budget.categoryId;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    width: 110,
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? const LinearGradient(
                                              colors: [Color(0xFF2F69FD), Color(0xFF1A6BFF)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      color: isSelected
                                          ? null
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : Colors.grey.withValues(alpha: 0.2),
                                        width: 1.5,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF2F69FD).withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              )
                                            ]
                                          : [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.03),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              )
                                            ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          category.icon,
                                          style: const TextStyle(fontSize: 22),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          category.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: isSelected ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(2),
                                          child: LinearProgressIndicator(
                                            value: progress.clamp(0.0, 1.0),
                                            minHeight: 4,
                                            backgroundColor: isSelected
                                                ? Colors.white24
                                                : Colors.grey[200],
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              isSelected
                                                  ? Colors.white
                                                  : (progress > 1.0
                                                      ? Colors.red
                                                      : (progress >= 0.8
                                                          ? Colors.orange
                                                          : Colors.green)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Active budget details and list of deducting expenses
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildActiveBudgetCard(context, activeBudget, categoryState, currentMonthExpenses),
                                const SizedBox(height: 20),
                                Text(
                                  'Deducting Expenses',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                _buildDeductingExpensesList(context, activeBudget, currentMonthExpenses),
                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
                        ),
                      ],
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
    );
  }

  Widget _buildActiveBudgetCard(
    BuildContext context,
    Budget budget,
    CategoryState categoryState,
    List<Transaction> currentMonthExpenses,
  ) {
    final category = categoryState is CategoryLoaded
        ? categoryState.categories.firstWhere(
            (c) => c.id == budget.categoryId,
            orElse: () => Category(
              id: budget.categoryId,
              name: budget.categoryId == 'overall' ? 'Overall' : budget.categoryId,
              icon: budget.categoryId == 'overall' ? '💰' : '📌',
              color: '#888888',
            ),
          )
        : Category(
            id: budget.categoryId,
            name: budget.categoryId == 'overall' ? 'Overall' : budget.categoryId,
            icon: budget.categoryId == 'overall' ? '💰' : '📌',
            color: '#888888',
          );

    final double spentAmount = budget.categoryId == 'overall'
        ? currentMonthExpenses.fold<double>(
            0.0,
            (sum, t) => sum + t.amount,
          )
        : currentMonthExpenses
            .where((t) => t.categoryId == budget.categoryId)
            .fold<double>(
              0.0,
              (sum, t) => sum + t.amount,
            );

    final remainingAmount = budget.amount - spentAmount;
    final progress = budget.amount > 0 ? (spentAmount / budget.amount) : 0.0;
    final isOver = spentAmount > budget.amount;

    Color statusColor = Colors.green;
    String statusMsg = 'Safe Budget';
    if (progress > 1.0) {
      statusColor = Colors.red;
      statusMsg = 'Overspent!';
    } else if (progress >= 0.8) {
      statusColor = Colors.orange;
      statusMsg = 'Risk of Overspending';
    }

    // Priority badge styles
    Color priorityColor = Colors.grey;
    if (budget.priority == 'High') priorityColor = Colors.red;
    if (budget.priority == 'Medium') priorityColor = Colors.orange;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(category.color.replaceAll('#', ''), radix: 16) + 0xFF000000,
                    ).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    category.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            category.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: priorityColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              budget.priority,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: priorityColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusMsg,
                        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.errorColor),
                  onPressed: () {
                    context.read<BudgetBloc>().add(DeleteBudget(id: budget.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Budget deleted')),
                    );
                    setState(() {
                      _selectedCategoryId = 'overall';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Spent Amount', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${spentAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total Budget Limit', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${budget.amount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% consumed',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Text(
                  isOver
                      ? 'Rs. ${(-remainingAmount).toStringAsFixed(0)} Over limit'
                      : 'Rs. ${remainingAmount.toStringAsFixed(0)} Remaining',
                  style: TextStyle(
                    color: isOver ? Colors.red : AppColors.successColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeductingExpensesList(
    BuildContext context,
    Budget budget,
    List<Transaction> currentMonthExpenses,
  ) {
    final filteredExpenses = budget.categoryId == 'overall'
        ? currentMonthExpenses
        : currentMonthExpenses.where((t) => t.categoryId == budget.categoryId).toList();

    if (filteredExpenses.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 16),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green, size: 40),
                SizedBox(height: 10),
                Text(
                  'No expenses recorded under this category yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredExpenses.length,
      itemBuilder: (context, index) {
        final transaction = filteredExpenses[index];
        final formattedDate = DateFormat('MMM dd, yyyy').format(transaction.date);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              child: const Icon(Icons.arrow_downward, color: Colors.red, size: 18),
            ),
            title: Text(
              transaction.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              formattedDate,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: Text(
              '- Rs. ${transaction.amount.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }
}
