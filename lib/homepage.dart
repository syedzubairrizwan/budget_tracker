import 'package:budget_tracker/features/add_transaction/add_transaction_screen.dart';
import 'package:budget_tracker/features/add_transaction/transaction_bloc.dart';
import 'package:budget_tracker/features/manage_budgets/budget_bloc.dart';
import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/features/manage_categories/manage_categories_screen.dart';
import 'package:budget_tracker/features/manage_budgets/manage_budgets_screen.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:budget_tracker/features/manage_goals/goal_bloc.dart';
import 'package:budget_tracker/features/manage_goals/manage_goals_screen.dart';
import 'package:budget_tracker/features/reporting/reporting_screen.dart';
import 'package:budget_tracker/features/charts/charts_screen.dart';
import 'package:budget_tracker/features/settings/settings_screen.dart';
import 'package:budget_tracker/features/subscriptions/subscription_bloc.dart';
import 'package:budget_tracker/features/subscriptions/subscription_event.dart';
import 'package:budget_tracker/features/subscriptions/subscriptions_screen.dart';
import 'package:budget_tracker/features/profile/profile_screen.dart';
import 'package:budget_tracker/features/insights/insight_bloc.dart';
import 'package:budget_tracker/features/insights/insight_event.dart';
import 'package:budget_tracker/features/insights/insights_section.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:budget_tracker/core/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
//import 'package:budgeting_app/core/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<InsightBloc>().add(LoadInsights());
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: _getBody(),
      bottomNavigationBar: _CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _selectedIndex == 0 ? const _CenterFAB() : null,
    );
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return Stack(
          children: [
            const _GradientHeader(),
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(height: 12),
                      _HeaderRow(),
                      SizedBox(height: 24),
                      _BalanceSection(),
                      SizedBox(height: 20),
                      _ActionButtonsRow(),
                      SizedBox(height: 24),
                      _SummaryCardsRow(),
                      SizedBox(height: 24),
                      InsightsSection(),
                      SizedBox(height: 24),
                      _RecentActivitySection(),
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      case 1:
        return const ChartsScreen();
      case 2:
        return const SettingsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _GradientHeader extends StatelessWidget {
  const _GradientHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6D5DF6), Color(0xFFFCB045)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.grid_view_rounded,
                color: AppColors.primaryColor,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageCategoriesScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.category,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageBudgetsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.account_balance,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageGoalsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.flag,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportingScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.pie_chart,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.read<SubscriptionBloc>().add(LoadSubscriptions());
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.subscriptions,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: (value) {
            context.read<TransactionBloc>().add(SearchTransactions(query: value));
          },
          decoration: InputDecoration(
            hintText: 'Search transactions...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _BalanceSection extends StatelessWidget {
  const _BalanceSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final balance = state is TransactionLoaded
            ? state.transactions.fold<double>(0, (prev, tr) {
                return tr.type == TransactionType.income
                    ? prev + tr.amount
                    : prev - tr.amount;
              })
            : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Balance',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat.currency(symbol: '\$').format(balance),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 38,
                  ),
            ),
          ],
        );
      },
    );
  }
}

class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: Icons.send_rounded,
          label: 'Transfer',
          onTap: () {},
        ),
        const SizedBox(width: 20),
        _ActionButton(icon: Icons.qr_code_scanner, label: 'Scan', onTap: () {}),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 22),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _SummaryCardsRow extends StatelessWidget {
  const _SummaryCardsRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<BudgetBloc, BudgetState>(
          builder: (context, state) {
            if (state is BudgetLoaded) {
              final totalBudget = state.budgets.fold<double>(
                  0, (previousValue, budget) => previousValue + budget.amount);
              final totalSpending = state.budgets.fold<double>(
                  0,
                  (previousValue, budget) =>
                      previousValue + budget.spentAmount);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SummaryCard(
                    title: 'Total Budget',
                    value: '\$${totalBudget.toStringAsFixed(2)}',
                    progress: totalBudget > 0 ? totalSpending / totalBudget : 0,
                  ),
                  const SizedBox(width: 12),
                  _SummaryCard(
                      title: 'Total Spending',
                      value: '\$${totalSpending.toStringAsFixed(2)}'),
                ],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _SummaryCard(
                  title: 'Total Budget',
                  value: '\$0.00',
                  progress: 0,
                ),
                SizedBox(width: 12),
                _SummaryCard(title: 'Total Spending', value: '\$0.00'),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        BlocBuilder<GoalBloc, GoalState>(
          builder: (context, state) {
            if (state is GoalLoaded) {
              final totalTargetAmount = state.goals.fold<double>(0,
                  (previousValue, goal) => previousValue + goal.targetAmount);
              final totalCurrentAmount = state.goals.fold<double>(
                  0,
                  (previousValue, goal) =>
                      previousValue + goal.currentAmount);
              return _SummaryCard(
                title: 'Goal Progress',
                value:
                    '\$${totalCurrentAmount.toStringAsFixed(2)} / \$${totalTargetAmount.toStringAsFixed(2)}',
                progress: totalTargetAmount > 0
                    ? totalCurrentAmount / totalTargetAmount
                    : 0,
              );
            }
            return const _SummaryCard(
              title: 'Goal Progress',
              value: '\$0.00 / \$0.00',
              progress: 0,
            );
          },
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final double? progress;

  const _SummaryCard({
    required this.title,
    required this.value,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.all(14),
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
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (progress != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(
                    begin: 0,
                    end: progress,
                  ),
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryColor),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, transactionState) {
            if (transactionState is TransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (transactionState is TransactionLoaded) {
              if (transactionState.transactions.isEmpty) {
                return const _EmptyState();
              }
              return BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, categoryState) {
                  if (categoryState is CategoryLoaded) {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactionState.transactions.length,
                      itemBuilder: (context, index) {
                        final transaction =
                            transactionState.transactions[index];
                        final category = categoryState.categories.firstWhere(
                          (c) => c.id == transaction.categoryId,
                          orElse: () => Category(
                            id: '',
                            name: 'Unknown',
                            icon: Icons.help.codePoint.toString(),
                          ),
                        );
                        return _ActivityTile(
                          icon: IconData(
                            int.tryParse(category.icon) ?? Icons.help.codePoint,
                            fontFamily: 'MaterialIcons',
                          ),
                          iconBg: Color(0xFFB6F09C),
                          title: transaction.title,
                          subtitle:
                              DateFormat.yMMMd().format(transaction.date),
                          amount:
                              '${transaction.type == TransactionType.income ? '+' : '-'} \$${transaction.amount.toStringAsFixed(2)}',
                          amountColor:
                              transaction.type == TransactionType.income
                                  ? const Color(0xFF34C759)
                                  : const Color(0xFFFF3B30),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              );
            }
            if (transactionState is TransactionError) {
              return Center(child: Text(transactionState.message));
            }
            return const _EmptyState();
          },
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first transaction to get started',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  const _ActivityTile({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
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
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _CustomBottomNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarIcon(
            icon: Icons.home,
            label: 'Home',
            selected: selectedIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavBarIcon(
            icon: Icons.pie_chart,
            label: 'Charts',
            selected: selectedIndex == 1,
            onTap: () => onTap(1),
          ),
          const SizedBox(width: 48), // Space for FAB
          _NavBarIcon(
            icon: Icons.settings,
            label: 'Settings',
            selected: selectedIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavBarIcon(
            icon: Icons.person,
            label: 'Profile',
            selected: selectedIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavBarIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected ? AppColors.primaryColor : AppColors.textGrey,
          ),
          Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primaryColor : AppColors.textGrey,
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterFAB extends StatelessWidget {
  const _CenterFAB();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddTransactionScreen(),
          ),
        );
      },
      backgroundColor: AppColors.primaryColor,
      elevation: 4,
      child: const Icon(Icons.add, size: 28),
    );
  }
}
