import 'package:budget_tracker/features/add_transaction/transaction_bloc.dart';
import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:budget_tracker/services/ai_service.dart';
import 'package:budget_tracker/services/ocr_service.dart';
import 'package:budget_tracker/services/transaction_analysis_service.dart';
import 'package:budget_tracker/services/ai_parser_service.dart';
import 'package:budget_tracker/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

enum SplitMethod { equal, percentage, exact, shares }

class SplitParticipant {
  String name;
  double amount;
  double percentage;
  double shares;
  bool isPaidBy;

  SplitParticipant({
    required this.name,
    this.amount = 0.0,
    this.percentage = 0.0,
    this.shares = 1.0,
    this.isPaidBy = false,
  });
}

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;
  final ParsedTransactionResult? parsedResult;
  final bool initialScan;
  const AddTransactionScreen({
    super.key,
    this.transaction,
    this.parsedResult,
    this.initialScan = false,
  });

  @override
  AddTransactionScreenState createState() => AddTransactionScreenState();
}

class AddTransactionScreenState extends State<AddTransactionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _detailsController = TextEditingController();
  final _categoryScrollController = ScrollController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  TransactionType _selectedType = TransactionType.expense;
  bool _isSplit = false;

  // Split Bill State
  final List<SplitParticipant> _participants = [];
  SplitMethod _splitMethod = SplitMethod.equal;
  int _selectedPeopleCountOption = 5; // 2, 3, 4, 5, or -1 for Custom
  final List<String> _defaultNames = ['Ali', 'Sara', 'Usman', 'Fatima'];
  double _youPaidAmount = 0.0;

  late AnimationController _splitAnimController;
  late Animation<double> _splitAnimation;

  final _ocrService = OcrService();
  final _aiService = AiService();
  final _analysisService = TransactionAnalysisService();

  @override
  void initState() {
    super.initState();
    _splitAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _splitAnimation = CurvedAnimation(
      parent: _splitAnimController,
      curve: Curves.easeInOutCubic,
    );

    _titleController.addListener(_onTitleChanged);
    _amountController.addListener(_onTotalAmountChanged);

    // Initialize Split Bill state
    _initializeParticipants(5);

    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _youPaidAmount = widget.transaction!.amount;
      _selectedDate = widget.transaction!.date;
      _selectedCategoryId = widget.transaction!.categoryId;
      _selectedType = widget.transaction!.type;
      _isSplit = widget.transaction!.isSplit;
      if (_isSplit) {
        final names = widget.transaction!.splitWith?.split(', ') ?? [];
        _participants.clear();
        _participants.add(
          SplitParticipant(
            name: 'You (Paid by)',
            isPaidBy: true,
            amount:
                widget.transaction!.amount -
                (widget.transaction!.splitAmount ?? 0.0),
          ),
        );
        for (final name in names) {
          if (name.isNotEmpty) {
            _participants.add(
              SplitParticipant(
                name: name,
                amount:
                    (widget.transaction!.splitAmount ?? 0.0) /
                    (names.isNotEmpty ? names.length : 1),
              ),
            );
          }
        }
        _selectedPeopleCountOption = [2, 3, 4, 5].contains(_participants.length)
            ? _participants.length
            : -1;
        _recalculateSplit();
        _splitAnimController.value = 1.0;
      }
      _detailsController.text = widget.transaction!.details ?? '';
    } else if (widget.parsedResult != null) {
      _titleController.text = widget.parsedResult!.title;
      _amountController.text = widget.parsedResult!.amount.toString();
      _youPaidAmount = widget.parsedResult!.amount;
      _selectedType = widget.parsedResult!.type;
      _isSplit = widget.parsedResult!.isSplit;
      if (_isSplit) {
        final names = widget.parsedResult!.splitWith?.split(', ') ?? [];
        _participants.clear();
        _participants.add(
          SplitParticipant(name: 'You (Paid by)', isPaidBy: true),
        );
        for (final name in names) {
          if (name.isNotEmpty) {
            _participants.add(SplitParticipant(name: name));
          }
        }
        _selectedPeopleCountOption = [2, 3, 4, 5].contains(_participants.length)
            ? _participants.length
            : -1;
        _recalculateSplit();
        _splitAnimController.value = 1.0;
      }
      _predictCategory(widget.parsedResult!.categoryHint);
    }

    if (widget.initialScan) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scanReceipt());
    }
  }

  @override
  void dispose() {
    _splitAnimController.dispose();
    _ocrService.dispose();
    _titleController.removeListener(_onTitleChanged);
    _amountController.removeListener(_onTotalAmountChanged);
    _titleController.dispose();
    _amountController.dispose();
    _detailsController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _onTotalAmountChanged() {
    final total = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _youPaidAmount = total;
      _recalculateSplit();
    });
  }

  void _initializeParticipants(int count) {
    _participants.clear();
    _participants.add(SplitParticipant(name: 'You (Paid by)', isPaidBy: true));
    for (int i = 0; i < count - 1; i++) {
      String name = i < _defaultNames.length
          ? _defaultNames[i]
          : 'Person ${i + 2}';
      _participants.add(SplitParticipant(name: name));
    }
    _recalculateSplit();
  }

  void _recalculateSplit() {
    final total = double.tryParse(_amountController.text) ?? 0.0;
    final n = _participants.length;
    if (total <= 0 || n == 0) return;

    if (_splitMethod == SplitMethod.equal) {
      final share = total / n;
      for (var p in _participants) {
        p.amount = share;
        p.percentage = 100.0 / n;
        p.shares = 1.0;
      }
    } else if (_splitMethod == SplitMethod.percentage) {
      for (var p in _participants) {
        p.amount = total * (p.percentage / 100.0);
      }
    } else if (_splitMethod == SplitMethod.exact) {
      for (var p in _participants) {
        p.percentage = total > 0 ? (p.amount / total) * 100.0 : 0.0;
      }
    } else if (_splitMethod == SplitMethod.shares) {
      double totalShares = 0.0;
      for (var p in _participants) {
        totalShares += p.shares;
      }
      if (totalShares > 0) {
        for (var p in _participants) {
          p.amount = total * (p.shares / totalShares);
          p.percentage = (p.amount / total) * 100.0;
        }
      }
    }
  }

  void _onParticipantPercentageChanged(int index, double percentage) {
    setState(() {
      _participants[index].percentage = percentage;
      _recalculateSplit();
    });
  }

  void _onParticipantAmountChanged(int index, double amount) {
    setState(() {
      _participants[index].amount = amount;
      _recalculateSplit();
    });
  }

  void _onParticipantSharesChanged(int index, double shares) {
    setState(() {
      _participants[index].shares = shares;
      _recalculateSplit();
    });
  }

  Future<void> _scanReceipt() async {
    final data = await _ocrService.pickImageAndExtractData();
    if (data != null) {
      setState(() {
        if (data.amount != null) {
          _amountController.text = data.amount!.toStringAsFixed(2);
          _youPaidAmount = data.amount!;
        }
        if (data.merchantName != null) {
          _titleController.text = data.merchantName!;
          _predictCategory(data.merchantName!);
        }
        if (data.date != null) {
          _selectedDate = data.date!;
        }
        _recalculateSplit();
      });
    }
  }

  void _onTitleChanged() {
    _predictCategory(_titleController.text);
  }

  Future<void> _predictCategory(String title) async {
    if (title.isEmpty) return;
    final categoryState = context.read<CategoryBloc>().state;
    if (categoryState is CategoryLoaded) {
      final predictedCategoryId = await _aiService.predictCategory(
        title,
        categoryState.categories,
      );
      if (mounted &&
          predictedCategoryId != null &&
          predictedCategoryId != _selectedCategoryId) {
        setState(() {
          _selectedCategoryId = predictedCategoryId;
        });
        _scrollToSelectedCategory(categoryState.categories);
      }
    }
  }

  void _scrollToSelectedCategory(List<Category> categories) {
    if (_selectedCategoryId == null) return;
    final index = categories.indexWhere((c) => c.id == _selectedCategoryId);
    if (index >= 0 && _categoryScrollController.hasClients) {
      final itemWidth = 88.0;
      _categoryScrollController.animateTo(
        (index * itemWidth).clamp(
          0.0,
          _categoryScrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  void _toggleSplit(bool value) {
    setState(() {
      _isSplit = value;
      if (_isSplit) {
        _recalculateSplit();
        _splitAnimController.forward();
      } else {
        _splitAnimController.reverse();
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  double get _othersShareTotal {
    double total = 0.0;
    for (int i = 1; i < _participants.length; i++) {
      total += _participants[i].amount;
    }
    return total;
  }

  void _submitTransaction() {
    if (_formKey.currentState!.validate()) {
      final names = _participants
          .where((p) => !p.isPaidBy)
          .map((p) => p.name)
          .join(', ');
      final transaction = Transaction(
        id: widget.transaction?.id ?? const Uuid().v4(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        categoryId: _selectedCategoryId!,
        type: _selectedType,
        details: _detailsController.text.isEmpty
            ? null
            : _detailsController.text,
        isSplit: _isSplit,
        splitWith: _isSplit ? names : null,
        splitAmount: _isSplit ? _othersShareTotal : null,
      );
      if (widget.transaction != null) {
        context.read<TransactionBloc>().add(
          UpdateTransaction(transaction: transaction),
        );
      } else {
        context.read<TransactionBloc>().add(
          AddTransaction(transaction: transaction),
        );
      }
      Navigator.pop(context);
    }
  }

  Future<void> _handleAddTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final names = _participants
        .where((p) => !p.isPaidBy)
        .map((p) => p.name)
        .join(', ');
    final newTransaction = Transaction(
      id: widget.transaction?.id ?? const Uuid().v4(),
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      categoryId: _selectedCategoryId!,
      type: _selectedType,
      details: _detailsController.text.isEmpty ? null : _detailsController.text,
      isSplit: _isSplit,
      splitWith: _isSplit ? names : null,
      splitAmount: _isSplit ? _othersShareTotal : null,
    );

    final transactionState = context.read<TransactionBloc>().state;
    if (transactionState is TransactionLoaded) {
      final isDuplicate = await _analysisService.isPotentialDuplicate(
        newTransaction,
        transactionState.transactions,
      );
      if (isDuplicate && mounted) {
        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
              ),
              title: const Text('Potential Duplicate'),
              content: const Text(
                'This looks like a duplicate transaction. Are you sure you want to add it?',
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                TextButton(
                  child: Text(
                    'Add Anyway',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _submitTransaction();
                  },
                ),
              ],
            );
          },
        );
      } else {
        _submitTransaction();
      }
    } else {
      _submitTransaction();
    }
  }

  Color get _typeAccentColor => _selectedType == TransactionType.expense
      ? AppColors.tertiaryColor
      : AppColors.successColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

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
          widget.transaction != null ? 'Edit Transaction' : 'New Transaction',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Scan Receipt',
            icon: Icon(
              Icons.camera_alt_outlined,
              color: AppColors.primaryColor,
            ),
            onPressed: _scanReceipt,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            _TypeToggle(
              selected: _selectedType,
              onChanged: (t) => setState(() {
                _selectedType = t;
                if (t == TransactionType.income) {
                  _isSplit = false;
                  _splitAnimController.reverse();
                }
              }),
            ),
            const SizedBox(height: 24),

            _AmountHero(
              controller: _amountController,
              accentColor: _typeAccentColor,
              isDark: isDark,
              surface: surface,
              border: border,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 20),

            _FieldCard(
              isDark: isDark,
              surface: surface,
              border: border,
              child: TextFormField(
                controller: _titleController,
                maxLength: 30,
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
                    Icons.edit_note_rounded,
                    color: AppColors.primaryColor,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Please enter a title' : null,
              ),
            ),
            const SizedBox(height: 12),

            _FieldCard(
              isDark: isDark,
              surface: surface,
              border: border,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                onTap: () => _selectDate(context),
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
                              'Date',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat.yMMMMd().format(_selectedDate),
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

            _FieldCard(
              isDark: isDark,
              surface: surface,
              border: border,
              child: TextFormField(
                controller: _detailsController,
                maxLines: 2,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Notes (Optional)',
                  labelStyle: TextStyle(color: textSecondary),
                  prefixIcon: Icon(
                    Icons.notes_rounded,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _SectionLabel(
              label: 'Category',
              icon: Icons.category_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoaded) {
                  if (state.categories.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No categories available.',
                        style: TextStyle(color: textSecondary),
                      ),
                    );
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToSelectedCategory(state.categories);
                  });

                  return FormField<String>(
                    initialValue: _selectedCategoryId,
                    validator: (_) => _selectedCategoryId == null
                        ? 'Please select a category'
                        : null,
                    builder: (field) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 88,
                            child: ListView.separated(
                              controller: _categoryScrollController,
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              itemCount: state.categories.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, i) {
                                final cat = state.categories[i];
                                final isSelected =
                                    cat.id == _selectedCategoryId;
                                final catColor = _hexToColor(cat.color);
                                return _CategoryChip(
                                  category: cat,
                                  isSelected: isSelected,
                                  catColor: catColor,
                                  isDark: isDark,
                                  surface: surface,
                                  border: border,
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryId = cat.id;
                                    });
                                    field.didChange(cat.id);
                                  },
                                );
                              },
                            ),
                          ),
                          if (field.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 4),
                              child: Text(
                                field.errorText!,
                                style: TextStyle(
                                  color: AppColors.errorColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                }
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            Opacity(
              opacity: _selectedType == TransactionType.income ? 0.4 : 1.0,
              child: AbsorbPointer(
                absorbing: _selectedType == TransactionType.income,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(
                      label: 'Split Bill',
                      icon: Icons.people_alt_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _SplitToggleCard(
                      isSplit: _isSplit,
                      isDark: isDark,
                      surface: surface,
                      border: border,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onToggle: _toggleSplit,
                    ),
                  ],
                ),
              ),
            ),
            SizeTransition(
              sizeFactor: _splitAnimation,
              axisAlignment: -1,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _SplitBillDetailsPanel(
                  totalAmount: double.tryParse(_amountController.text) ?? 0.0,
                  youPaidAmount: _youPaidAmount,
                  participants: _participants,
                  splitMethod: _splitMethod,
                  selectedPeopleCountOption: _selectedPeopleCountOption,
                  isDark: isDark,
                  surface: surface,
                  border: border,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onPeopleCountOptionChanged: (opt) {
                    setState(() {
                      _selectedPeopleCountOption = opt;
                      if (opt != -1) {
                        _initializeParticipants(opt);
                      }
                    });
                  },
                  onCustomPeopleCountRequested: () {
                    _showCustomPeopleCountDialog(context);
                  },
                  onSplitMethodChanged: (method) {
                    setState(() {
                      _splitMethod = method;
                      _recalculateSplit();
                    });
                  },
                  onAddPerson: () {
                    setState(() {
                      _selectedPeopleCountOption = -1; // custom
                      String nextName =
                          _participants.length - 1 < _defaultNames.length
                          ? _defaultNames[_participants.length - 1]
                          : 'Person ${_participants.length + 1}';
                      _participants.add(SplitParticipant(name: nextName));
                      _recalculateSplit();
                    });
                  },
                  onRemovePerson: (idx) {
                    setState(() {
                      _selectedPeopleCountOption = -1; // custom
                      _participants.removeAt(idx);
                      _recalculateSplit();
                    });
                  },
                  onParticipantPercentageChanged:
                      _onParticipantPercentageChanged,
                  onParticipantAmountChanged: _onParticipantAmountChanged,
                  onParticipantSharesChanged: _onParticipantSharesChanged,
                  onParticipantNameChanged: (idx, name) {
                    setState(() {
                      _participants[idx].name = name;
                    });
                  },
                  onYouPaidAmountChanged: (amt) {
                    setState(() {
                      _youPaidAmount = amt;
                    });
                  },
                  onReset: () {
                    setState(() {
                      _splitMethod = SplitMethod.equal;
                      _selectedPeopleCountOption = 5;
                      _initializeParticipants(5);
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _SaveBar(
        isEdit: widget.transaction != null,
        accentColor: _typeAccentColor,
        onSave: _handleAddTransaction,
      ),
    );
  }

  void _showCustomPeopleCountDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
          title: const Text('Enter Number of People'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'e.g. 6'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final count = int.tryParse(controller.text);
                if (count != null && count >= 2) {
                  setState(() {
                    _selectedPeopleCountOption = -1;
                    _initializeParticipants(count);
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceAll('#', ''), radix: 16) + 0xFF000000);
  }
}

// ─── Type Toggle ──────────────────────────────────────────────────────────────
class _TypeToggle extends StatelessWidget {
  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;
  const _TypeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: trackBg,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          _TypePill(
            label: 'Expense',
            icon: Icons.arrow_downward_rounded,
            isSelected: selected == TransactionType.expense,
            activeColor: AppColors.tertiaryColor,
            onTap: () => onChanged(TransactionType.expense),
          ),
          _TypePill(
            label: 'Income',
            icon: Icons.arrow_upward_rounded,
            isSelected: selected == TransactionType.income,
            activeColor: AppColors.successColor,
            onTap: () => onChanged(TransactionType.income),
          ),
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;
  const _TypePill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: isSelected ? Colors.white : AppColors.textGrey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isSelected ? Colors.white : AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Amount Hero ──────────────────────────────────────────────────────────────
class _AmountHero extends StatelessWidget {
  final TextEditingController controller;
  final Color accentColor;
  final bool isDark;
  final Color surface, border, textPrimary, textSecondary;
  const _AmountHero({
    required this.controller,
    required this.accentColor,
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius + 4),
        border: Border.all(color: accentColor.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Amount',
            style: TextStyle(color: textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Rs. ',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: textSecondary.withValues(alpha: 0.4),
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter an amount';
                    final a = double.tryParse(v);
                    if (a == null) return 'Invalid number';
                    if (a <= 0) return 'Must be positive';
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
}

// ─── Generic Field Card ───────────────────────────────────────────────────────
class _FieldCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color surface, border;
  const _FieldCard({
    required this.child,
    required this.isDark,
    required this.surface,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  const _SectionLabel({
    required this.label,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

// ─── Category Chip ────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final Color catColor;
  final bool isDark;
  final Color surface, border;
  final VoidCallback onTap;
  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.catColor,
    required this.isDark,
    required this.surface,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? catColor.withValues(alpha: isDark ? 0.25 : 0.12)
              : surface,
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          border: Border.all(
            color: isSelected ? catColor : border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? catColor
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Split Toggle Card ────────────────────────────────────────────────────────
class _SplitToggleCard extends StatelessWidget {
  final bool isSplit;
  final bool isDark;
  final Color surface, border, textPrimary, textSecondary;
  final ValueChanged<bool> onToggle;
  const _SplitToggleCard({
    required this.isSplit,
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(
          color: isSplit
              ? AppColors.primaryColor.withValues(alpha: 0.5)
              : border,
          width: isSplit ? 1.5 : 1,
        ),
      ),
      child: SwitchListTile.adaptive(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          'Split Bill',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          isSplit ? 'Tap below to fill split details' : 'Share with someone',
          style: TextStyle(color: textSecondary, fontSize: 12),
        ),
        secondary: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primaryColor.withValues(
            alpha: isSplit ? 0.15 : 0.08,
          ),
          child: Icon(
            Icons.people_alt_rounded,
            size: 18,
            color: isSplit ? AppColors.primaryColor : textSecondary,
          ),
        ),
        value: isSplit,
        activeThumbColor: AppColors.primaryColor,
        activeTrackColor: AppColors.primaryColor.withValues(alpha: 0.4),
        onChanged: onToggle,
      ),
    );
  }
}

// ─── Premium Split Bill Details Panel ────────────────────────────────────────
class _SplitBillDetailsPanel extends StatelessWidget {
  final double totalAmount;
  final double youPaidAmount;
  final List<SplitParticipant> participants;
  final SplitMethod splitMethod;
  final int selectedPeopleCountOption;
  final bool isDark;
  final Color surface, border, textPrimary, textSecondary;

  final ValueChanged<int> onPeopleCountOptionChanged;
  final VoidCallback onCustomPeopleCountRequested;
  final ValueChanged<SplitMethod> onSplitMethodChanged;
  final VoidCallback onAddPerson;
  final ValueChanged<int> onRemovePerson;
  final void Function(int, double) onParticipantPercentageChanged;
  final void Function(int, double) onParticipantAmountChanged;
  final void Function(int, double) onParticipantSharesChanged;
  final void Function(int, String) onParticipantNameChanged;
  final ValueChanged<double> onYouPaidAmountChanged;
  final VoidCallback onReset;

  const _SplitBillDetailsPanel({
    required this.totalAmount,
    required this.youPaidAmount,
    required this.participants,
    required this.splitMethod,
    required this.selectedPeopleCountOption,
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.onPeopleCountOptionChanged,
    required this.onCustomPeopleCountRequested,
    required this.onSplitMethodChanged,
    required this.onAddPerson,
    required this.onRemovePerson,
    required this.onParticipantPercentageChanged,
    required this.onParticipantAmountChanged,
    required this.onParticipantSharesChanged,
    required this.onParticipantNameChanged,
    required this.onYouPaidAmountChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final youShare = participants.isNotEmpty ? participants[0].amount : 0.0;
    final othersOwe = (youPaidAmount - youShare).clamp(0.0, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header total / you share summary ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'You Pay',
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rs. ${youShare.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.errorColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onReset,
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── How many people? ──
        Text(
          'How many people?',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var val in [2, 3, 4, 5])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _PeopleOptionButton(
                    label: val.toString(),
                    isSelected: selectedPeopleCountOption == val,
                    isDark: isDark,
                    onTap: () => onPeopleCountOptionChanged(val),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _PeopleOptionButton(
                  label: 'Custom',
                  isSelected: selectedPeopleCountOption == -1,
                  isDark: isDark,
                  onTap: onCustomPeopleCountRequested,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Split Method ──
        Text(
          'Split Method',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              _MethodTabButton(
                label: 'Equal',
                icon: Icons.tune_rounded,
                isSelected: splitMethod == SplitMethod.equal,
                onTap: () => onSplitMethodChanged(SplitMethod.equal),
              ),
              _MethodTabButton(
                label: 'Percentage',
                icon: Icons.percent_rounded,
                isSelected: splitMethod == SplitMethod.percentage,
                onTap: () => onSplitMethodChanged(SplitMethod.percentage),
              ),
              _MethodTabButton(
                label: 'Exact',
                icon: Icons.currency_rupee_rounded,
                isSelected: splitMethod == SplitMethod.exact,
                onTap: () => onSplitMethodChanged(SplitMethod.exact),
              ),
              _MethodTabButton(
                label: 'Shares',
                icon: Icons.people_outline_rounded,
                isSelected: splitMethod == SplitMethod.shares,
                onTap: () => onSplitMethodChanged(SplitMethod.shares),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Participants List ──
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: participants.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, idx) {
            final part = participants[idx];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryColor.withValues(
                      alpha: 0.15,
                    ),
                    child: Text(
                      part.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: part.isPaidBy
                        ? Row(
                            children: [
                              Text(
                                'You',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '(Paid by)',
                                style: TextStyle(
                                  color: AppColors.successColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : TextFormField(
                            key: ValueKey(part),
                            initialValue: part.name,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            onChanged: (val) =>
                                onParticipantNameChanged(idx, val),
                          ),
                  ),
                  const SizedBox(width: 12),
                  _buildInputForMethod(idx, part),
                  if (!part.isPaidBy) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline_rounded,
                        color: AppColors.errorColor,
                        size: 20,
                      ),
                      onPressed: () => onRemovePerson(idx),
                    ),
                  ],
                  const SizedBox(width: 4),
                  Icon(
                    Icons.drag_indicator_rounded,
                    color: textSecondary,
                    size: 20,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),

        // ── Add Person Dotted Button ──
        GestureDetector(
          onTap: onAddPerson,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
              border: Border.all(
                color: AppColors.primaryColor,
                style: BorderStyle.solid,
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_rounded,
                  color: AppColors.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Add Person',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ── Expense Summary ──
        Text(
          'Expense Summary',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            border: Border.all(color: border),
          ),
          child: Column(
            children: [
              _SummaryRow(
                label: 'Total Amount',
                value: 'Rs. ${totalAmount.toStringAsFixed(0)}',
                textSecondary: textSecondary,
                textPrimary: textPrimary,
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'You Paid',
                    style: TextStyle(color: textSecondary, fontSize: 13),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      key: ValueKey(totalAmount),
                      initialValue: youPaidAmount.toStringAsFixed(0),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      onChanged: (val) {
                        final amt = double.tryParse(val) ?? 0.0;
                        onYouPaidAmountChanged(amt);
                      },
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              _SummaryRow(
                label: 'Your Share',
                value: 'Rs. ${youShare.toStringAsFixed(0)}',
                textSecondary: textSecondary,
                textPrimary: textPrimary,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.successColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.successColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.successColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        youPaidAmount >= youShare
                            ? 'You will receive Rs. ${othersOwe.toStringAsFixed(0)}'
                            : 'You owe others Rs. ${(youShare - youPaidAmount).toStringAsFixed(0)}',
                        style: TextStyle(
                          color: AppColors.successColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputForMethod(int index, SplitParticipant part) {
    if (splitMethod == SplitMethod.equal) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Rs. ${part.amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            '${part.percentage.toStringAsFixed(1)}%',
            style: TextStyle(color: textSecondary, fontSize: 11),
          ),
        ],
      );
    } else if (splitMethod == SplitMethod.percentage) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50,
            child: TextFormField(
              key: ValueKey(part),
              initialValue: part.percentage.toStringAsFixed(0),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixText: '%',
              ),
              onChanged: (val) {
                final pct = double.tryParse(val) ?? 0.0;
                onParticipantPercentageChanged(index, pct);
              },
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Rs. ${part.amount.toStringAsFixed(0)}',
            style: TextStyle(color: textSecondary, fontSize: 11),
          ),
        ],
      );
    } else if (splitMethod == SplitMethod.exact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 70,
            child: TextFormField(
              key: ValueKey(part),
              initialValue: part.amount.toStringAsFixed(0),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                prefixText: 'Rs.',
              ),
              onChanged: (val) {
                final amt = double.tryParse(val) ?? 0.0;
                onParticipantAmountChanged(index, amt);
              },
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${part.percentage.toStringAsFixed(0)}%',
            style: TextStyle(color: textSecondary, fontSize: 11),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            child: TextFormField(
              key: ValueKey(part),
              initialValue: part.shares.toStringAsFixed(0),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (val) {
                final shares = double.tryParse(val) ?? 1.0;
                onParticipantSharesChanged(index, shares);
              },
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Rs. ${part.amount.toStringAsFixed(0)}',
            style: TextStyle(color: textSecondary, fontSize: 11),
          ),
        ],
      );
    }
  }
}

class _PeopleOptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  const _PeopleOptionButton({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _MethodTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _MethodTabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius - 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textSecondary, textPrimary;
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.textSecondary,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textSecondary, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ─── Save Bar ─────────────────────────────────────────────────────────────────
class _SaveBar extends StatelessWidget {
  final bool isEdit;
  final Color accentColor;
  final VoidCallback onSave;
  const _SaveBar({
    required this.isEdit,
    required this.accentColor,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            ),
          ),
          child: Text(
            isEdit ? 'Update Transaction' : 'Save Transaction',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
