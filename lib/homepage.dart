import 'package:budget_tracker/features/add_transaction/add_transaction_screen.dart';
import 'package:budget_tracker/features/add_transaction/transaction_bloc.dart';
import 'package:budget_tracker/features/manage_budgets/budget_bloc.dart';
import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/features/manage_budgets/add_budget_screen.dart';
import 'package:budget_tracker/features/manage_budgets/monthly_budgets_screen.dart';
import 'package:budget_tracker/models/budget.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:budget_tracker/features/manage_goals/goal_bloc.dart';
import 'package:budget_tracker/features/manage_goals/manage_goals_screen.dart';
import 'package:budget_tracker/features/settings/settings_screen.dart';
import 'package:budget_tracker/features/profile/profile_screen.dart';
import 'package:budget_tracker/features/planned_payments/planned_payments_screen.dart';
import 'package:budget_tracker/features/insights/insight_bloc.dart';
import 'package:budget_tracker/features/insights/insight_event.dart';
import 'package:budget_tracker/features/insights/insights_section.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/services/notification_service.dart';
// ignore: unused_import
import 'package:budget_tracker/services/ocr_service.dart';
import 'package:flutter/material.dart';
import 'package:budget_tracker/core/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:budget_tracker/features/voice_assistant/voice_recording_dialog.dart';
import 'package:budget_tracker/services/ai_parser_service.dart';


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
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionLoaded) {
          context.read<BudgetBloc>().add(LoadBudgets());
          context.read<InsightBloc>().add(LoadInsights());
        }
      },
      child: Scaffold(
        body: _getBody(),
        bottomNavigationBar: _CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: const _CenterFAB(),
      ),
    );
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return const _DashboardTab();
      case 1:
        return const MonthlyBudgetsScreen();
      case 2:
        return const _AnalyticsTab();
      case 3:
        return const PlannedPaymentsScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ActionButtonsRow(),
                  const SizedBox(height: 24),
                  const _SummaryCardsRow(),
                  const SizedBox(height: 24),
                  const BudgetOverviewCard(),
                  const SizedBox(height: 24),
                  const InsightsSection(),
                  const SizedBox(height: 24),
                  const _RecentActivitySection(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2F69FD), Color(0xFF1A6BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              const Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.settings, color: Colors.white, size: 20),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Center(child: _DashboardBalanceSection()),
          const SizedBox(height: 24),
          const _DashboardSearchField(),
        ],
      ),
    );
  }
}

class _DashboardBalanceSection extends StatelessWidget {
  const _DashboardBalanceSection();

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
          children: [
            Text(
              'Total Balance',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              NumberFormat.currency(symbol: 'Rs. ').format(balance),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DashboardSearchField extends StatelessWidget {
  const _DashboardSearchField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) {
        context.read<TransactionBloc>().add(SearchTransactions(query: value));
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search transactions...',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white38, width: 1),
        ),
      ),
    );
  }
}

class BudgetsTab extends StatelessWidget {
  const BudgetsTab();

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
              Text('Budget Templates', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(template.description, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: template.items.map((item) {
                            String emoji = '📌';
                            if (item.categoryId == 'health') emoji = '💊';
                            if (item.categoryId == 'food') emoji = '🍔';
                            if (item.categoryId == 'bills') emoji = '💡';
                            if (item.categoryId == 'shopping') emoji = '🛍️';
                            if (item.categoryId == 'transport') emoji = '🚗';
                            if (item.categoryId == 'entertainment') emoji = '🍿';
                            if (item.categoryId == 'education') emoji = '🎓';
                            
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$emoji Rs.${item.amount.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
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

  void _confirmTemplateApplication(BuildContext context, BudgetTemplate template) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                final outerContext = context;
                outerContext.read<BudgetBloc>().add(ApplyTemplate(template: template));
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(outerContext).showSnackBar(
                  SnackBar(content: Text('Applied "${template.name}" template successfully!')),
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

    return SafeArea(
      child: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, budgetState) {
          return BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, transactionState) {
              return BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, categoryState) {
                  double totalBudgetLimit = 0;
                  double totalSpent = 0;

                  // Get active transactions in this tab to dynamically count total spent
                  final List<Transaction> activeExpenses = transactionState is TransactionLoaded
                      ? transactionState.transactions
                          .where((t) => t.type == TransactionType.expense &&
                                        t.date.year == now.year &&
                                        t.date.month == now.month)
                          .toList()
                      : [];

                  if (budgetState is BudgetLoaded) {
                    totalBudgetLimit = budgetState.budgets.fold(
                      0,
                      (sum, b) => sum + b.amount,
                    );
                    
                    // Sum the dynamically calculated spent amounts for all budgets
                    for (final budget in budgetState.budgets) {
                      final spentForCategory = activeExpenses
                          .where((t) => t.categoryId == budget.categoryId)
                          .fold<double>(0.0, (sum, t) => sum + t.amount);
                      totalSpent += spentForCategory;
                    }
                  }

                  final spentPercentage = totalBudgetLimit > 0
                      ? (totalSpent / totalBudgetLimit)
                      : 0.0;
                  final remainingAmount = totalBudgetLimit - totalSpent;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSummaryCard(
                                context,
                                totalBudgetLimit,
                                totalSpent,
                                spentPercentage,
                                remainingAmount,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Budget Progress',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        tooltip: 'Apply Template',
                                        icon: const Icon(
                                          Icons.auto_awesome_outlined,
                                          color: Colors.orange,
                                        ),
                                        onPressed: () => _showTemplatesDialog(context),
                                      ),
                                      IconButton(
                                        tooltip: 'Add Budget',
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          color: AppColors.primaryColor,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const AddBudgetScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (budgetState is BudgetLoading)
                                const Center(child: CircularProgressIndicator())
                              else if (budgetState is BudgetLoaded &&
                                  budgetState.budgets.isNotEmpty)
                                ...budgetState.budgets.map((budget) {
                                  final category =
                                      categoryState is CategoryLoaded
                                      ? categoryState.categories.firstWhere(
                                          (c) => c.id == budget.categoryId,
                                          orElse: () => Category(
                                            id: '',
                                            name: 'Unknown',
                                            icon: '❓',
                                            color: '#888888',
                                          ),
                                        )
                                      : Category(
                                          id: '',
                                          name: 'Unknown',
                                          icon: '❓',
                                          color: '#888888',
                                        );

                                  // Dynamically calculate spent amount from loaded transactions
                                  final double spentAmount = activeExpenses
                                      .where((t) => t.categoryId == budget.categoryId)
                                      .fold<double>(0.0, (sum, t) => sum + t.amount);

                                  final progress = budget.amount > 0
                                      ? (spentAmount / budget.amount)
                                      : 0.0;
                                  final isOver = spentAmount > budget.amount;

                                  // Priority Badge Colors
                                  Color badgeBg = Colors.grey.withValues(alpha: 0.1);
                                  Color badgeText = Colors.grey;
                                  String badgeLabel = 'Low';
                                  if (budget.priority == 'High') {
                                    badgeBg = Colors.red.withValues(alpha: 0.1);
                                    badgeText = Colors.red;
                                    badgeLabel = '🔥 High';
                                  } else if (budget.priority == 'Medium') {
                                    badgeBg = Colors.orange.withValues(alpha: 0.1);
                                    badgeText = Colors.orange;
                                    badgeLabel = '⚡ Medium';
                                  }

                                  // Status message and color coding
                                  String statusMessage = '';
                                  Color statusColor = Colors.green;
                                  if (progress > 1.0) {
                                    statusMessage = 'Overspent: Rs. ${spentAmount.toStringAsFixed(0)} / Rs. ${budget.amount.toStringAsFixed(0)}';
                                    statusColor = Colors.red;
                                  } else if (progress >= 0.8) {
                                    statusMessage = 'Risk of overspending: Rs. ${spentAmount.toStringAsFixed(0)} / Rs. ${budget.amount.toStringAsFixed(0)}';
                                    statusColor = Colors.orange;
                                  } else {
                                    statusMessage = 'Expense: Rs. ${spentAmount.toStringAsFixed(0)} / Rs. ${budget.amount.toStringAsFixed(0)}';
                                    statusColor = Colors.green;
                                  }

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Color(
                                                    int.parse(
                                                          category.color
                                                              .replaceAll(
                                                                '#',
                                                                '',
                                                              ),
                                                          radix: 16,
                                                        ) +
                                                        0xFF000000,
                                                  ).withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  category.icon,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                  ),
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
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: badgeBg,
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                          child: Text(
                                                            badgeLabel,
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                              color: badgeText,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      statusMessage,
                                                      style: TextStyle(
                                                        color: statusColor,
                                                        fontWeight: progress >= 0.8 ? FontWeight.bold : FontWeight.normal,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    isOver
                                                        ? 'Rs. ${(spentAmount - budget.amount).toStringAsFixed(0)} over'
                                                        : 'Rs. ${(budget.amount - spentAmount).toStringAsFixed(0)} left',
                                                    style: TextStyle(
                                                      color: isOver
                                                          ? Colors.red
                                                          : AppColors.successColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
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
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(statusColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                })
                              else
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 40),
                                    child: Text('No budgets configured.'),
                                  ),
                                ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2F69FD), Color(0xFF1A6BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Text(
          'Budgets',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    double limit,
    double spent,
    double percentage,
    double remaining,
  ) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Budgets Summary',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Text(
                        'This Month',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CustomPaint(
                    painter: DonutChartPainter(
                      percentage: percentage,
                      activeColor: AppColors.primaryColor,
                      backgroundColor: Colors.grey[200]!,
                      strokeWidth: 10,
                    ),
                    child: Center(
                      child: Text(
                        '${(percentage * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overall Budget Status',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Spent Rs. ${spent.toStringAsFixed(0)} of Rs. ${limit.toStringAsFixed(0)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rs. ${remaining.toStringAsFixed(2)} Remaining',
                        style: TextStyle(
                          color: remaining < 0
                              ? Colors.red
                              : AppColors.successColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final double percentage;
  final Color activeColor;
  final Color backgroundColor;
  final double strokeWidth;

  DonutChartPainter({
    required this.percentage,
    required this.activeColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final double sweepAngle = 2 * 3.1415926535 * percentage.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _AnalyticsTab extends StatefulWidget {
  const _AnalyticsTab();

  @override
  State<_AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<_AnalyticsTab> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, transactionState) {
          double totalIncome = 0;
          double totalExpense = 0;
          final List<Transaction> filteredTransactions = [];

          if (transactionState is TransactionLoaded) {
            for (final t in transactionState.transactions) {
              if (t.date.year == _selectedMonth.year &&
                  t.date.month == _selectedMonth.month) {
                filteredTransactions.add(t);
                if (t.type == TransactionType.income) {
                  totalIncome += t.amount;
                } else {
                  totalExpense += t.amount;
                }
              }
            }
          }

          final generalBalance = totalIncome - totalExpense;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, generalBalance),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Income',
                              value: 'Rs. ${totalIncome.toStringAsFixed(0)}',
                              icon: Icons.arrow_upward_rounded,
                              iconColor: Colors.green,
                              transactionCount: filteredTransactions
                                  .where(
                                    (t) => t.type == TransactionType.income,
                                  )
                                  .length,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Expenses',
                              value: 'Rs. ${totalExpense.toStringAsFixed(0)}',
                              icon: Icons.arrow_downward_rounded,
                              iconColor: Colors.red,
                              transactionCount: filteredTransactions
                                  .where(
                                    (t) => t.type == TransactionType.expense,
                                  )
                                  .length,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildComparisonChartCard(context, filteredTransactions),
                      const SizedBox(height: 24),
                      _buildCategoryBreakdownCard(
                        context,
                        filteredTransactions,
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double balance) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2F69FD), Color(0xFF1A6BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Column(
        children: [
          Text(
            'Analytics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month - 1,
                    );
                  });
                },
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.calendar_today,
                color: Colors.white.withValues(alpha: 0.7),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMMM yyyy').format(_selectedMonth),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month + 1,
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${balance >= 0 ? '+' : '-'} Rs. ${balance.abs().toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'General Balance',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required int transactionCount,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: iconColor.withValues(alpha: 0.15),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$transactionCount Transactions',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonChartCard(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    final daysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    ).day;
    final incomeData = List<double>.filled(daysInMonth, 0);
    final expenseData = List<double>.filled(daysInMonth, 0);

    for (final t in transactions) {
      final day = t.date.day - 1;
      if (day >= 0 && day < daysInMonth) {
        if (t.type == TransactionType.income) {
          incomeData[day] += t.amount;
        } else {
          expenseData[day] += t.amount;
        }
      }
    }

    double cumIncome = 0;
    double cumExpense = 0;
    final List<double> incomeLine = [];
    final List<double> expenseLine = [];

    for (int i = 0; i < daysInMonth; i++) {
      cumIncome += incomeData[i];
      cumExpense += expenseData[i];
      incomeLine.add(cumIncome);
      expenseLine.add(cumExpense);
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Comparison Chart',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    _buildLegendItem('Income', Colors.green),
                    const SizedBox(width: 12),
                    _buildLegendItem('Expenses', Colors.red),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              width: double.infinity,
              child: CustomPaint(
                painter: _LineChartPainter(
                  incomeData: incomeLine,
                  expenseData: expenseLine,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1 ${DateFormat('MMM').format(_selectedMonth)}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  '${daysInMonth ~/ 2} ${DateFormat('MMM').format(_selectedMonth)}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  '$daysInMonth ${DateFormat('MMM').format(_selectedMonth)}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdownCard(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();
    final Map<String, double> categoryTotals = {};

    for (final t in expenses) {
      categoryTotals[t.categoryId] =
          (categoryTotals[t.categoryId] ?? 0) + t.amount;
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalSpent = categoryTotals.values.fold<double>(
      0.0,
      (sum, val) => sum + val,
    );

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Breakdown',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (expenses.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    'No expenses recorded for this month.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, categoryState) {
                  return Column(
                    children: sortedEntries.map((entry) {
                      final category = categoryState is CategoryLoaded
                          ? categoryState.categories.firstWhere(
                              (c) => c.id == entry.key,
                              orElse: () => Category(
                                id: '',
                                name: 'Unknown',
                                icon: '❓',
                                color: '#888888',
                              ),
                            )
                          : Category(
                              id: '',
                              name: 'Unknown',
                              icon: '❓',
                              color: '#888888',
                            );

                      final percentage = totalSpent > 0
                          ? (entry.value / totalSpent) * 100
                          : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  category.icon,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    category.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Rs. ${entry.value.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${percentage.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                minHeight: 4,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(
                                    int.parse(
                                          category.color.replaceAll('#', ''),
                                          radix: 16,
                                        ) +
                                        0xFF000000,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> incomeData;
  final List<double> expenseData;

  _LineChartPainter({required this.incomeData, required this.expenseData});

  @override
  void paint(Canvas canvas, Size size) {
    if (incomeData.isEmpty || expenseData.isEmpty) return;

    final maxVal = [
      ...incomeData,
      ...expenseData,
      1000.0,
    ].reduce((a, b) => a > b ? a : b);

    final width = size.width;
    final height = size.height;

    final incomePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final expensePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final incomeFillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.green.withValues(alpha: 0.2),
          Colors.green.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    final expenseFillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.red.withValues(alpha: 0.2),
          Colors.red.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    _drawPath(canvas, size, incomeData, maxVal, incomePaint, incomeFillPaint);
    _drawPath(
      canvas,
      size,
      expenseData,
      maxVal,
      expensePaint,
      expenseFillPaint,
    );
  }

  void _drawPath(
    Canvas canvas,
    Size size,
    List<double> data,
    double maxVal,
    Paint strokePaint,
    Paint fillPaint,
  ) {
    final points = <Offset>[];
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxVal) * size.height;
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlX = (p1.dx + p2.dx) / 2;
      path.cubicTo(controlX, p1.dy, controlX, p2.dy, p2.dx, p2.dy);
    }

    canvas.drawPath(path, strokePaint);

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.qr_code_scanner,
          label: 'Scan',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const AddTransactionScreen(initialScan: true),
              ),
            );
          },
        ),
        _ActionButton(
          icon: Icons.flag_rounded,
          label: 'Goals',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageGoalsScreen(),
              ),
            );
          },
        ),
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
        backgroundColor: Theme.of(context).cardTheme.color,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          side: BorderSide(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.lightBorder
                : AppColors.darkBorder,
            width: 1,
          ),
        ),
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
        BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, transactionState) {
            final totalSpending = transactionState is TransactionLoaded
                ? transactionState.transactions
                      .where((t) => t.type == TransactionType.expense)
                      .fold<double>(0, (prev, t) => prev + t.amount)
                : 0.0;

            return BlocBuilder<BudgetBloc, BudgetState>(
              builder: (context, budgetState) {
                final totalBudget = budgetState is BudgetLoaded
                    ? budgetState.budgets.fold<double>(
                        0,
                        (prev, b) => prev + b.amount,
                      )
                    : 0.0;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SummaryCard(
                      title: 'Total Budget',
                      value: 'Rs. ${totalBudget.toStringAsFixed(0)}',
                      progress: totalBudget > 0
                          ? totalSpending / totalBudget
                          : 0,
                    ),
                    const SizedBox(width: 12),
                    _SummaryCard(
                      title: 'Total Spending',
                      value: 'Rs. ${totalSpending.toStringAsFixed(0)}',
                    ),
                  ],
                );
              },
            );
          },
        ),
        const SizedBox(height: 12),
        BlocBuilder<GoalBloc, GoalState>(
          builder: (context, state) {
            if (state is GoalLoaded) {
              final totalTargetAmount = state.goals.fold<double>(
                0,
                (previousValue, goal) => previousValue + goal.targetAmount,
              );
              final totalCurrentAmount = state.goals.fold<double>(
                0,
                (previousValue, goal) => previousValue + goal.currentAmount,
              );
              return _SummaryCard(
                title: 'Goal Progress',
                value:
                    'Rs. ${totalCurrentAmount.toStringAsFixed(0)} / Rs. ${totalTargetAmount.toStringAsFixed(0)}',
                progress: totalTargetAmount > 0
                    ? totalCurrentAmount / totalTargetAmount
                    : 0,
              );
            }
            return const _SummaryCard(
              title: 'Goal Progress',
              value: 'Rs. 0 / Rs. 0',
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

  const _SummaryCard({required this.title, required this.value, this.progress});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.lightBorder
                : AppColors.darkBorder,
            width: 1,
          ),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (progress != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(begin: 0, end: progress),
                  builder: (context, value, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: value.clamp(0.0, 1.0),
                        minHeight: 4,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
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
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                      itemCount: transactionState.transactions.length > 5
                          ? 5
                          : transactionState.transactions.length,
                      itemBuilder: (context, index) {
                        final transaction =
                            transactionState.transactions[index];
                        final category = categoryState.categories.firstWhere(
                          (c) => c.id == transaction.categoryId,
                          orElse: () => Category(
                            id: '',
                            name: 'Unknown',
                            icon: '❓',
                            color: '#888888',
                          ),
                        );
                        return Dismissible(
                          key: Key(transaction.id),
                          direction: DismissDirection.horizontal,
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddTransactionScreen(
                                    transaction: transaction,
                                  ),
                                ),
                              );
                              return false;
                            }
                            return true;
                          },
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              context.read<TransactionBloc>().add(
                                DeleteTransaction(id: transaction.id),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${transaction.title} deleted'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () {
                                      context.read<TransactionBloc>().add(
                                        AddTransaction(
                                          transaction: transaction,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                          child: _ActivityTile(
                            iconEmoji: category.icon,
                            iconBg: Color(
                              int.parse(
                                    category.color.replaceAll('#', ''),
                                    radix: 16,
                                  ) +
                                  0xFF000000,
                            ),
                            title: transaction.title,
                            subtitle: transaction.isSplit
                                ? 'Split with ${transaction.splitWith}'
                                : DateFormat.yMMMd().format(transaction.date),
                            amount:
                                '${transaction.type == TransactionType.income ? '+' : '-'} Rs. ${transaction.amount.toStringAsFixed(0)}',
                            amountColor:
                                transaction.type == TransactionType.income
                                ? const Color(0xFF34C759)
                                : const Color(0xFFFF3B30),
                            isSplit: transaction.isSplit,
                            onRemind: () {
                              NotificationService().showNotification(
                                transaction.hashCode,
                                'Split Bill Reminder',
                                'Reminder: ${transaction.splitWith} owes you Rs. ${transaction.splitAmount?.toStringAsFixed(2)} for ${transaction.title}',
                                '',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Reminder sent to ${transaction.splitWith}!',
                                  ),
                                ),
                              );
                            },
                          ),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No transactions yet',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add your first transaction to get started',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
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
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String iconEmoji;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final bool isSplit;
  final VoidCallback? onRemind;

  const _ActivityTile({
    required this.iconEmoji,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    this.isSplit = false,
    this.onRemind,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.lightBorder
              : AppColors.darkBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: iconBg.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: Text(iconEmoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                  fontSize: 15,
                ),
              ),
              if (isSplit)
                IconButton(
                  icon: Icon(
                    Icons.notifications_active,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: onRemind,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  tooltip: 'Remind person',
                ),
            ],
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
      color: Theme.of(context).cardTheme.color,
      elevation: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarIcon(
            icon: Icons.grid_view_rounded,
            label: 'Home',
            selected: selectedIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavBarIcon(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Budgets',
            selected: selectedIndex == 1,
            onTap: () => onTap(1),
          ),
          const SizedBox(width: 48), // Notch space
          _NavBarIcon(
            icon: Icons.show_chart_rounded,
            label: 'Analytics',
            selected: selectedIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavBarIcon(
            icon: Icons.sticky_note_2_rounded,
            label: 'Notes',
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
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected
                ? Theme.of(context).colorScheme.primary
                : AppColors.textGrey,
            size: 22,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : AppColors.textGrey,
              fontSize: 10,
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
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      activeBackgroundColor: Theme.of(context).colorScheme.primary,
      activeForegroundColor: Colors.white,
      elevation: 4.0,
      shape: const CircleBorder(),
      children: [
        SpeedDialChild(
          child: const Icon(Icons.mic),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          label: 'Voice',
          onTap: () async {
            final result = await showDialog<ParsedTransactionResult>(
              context: context,
              builder: (context) => const VoiceRecordingDialog(),
            );

            if (result != null && context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddTransactionScreen(parsedResult: result),
                ),
              );
            }
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.edit),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          label: 'Manual',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTransactionScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class BudgetOverviewCard extends StatelessWidget {
  const BudgetOverviewCard({super.key});

  IconData _getCategoryIconData(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'food':
      case 'groceries':
        return Icons.shopping_cart_outlined;
      case 'transport':
      case 'transportation':
        return Icons.directions_car_outlined;
      case 'bills':
      case 'utilities':
      case 'bills & utilities':
        return Icons.lightbulb_outline;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'entertainment':
        return Icons.theater_comedy_outlined;
      case 'health':
      case 'healthcare':
        return Icons.local_hospital_outlined;
      case 'education':
        return Icons.school_outlined;
      case 'travel':
        return Icons.flight_takeoff_outlined;
      case 'cash':
        return Icons.payments_outlined;
      default:
        return Icons.label_outline;
    }
  }

  Color _getBudgetColor(double progress) {
    if (progress >= 0.7) {
      return const Color(0xFFD32F2F); // Red
    } else if (progress >= 0.5) {
      return const Color(0xFF1A6BFF); // Blue
    } else {
      return const Color(0xFF2E7D32); // Green
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, budgetState) {
        return BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, transactionState) {
            if (budgetState is BudgetLoading) {
              return const SizedBox.shrink();
            }

            if (budgetState is BudgetLoaded) {
              if (budgetState.budgets.isEmpty) {
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.wallet, color: AppColors.primaryColor, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Track with Budgets',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Set limits to save money automatically.',
                                style: TextStyle(color: Colors.grey, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MonthlyBudgetsScreen()),
                            );
                          },
                          child: const Text('Set Up', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Get active transactions in this tab to dynamically count spent
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

              return BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, categoryState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly Budgets',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: budgetState.budgets.length,
                          itemBuilder: (context, index) {
                            final budget = budgetState.budgets[index];
                            
                            // Find category details
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
                                ? currentMonthExpenses.fold<double>(0.0, (sum, t) => sum + t.amount)
                                : currentMonthExpenses
                                    .where((t) => t.categoryId == budget.categoryId)
                                    .fold<double>(0.0, (sum, t) => sum + t.amount);

                            final progress = budget.amount > 0 ? (spentAmount / budget.amount) : 0.0;
                            final themeColor = _getBudgetColor(progress);
                            final percentageString = (progress * 100).toStringAsFixed(0);

                            return Container(
                              width: 195,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.15),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: themeColor.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _getCategoryIconData(budget.categoryId),
                                          color: themeColor,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          category.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  RichText(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      children: [
                                        TextSpan(
                                          text: 'Rs. ${spentAmount.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: themeColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const TextSpan(text: ' / '),
                                        TextSpan(
                                          text: 'Rs. ${budget.amount.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: progress.clamp(0.0, 1.0),
                                            minHeight: 5,
                                            backgroundColor: Colors.grey[200],
                                            valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '~$percentageString%',
                                        style: TextStyle(
                                          color: themeColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}
