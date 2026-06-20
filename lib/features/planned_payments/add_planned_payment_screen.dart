import 'package:budget_tracker/core/constants.dart';
import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/features/planned_payments/planned_payment_bloc.dart';
import 'package:budget_tracker/models/planned_payment.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddPlannedPaymentScreen extends StatefulWidget {
  final PlannedPayment? existing;
  const AddPlannedPaymentScreen({super.key, this.existing});

  @override
  State<AddPlannedPaymentScreen> createState() =>
      _AddPlannedPaymentScreenState();
}

class _AddPlannedPaymentScreenState extends State<AddPlannedPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _payeeController = TextEditingController();
  final _notesController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _selectedCategoryId;
  PlannedFrequency _frequency = PlannedFrequency.oneTime;
  String _paymentMethod = 'Cash';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  bool _notificationEnabled = false;

  static const List<String> _paymentMethods = [
    'Cash',
    'Card',
    'Bank Transfer',
    'Mobile Pay',
    'Cheque',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleController.text = e.title;
      _amountController.text = e.amount.toString();
      _payeeController.text = e.payee;
      _notesController.text = e.notes ?? '';
      _type = e.type;
      _selectedCategoryId = e.categoryId.isNotEmpty ? e.categoryId : null;
      _frequency = e.frequency;
      _paymentMethod = e.paymentMethod;
      _dueDate = e.dueDate;
      _notificationEnabled = e.notificationEnabled;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _payeeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Color get _accentColor => _type == TransactionType.expense
      ? const Color(0xFFFF6B6B)
      : const Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.existing != null ? 'Edit Reminder' : 'New Planned Payment',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            // ── Type Toggle ──────────────────────────────────────────────
            _buildTypeToggle(isDark, surface),
            const SizedBox(height: 20),

            // ── Amount ───────────────────────────────────────────────────
            _buildAmountField(isDark, surface, textPrimary, textSecondary),
            const SizedBox(height: 12),

            // ── Title ────────────────────────────────────────────────────
            _buildFieldCard(
              isDark,
              surface,
              child: TextFormField(
                controller: _titleController,
                maxLength: 40,
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Title',
                  labelStyle: TextStyle(color: textSecondary),
                  counterStyle: TextStyle(color: textSecondary, fontSize: 11),
                  prefixIcon: Icon(
                    Icons.title_rounded,
                    color: AppColors.primaryColor,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Please enter a title' : null,
              ),
            ),
            const SizedBox(height: 12),

            // ── Category ─────────────────────────────────────────────────
            _buildSectionLabel(
              'Category',
              Icons.category_rounded,
              textSecondary,
            ),
            const SizedBox(height: 8),
            _buildCategoryPicker(isDark, surface, textSecondary),
            const SizedBox(height: 20),

            // ── Payment Method ───────────────────────────────────────────
            _buildFieldCard(
              isDark,
              surface,
              child: DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Payment Method',
                  labelStyle: TextStyle(color: textSecondary),
                  prefixIcon: Icon(
                    Icons.credit_card_rounded,
                    color: AppColors.primaryColor,
                  ),
                ),
                dropdownColor: surface,
                style: TextStyle(color: textPrimary),
                items: _paymentMethods
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _paymentMethod = v ?? 'Cash'),
              ),
            ),
            const SizedBox(height: 12),

            // ── Payee ─────────────────────────────────────────────────────
            _buildFieldCard(
              isDark,
              surface,
              child: TextFormField(
                controller: _payeeController,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Payee / Merchant (Optional)',
                  labelStyle: TextStyle(color: textSecondary),
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Frequency ────────────────────────────────────────────────
            _buildSectionLabel(
              'Frequency',
              Icons.repeat_rounded,
              textSecondary,
            ),
            const SizedBox(height: 8),
            _buildFrequencySelector(
              isDark,
              surface,
              textPrimary,
              textSecondary,
            ),
            const SizedBox(height: 20),

            // ── Due Date ─────────────────────────────────────────────────
            _buildFieldCard(
              isDark,
              surface,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                onTap: () => _pickDate(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Due Date',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat.yMMMMd().format(_dueDate),
                              style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: textSecondary),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Notification Toggle ──────────────────────────────────────
            _buildFieldCard(
              isDark,
              surface,
              child: SwitchListTile(
                value: _notificationEnabled,
                onChanged: (v) => setState(() => _notificationEnabled = v),
                title: Text(
                  'Reminder Notification',
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Get notified on the due date',
                  style: TextStyle(color: textSecondary, fontSize: 12),
                ),
                secondary: Icon(
                  _notificationEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_outlined,
                  color: _notificationEnabled
                      ? AppColors.primaryColor
                      : Colors.grey,
                ),
                activeThumbColor: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),

            // ── Notes ────────────────────────────────────────────────────
            _buildFieldCard(
              isDark,
              surface,
              child: TextFormField(
                controller: _notesController,
                maxLines: 3,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Notes (Optional)',
                  labelStyle: TextStyle(color: textSecondary),
                  prefixIcon: Icon(
                    Icons.sticky_note_2_outlined,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Save Button ──────────────────────────────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: _submit,
                child: Text(
                  widget.existing != null ? 'Save Changes' : 'Save Reminder',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── UI Builders ──────────────────────────────────────────────────────────

  Widget _buildTypeToggle(bool isDark, Color surface) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _TypeBtn(
            label: 'Expense',
            icon: Icons.arrow_upward_rounded,
            selected: _type == TransactionType.expense,
            selectedColor: const Color(0xFFFF6B6B),
            onTap: () => setState(() => _type = TransactionType.expense),
          ),
          _TypeBtn(
            label: 'Income',
            icon: Icons.arrow_downward_rounded,
            selected: _type == TransactionType.income,
            selectedColor: const Color(0xFF4CAF50),
            onTap: () => setState(() => _type = TransactionType.income),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField(
    bool isDark,
    Color surface,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _accentColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _type == TransactionType.expense
                ? 'Planned Expense Amount'
                : 'Expected Income Amount',
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Rs.',
                style: TextStyle(
                  color: _accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: textSecondary.withValues(alpha: 0.4),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter an amount';
                    if (double.tryParse(v) == null || double.parse(v) <= 0) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPicker(bool isDark, Color surface, Color textSecondary) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is! CategoryLoaded || state.categories.isEmpty) {
          return const SizedBox.shrink();
        }
        final cats = state.categories;
        return FormField<String>(
          initialValue: _selectedCategoryId,
          validator: (_) =>
              _selectedCategoryId == null ? 'Please select a category' : null,
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 82,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  itemCount: cats.length,
                  // ignore: unnecessary_underscores
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final cat = cats[i];
                    final selected = cat.id == _selectedCategoryId;
                    final catColor = Color(
                      int.parse(cat.color.replaceAll('#', ''), radix: 16) +
                          0xFF000000,
                    );
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategoryId = cat.id);
                        field.didChange(cat.id);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 72,
                        decoration: BoxDecoration(
                          color: selected
                              ? catColor.withValues(alpha: 0.18)
                              : (isDark
                                    ? AppColors.darkSurface
                                    : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected ? catColor : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              cat.icon,
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: selected ? catColor : textSecondary,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    field.errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFrequencySelector(
    bool isDark,
    Color surface,
    Color textPrimary,
    Color textSecondary,
  ) {
    final freqs = [
      (PlannedFrequency.oneTime, 'One-Time', Icons.looks_one_rounded),
      (PlannedFrequency.monthly, 'Monthly', Icons.calendar_month_rounded),
      (PlannedFrequency.weekly, 'Weekly', Icons.calendar_view_week_rounded),
    ];
    return Row(
      children: freqs.map((f) {
        final selected = _frequency == f.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _frequency = f.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryColor
                    : (isDark ? AppColors.darkSurface : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.primaryColor : Colors.transparent,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    f.$3,
                    color: selected ? Colors.white : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    f.$2,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFieldCard(bool isDark, Color surface, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: child,
    );
  }

  Widget _buildSectionLabel(String label, IconData icon, Color textSecondary) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: AppColors.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final payment = PlannedPayment(
      id: widget.existing?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      type: _type,
      categoryId: _selectedCategoryId ?? '',
      amount: double.parse(_amountController.text),
      paymentMethod: _paymentMethod,
      payee: _payeeController.text.trim(),
      frequency: _frequency,
      dueDate: _dueDate,
      notificationEnabled: _notificationEnabled,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    if (widget.existing != null) {
      context.read<PlannedPaymentBloc>().add(UpdatePlannedPayment(payment));
    } else {
      context.read<PlannedPaymentBloc>().add(AddPlannedPayment(payment));
    }

    // If notification enabled and due date is today, show immediately
    if (_notificationEnabled) {
      final now = DateTime.now();
      if (_dueDate.year == now.year &&
          _dueDate.month == now.month &&
          _dueDate.day == now.day) {
        NotificationService().showNotification(
          payment.id.hashCode,
          '📅 Payment Due Today',
          '${payment.title} — Rs. ${payment.amount.toStringAsFixed(0)} is due today',
          '',
        );
      }
    }

    Navigator.pop(context);
  }
}

class _TypeBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _TypeBtn({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: selected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
