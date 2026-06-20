// ignore_for_file: use_build_context_synchronously, unnecessary_underscores

import 'package:budget_tracker/core/constants.dart';
import 'package:budget_tracker/features/add_transaction/transaction_bloc.dart';
import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/features/planned_payments/add_planned_payment_screen.dart';
import 'package:budget_tracker/features/planned_payments/planned_payment_bloc.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:budget_tracker/models/planned_payment.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

enum _FilterMode { all, upcoming, overdue, paid }

class PlannedPaymentsScreen extends StatefulWidget {
  const PlannedPaymentsScreen({super.key});

  @override
  State<PlannedPaymentsScreen> createState() => _PlannedPaymentsScreenState();
}

class _PlannedPaymentsScreenState extends State<PlannedPaymentsScreen> {
  _FilterMode _filter = _FilterMode.all;

  @override
  void initState() {
    super.initState();
    context.read<PlannedPaymentBloc>().add(LoadPlannedPayments());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          _buildFilterChips(context, isDark),
          const SizedBox(height: 8),
          Expanded(child: _buildList(context, isDark)),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C3EF4), Color(0xFF4A90E2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Planned Payments',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Notes & Reminders',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              FloatingActionButton.small(
                heroTag: 'add_planned',
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6C3EF4),
                elevation: 0,
                onPressed: () =>
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddPlannedPaymentScreen(),
                      ),
                    ).then(
                      (_) => context.read<PlannedPaymentBloc>().add(
                        LoadPlannedPayments(),
                      ),
                    ),
                child: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHeaderStats(context),
        ],
      ),
    );
  }

  Widget _buildHeaderStats(BuildContext context) {
    return BlocBuilder<PlannedPaymentBloc, PlannedPaymentState>(
      builder: (context, state) {
        if (state is! PlannedPaymentLoaded) return const SizedBox.shrink();
        final all = state.payments;
        final upcoming = all.where((p) => !p.isPaid && !p.isOverdue).length;
        final overdue = all.where((p) => p.isOverdue).length;
        final paid = all.where((p) => p.isPaid).length;

        return Row(
          children: [
            _HeaderStat(
              label: 'Upcoming',
              value: upcoming.toString(),
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            _HeaderStat(
              label: 'Overdue',
              value: overdue.toString(),
              color: overdue > 0
                  ? const Color(0xFFFFB74D)
                  : Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 16),
            _HeaderStat(
              label: 'Paid',
              value: paid.toString(),
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ],
        );
      },
    );
  }

  // ── Filter chips ──────────────────────────────────────────────────────────

  Widget _buildFilterChips(BuildContext context, bool isDark) {
    final filters = [
      (_FilterMode.all, 'All', Icons.list_rounded),
      (_FilterMode.upcoming, 'Upcoming', Icons.schedule_rounded),
      (_FilterMode.overdue, 'Overdue', Icons.warning_amber_rounded),
      (_FilterMode.paid, 'Paid', Icons.check_circle_rounded),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((f) {
          final selected = _filter == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF6C3EF4)
                      : (isDark ? AppColors.darkSurface : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF6C3EF4)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      f.$3,
                      size: 14,
                      color: selected ? Colors.white : Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      f.$2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── List ──────────────────────────────────────────────────────────────────

  Widget _buildList(BuildContext context, bool isDark) {
    return BlocBuilder<PlannedPaymentBloc, PlannedPaymentState>(
      builder: (context, state) {
        if (state is PlannedPaymentLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PlannedPaymentError) {
          return Center(child: Text(state.message));
        }
        if (state is! PlannedPaymentLoaded || state.payments.isEmpty) {
          return _buildEmptyState(context);
        }

        // Apply filter
        final payments = state.payments.where((p) {
          switch (_filter) {
            case _FilterMode.upcoming:
              return !p.isPaid && !p.isOverdue;
            case _FilterMode.overdue:
              return p.isOverdue;
            case _FilterMode.paid:
              return p.isPaid;
            case _FilterMode.all:
              return true;
          }
        }).toList();

        if (payments.isEmpty) {
          return _buildEmptyState(context, filtered: true);
        }

        return BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, catState) {
            final cats = catState is CategoryLoaded
                ? catState.categories
                : <Category>[];
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
              itemCount: payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _PlannedPaymentCard(
                payment: payments[i],
                categories: cats,
                isDark: isDark,
                onMarkPaid: () => _onMarkPaid(context, payments[i]),
                onEdit: () =>
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddPlannedPaymentScreen(existing: payments[i]),
                      ),
                    ).then(
                      (_) => context.read<PlannedPaymentBloc>().add(
                        LoadPlannedPayments(),
                      ),
                    ),
                onDelete: () => _onDelete(context, payments[i]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, {bool filtered = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6C3EF4).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sticky_note_2_rounded,
                size: 56,
                color: Color(0xFF6C3EF4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              filtered ? 'No items in this filter' : 'No planned payments yet',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filtered
                  ? 'Try a different filter.'
                  : 'Add reminders for recurring bills,\nsalaries or one-time payments.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            if (!filtered) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C3EF4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () =>
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddPlannedPaymentScreen(),
                      ),
                    ).then(
                      (_) => context.read<PlannedPaymentBloc>().add(
                        LoadPlannedPayments(),
                      ),
                    ),
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Add First Reminder',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _onMarkPaid(BuildContext context, PlannedPayment payment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green),
            SizedBox(width: 8),
            Text('Confirm Payment'),
          ],
        ),
        content: Text(
          'Mark "${payment.title}" as paid?\n\nThis will add a Rs. ${payment.amount.toStringAsFixed(0)} ${payment.type == TransactionType.income ? "income" : "expense"} entry to your transaction history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<PlannedPaymentBloc>().add(
                MarkPlannedPaymentPaid(
                  payment: payment,
                  transactionBloc: context.read<TransactionBloc>(),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '✅ "${payment.title}" marked as paid and added to history!',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Yes, Mark Paid'),
          ),
        ],
      ),
    );
  }

  void _onDelete(BuildContext context, PlannedPayment payment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Reminder'),
        content: Text('Remove "${payment.title}" from your planned payments?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<PlannedPaymentBloc>().add(
                DeletePlannedPayment(payment.id),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _PlannedPaymentCard extends StatelessWidget {
  final PlannedPayment payment;
  final List<Category> categories;
  final bool isDark;
  final VoidCallback onMarkPaid;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PlannedPaymentCard({
    required this.payment,
    required this.categories,
    required this.isDark,
    required this.onMarkPaid,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _cardColor {
    if (payment.isPaid) {
      return payment.type == TransactionType.income
          ? const Color(0xFF4CAF50)
          : const Color(0xFF42A5F5);
    }
    if (payment.isOverdue) return const Color(0xFFFF7043);
    if (payment.isDueToday) return const Color(0xFFFFB300);
    return const Color(0xFF6C3EF4);
  }

  Color get _bgTint {
    if (payment.isPaid) {
      return payment.type == TransactionType.income
          ? const Color(0xFF4CAF50).withValues(alpha: 0.08)
          : const Color(0xFF42A5F5).withValues(alpha: 0.08);
    }
    if (payment.isOverdue) {
      return const Color(0xFFFF7043).withValues(alpha: 0.07);
    }
    if (payment.isDueToday) {
      return const Color(0xFFFFB300).withValues(alpha: 0.07);
    }
    return Colors.transparent;
  }

  String get _statusLabel {
    if (payment.isPaid) return 'PAID';
    if (payment.isOverdue) return 'OVERDUE';
    if (payment.isDueToday) return 'DUE TODAY';
    return _frequencyLabel;
  }

  String get _frequencyLabel {
    switch (payment.frequency) {
      case PlannedFrequency.oneTime:
        return 'ONE-TIME';
      case PlannedFrequency.monthly:
        return 'MONTHLY';
      case PlannedFrequency.weekly:
        return 'WEEKLY';
    }
  }

  Category? get _category {
    try {
      return categories.firstWhere((c) => c.id == payment.categoryId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = _category;
    final catColor = cat != null
        ? Color(
            int.parse(cat.color.replaceAll('#', ''), radix: 16) + 0xFF000000,
          )
        : Colors.grey;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.95)
            : (payment.isPaid || payment.isOverdue || payment.isDueToday
                  ? _bgTint
                  : Colors.white),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _cardColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _cardColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Coloured top stripe
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: icon + title + amount
                Row(
                  children: [
                    // Category icon or type icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          cat?.icon ??
                              (payment.type == TransactionType.income
                                  ? '💰'
                                  : '💸'),
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                              decoration: payment.isPaid
                                  ? TextDecoration.none
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cat?.name ?? 'Uncategorised',
                            style: TextStyle(
                              color: catColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${payment.type == TransactionType.income ? '+' : '-'} Rs. ${NumberFormat.compact().format(payment.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: payment.type == TransactionType.income
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _cardColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _statusLabel,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: _cardColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Row 2: meta info
                Row(
                  children: [
                    _MetaChip(
                      icon: Icons.calendar_today_rounded,
                      label: payment.isPaid
                          ? 'Paid ${DateFormat('MMM d').format(payment.paidDate!)}'
                          : 'Due ${DateFormat('MMM d, yyyy').format(payment.dueDate)}',
                      color: _cardColor,
                    ),
                    const SizedBox(width: 8),
                    if (payment.paymentMethod.isNotEmpty)
                      _MetaChip(
                        icon: Icons.credit_card_rounded,
                        label: payment.paymentMethod,
                        color: Colors.grey,
                      ),
                    if (payment.notificationEnabled && !payment.isPaid) ...[
                      const SizedBox(width: 8),
                      _MetaChip(
                        icon: Icons.notifications_active_rounded,
                        label: 'Notif',
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ],
                ),

                if (payment.payee.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        payment.payee,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],

                if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.sticky_note_2_outlined,
                        size: 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          payment.notes!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // Row 3: action buttons
                if (!payment.isPaid) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: onMarkPaid,
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: const Text(
                              'Mark Paid',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _IconActionBtn(
                        icon: Icons.edit_outlined,
                        color: AppColors.primaryColor,
                        onTap: onEdit,
                      ),
                      const SizedBox(width: 6),
                      _IconActionBtn(
                        icon: Icons.delete_outline_rounded,
                        color: Colors.red,
                        onTap: onDelete,
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _IconActionBtn(
                        icon: Icons.edit_outlined,
                        color: Colors.grey,
                        onTap: onEdit,
                      ),
                      const SizedBox(width: 6),
                      _IconActionBtn(
                        icon: Icons.delete_outline_rounded,
                        color: Colors.red,
                        onTap: onDelete,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HeaderStat({
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
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
