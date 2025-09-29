import 'package:budget_tracker/features/add_transaction/transaction_bloc.dart';
import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  AddTransactionScreenState createState() => AddTransactionScreenState();
}

class AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedCategoryId;
  TransactionType _selectedType = TransactionType.expense;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
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
              const SizedBox(height: 16),
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoaded) {
                    if (state.categories.isEmpty) {
                      return Column(
                        children: [
                          const Text(
                            'No categories available. Please add some categories first.',
                            style: TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigate to manage categories
                            },
                            child: const Text('Manage Categories'),
                          ),
                        ],
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      hint: const Text('Select Category'),
                      decoration: const InputDecoration(
                        labelText: 'Category',
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
                  } else if (state is CategoryLoading) {
                    return const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Loading categories...'),
                      ],
                    );
                  } else if (state is CategoryError) {
                    return Column(
                      children: [
                        Text(
                          'Error loading categories: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            context.read<CategoryBloc>().add(LoadCategories());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final transaction = Transaction(
                      id: const Uuid().v4(),
                      title: _titleController.text,
                      amount: double.parse(_amountController.text),
                      date: DateTime.now(),
                      categoryId: _selectedCategoryId!,
                      type: _selectedType,
                    );
                    context
                        .read<TransactionBloc>()
                        .add(AddTransaction(transaction: transaction));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}