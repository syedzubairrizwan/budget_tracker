import 'package:flutter/material.dart';
import 'package:budget_tracker/core/constants.dart';
import 'package:budget_tracker/features/add_transaction/transaction_bloc.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:budget_tracker/features/view_transactions/transactions_list_screen.dart';
import 'package:budget_tracker/features/manage_budgets/monthly_budgets_screen.dart';
import 'package:budget_tracker/features/manage_budgets/budget_bloc.dart';
import 'package:budget_tracker/features/manage_goals/add_goal_screen.dart';
import 'package:budget_tracker/features/manage_goals/manage_goals_screen.dart';
import 'package:budget_tracker/features/manage_goals/goal_bloc.dart';
import 'package:budget_tracker/features/manage_categories/categories_screen.dart';
import 'package:budget_tracker/models/award_badge.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budget_tracker/features/auth/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showEditProfileDialog(context),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _ProfileHeader(),
            const SizedBox(height: 24),
            _StatsSection(),
            const SizedBox(height: 24),
            _QuickActionsSection(),
            const SizedBox(height: 24),
            const _AccountSettingsSection(),
            const SizedBox(height: 24),
            _AchievementsSection(),
            const SizedBox(height: 24),
            _RecentActivitySection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'User';
    final email = user?.email ?? 'No email address';
    final photoUrl = user?.photoURL;
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null
                    ? Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Premium Member',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final totalBudgets = context.select((BudgetBloc bloc) {
      final state = bloc.state;
      return state is BudgetLoaded ? state.budgets.length : 0;
    });

    final goalsAchieved = context.select((GoalBloc bloc) {
      final state = bloc.state;
      return state is GoalLoaded
          ? state.goals.where((g) => g.currentAmount >= g.targetAmount).length
          : 0;
    });

    final daysActive = context.select((TransactionBloc bloc) {
      final state = bloc.state;
      if (state is TransactionLoaded) {
        return state.transactions
            .map((t) => DateFormat('yyyy-MM-dd').format(t.date))
            .toSet()
            .length;
      }
      return 0;
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Total Budgets',
              value: totalBudgets.toString(),
              icon: Icons.account_balance_wallet,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Goals Achieved',
              value: goalsAchieved.toString(),
              icon: Icons.flag,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Day Streak',
              value: daysActive.toString(),
              emoji: '🔥',
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final String? emoji;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    this.icon,
    this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: emoji != null
                ? Text(emoji!, style: const TextStyle(fontSize: 20))
                : Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textDark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  title: 'View Transactions',
                  icon: Icons.receipt_long,
                  color: AppColors.primaryColor,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsListScreen()));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  title: 'Set Budget',
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MonthlyBudgetsScreen()));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  title: 'Create Goal',
                  icon: Icons.flag,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGoalScreen()));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  title: 'View Progress',
                  icon: Icons.track_changes,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageGoalsScreen()));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  title: 'Categories',
                  icon: Icons.category_rounded,
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  title: 'Sign Out',
                  icon: Icons.logout_rounded,
                  color: Colors.redAccent,
                  onTap: () async {
                    final authService = AuthService();
                    await authService.logout();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textDark;
    
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Collect stats from BLoCs
    final totalBudgets = context.select((BudgetBloc bloc) {
      final state = bloc.state;
      return state is BudgetLoaded ? state.budgets.length : 0;
    });

    final totalGoals = context.select((GoalBloc bloc) {
      final state = bloc.state;
      return state is GoalLoaded ? state.goals.length : 0;
    });

    final goalsAchieved = context.select((GoalBloc bloc) {
      final state = bloc.state;
      return state is GoalLoaded
          ? state.goals.where((g) => g.currentAmount >= g.targetAmount).length
          : 0;
    });

    final transactions = context.select((TransactionBloc bloc) {
      final state = bloc.state;
      return state is TransactionLoaded ? state.transactions : <Transaction>[];
    });

    final totalTransactions = transactions.length;
    
    final dayStreak = transactions
        .map((t) => DateFormat('yyyy-MM-dd').format(t.date))
        .toSet()
        .length;

    final incomeCount = transactions.where((t) => t.type == TransactionType.income).length;
    final splitCount = transactions.where((t) => t.isSplit).length;

    int getProgress(String id) {
      switch (id) {
        case 'goal_1':
        case 'goal_5':
          return totalGoals;
        case 'goal_achieved_1':
        case 'goal_achieved_5':
        case 'goal_fast':
          return goalsAchieved;
        case 'budget_1':
        case 'budget_5':
          return totalBudgets;
        case 'budget_kept_1': return 1; // mock
        case 'budget_kept_10': return 2; // mock
        case 'tx_10':
        case 'tx_50':
        case 'tx_100':
          return totalTransactions;
        case 'streak_3':
        case 'streak_7':
        case 'streak_30':
          return dayStreak;
        case 'income_first':
        case 'income_5':
          return incomeCount;
        case 'split_1':
        case 'split_10':
          return splitCount;
        case 'save_100': return 100;
        case 'save_1000': return 350;
        case 'save_5000': return 350;
        case 'frugal_fox': return 1;
        case 'weekend_saver': return 0;
        case 'no_dining_out': return 2;
        case 'better_month': return 1;
        case 'side_hustle': return 0;
        case 'night_owl': return 0;
        case 'early_bird': return 1;
        case 'explorer': return 12; // mock
        default:
          return 0;
      }
    }

    final badges = AwardBadge.badges;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
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
              'Awards',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: badges.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final badge = badges[index];
                  final progress = getProgress(badge.id);
                  return SizedBox(
                    width: 100,
                    child: _DuolingoBadgeWidget(
                      badge: badge,
                      currentProgress: progress,
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

class _DuolingoBadgeWidget extends StatelessWidget {
  final AwardBadge badge;
  final int currentProgress;

  const _DuolingoBadgeWidget({
    required this.badge,
    required this.currentProgress,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = currentProgress >= badge.target;
    final displayProgress = currentProgress > badge.target ? badge.target : currentProgress;
    
    final color = isUnlocked ? badge.color : Colors.grey[300]!;
    final emojiOpacity = isUnlocked ? 1.0 : 0.3;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isUnlocked ? 0.2 : 0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: isUnlocked ? 3 : 0,
                ),
              ),
              child: Center(
                child: Opacity(
                  opacity: emojiOpacity,
                  child: Text(
                    badge.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  isUnlocked ? 'DONE' : '$displayProgress / ${badge.target}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          badge.title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isUnlocked ? null : Colors.grey,
              ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full activity
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoaded) {
                  final recentTransactions = state.transactions
                      .take(3)
                      .toList();

                  return Column(
                    children: recentTransactions.map((transaction) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: transaction.type == TransactionType.income
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                transaction.type == TransactionType.income
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: transaction.type == TransactionType.income
                                    ? Colors.green
                                    : Colors.red,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(transaction.date),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${transaction.type == TransactionType.income ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: transaction.type == TransactionType.income
                                    ? Colors.green
                                    : Colors.red,
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
      ),
    );
  }
}

class _AccountSettingsSection extends StatelessWidget {
  const _AccountSettingsSection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textDark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Security',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          _settingsRow(
            context,
            icon: Icons.edit_rounded,
            title: 'Edit Profile Name',
            subtitle: 'Update your display name in the cloud',
            color: Colors.blueAccent,
            onTap: () => _showEditProfileDialog(context),
          ),
          const SizedBox(height: 12),
          _settingsRow(
            context,
            icon: Icons.lock_rounded,
            title: 'Change Password',
            subtitle: 'Update your account password',
            color: Colors.orangeAccent,
            onTap: () => _showChangePasswordDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _settingsRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textDark;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.textGrey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
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
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: subColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: subColor, size: 14),
          ],
        ),
      ),
    );
  }
}

void _showEditProfileDialog(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;
  final controller = TextEditingController(text: user?.displayName);
  final formKey = GlobalKey<FormState>();
  bool isSaving = false;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Edit Profile Name',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Display Name',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isSaving = true);
                      try {
                        final newName = controller.text.trim();
                        await user?.updateDisplayName(newName);
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .update({'displayName': newName});
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile updated successfully!')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to update: $e')),
                        );
                      } finally {
                        setState(() => isSaving = false);
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        );
      },
    ),
  );
}

void _showChangePasswordDialog(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isSaving = false;
  String? errorMsg;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Change Password',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMsg != null) ...[
                    Text(
                      errorMsg!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                  ],
                  TextFormField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: const Icon(Icons.vpn_key_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v.length < 6) return 'At least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon: const Icon(Icons.vpn_key_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) {
                      if (v != newPasswordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() {
                        isSaving = true;
                        errorMsg = null;
                      });
                      try {
                        final credential = EmailAuthProvider.credential(
                          email: user!.email!,
                          password: currentPasswordController.text,
                        );
                        await user.reauthenticateWithCredential(credential);
                        await user.updatePassword(newPasswordController.text);
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password changed successfully!')),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          errorMsg = e.message;
                        });
                      } catch (e) {
                        setState(() {
                          errorMsg = e.toString();
                        });
                      } finally {
                        setState(() => isSaving = false);
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Change'),
            ),
          ],
        );
      },
    ),
  );
}
