import 'package:budget_tracker/features/add_transaction/transaction_bloc.dart';
import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/services/ai_service.dart';
import 'package:budget_tracker/services/ocr_service.dart';
import 'package:budget_tracker/services/transaction_analysis_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  AddTransactionScreenState createState() => AddTransactionScreenState();
}

class AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _splitWithController = TextEditingController();
  final _splitAmountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  TransactionType _selectedType = TransactionType.expense;
  bool _isSplit = false;

  final _ocrService = OcrService();
  final _aiService = AiService();
  final _analysisService = TransactionAnalysisService();

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTitleChanged);
    _dateController.text = DateFormat.yMMMd().format(_selectedDate);
    _amountController.addListener(_updateSplitAmount);
  }

  @override
  void dispose() {
    _ocrService.dispose();
    _titleController.removeListener(_onTitleChanged);
    _amountController.removeListener(_updateSplitAmount);
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _splitWithController.dispose();
    _splitAmountController.dispose();
    super.dispose();
  }

  void _updateSplitAmount() {
    if (_isSplit) {
      final total = double.tryParse(_amountController.text) ?? 0;
      _splitAmountController.text = (total / 2).toStringAsFixed(2);
    }
  }

  Future<void> _scanReceipt() async {
    final data = await _ocrService.pickImageAndExtractData();
    if (data != null) {
      setState(() {
        if (data.amount != null) {
          _amountController.text = data.amount!.toStringAsFixed(2);
        }
        if (data.merchantName != null) {
          _titleController.text = data.merchantName!;
          _predictCategory(data.merchantName!);
        }
        if (data.date != null) {
          _selectedDate = data.date!;
          _dateController.text = DateFormat.yMMMd().format(_selectedDate);
        }
      });
    }
  }

  void _onTitleChanged() {
    _predictCategory(_titleController.text);
  }

  Future<void> _predictCategory(String title) async {
    if (title.isEmpty) {
      return;
    }
    final categoryState = context.read<CategoryBloc>().state;
    if (categoryState is CategoryLoaded) {
      final predictedCategoryId =
          await _aiService.predictCategory(title, categoryState.categories);
      if (mounted && predictedCategoryId != null && predictedCategoryId != _selectedCategoryId) {
        setState(() {
          _selectedCategoryId = predictedCategoryId;
        });
      }
    }
  }

  void _submitTransaction() {
    if (_formKey.currentState!.validate()) {
      final transaction = Transaction(
        id: const Uuid().v4(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        categoryId: _selectedCategoryId!,
        type: _selectedType,
        isSplit: _isSplit,
        splitWith: _isSplit ? _splitWithController.text : null,
        splitAmount: _isSplit ? double.tryParse(_splitAmountController.text) : null,
      );
      context
          .read<TransactionBloc>()
          .add(AddTransaction(transaction: transaction));
      Navigator.pop(context);
    }
  }

  Future<void> _handleAddTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newTransaction = Transaction(
      id: const Uuid().v4(),
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      categoryId: _selectedCategoryId!,
      type: _selectedType,
      isSplit: _isSplit,
      splitWith: _isSplit ? _splitWithController.text : null,
      splitAmount: _isSplit ? double.tryParse(_splitAmountController.text) : null,
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
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Potential Duplicate'),
              content: const Text(
                  'This looks like a duplicate transaction. Are you sure you want to add it?'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Add Anyway'),
                  onPressed: () {
                    Navigator.of(context).pop();
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'receipt':
        return Icons.receipt;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'flight':
        return Icons.flight;
      case 'work':
        return Icons.work;
      case 'laptop':
        return Icons.laptop;
      case 'trending_up':
        return Icons.trending_up;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat.yMMMd().format(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return 'Please enter a valid number';
                  }
                  if (amount <= 0) {
                    return 'Please enter a positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 24),
              SegmentedButton<TransactionType>(
                segments: const <ButtonSegment<TransactionType>>[
                  ButtonSegment<TransactionType>(
                    value: TransactionType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment<TransactionType>(
                    value: TransactionType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: <TransactionType>{_selectedType},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Split Bill'),
                subtitle: const Text('Share this expense with someone else'),
                value: _isSplit,
                onChanged: (bool value) {
                  setState(() {
                    _isSplit = value;
                    if (_isSplit) _updateSplitAmount();
                  });
                },
              ),
              if (_isSplit) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _splitWithController,
                  decoration: const InputDecoration(
                    labelText: 'Split With (Name)',
                    prefixIcon: Icon(Icons.person_add),
                  ),
                  validator: (value) {
                    if (_isSplit && (value == null || value.isEmpty)) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _splitAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Their Share',
                    prefixIcon: Icon(Icons.money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (_isSplit && (value == null || value.isEmpty)) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoaded) {
                    if (state.categories.isEmpty) {
                      return const Text('No categories available.');
                    }
                    return DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      hint: const Text('Select Category'),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: state.categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Row(
                            children: [
                              Icon(
                                _getIconData(category.icon),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _scanReceipt,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Scan Receipt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleAddTransaction,
                      child: const Text('Add Transaction'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
