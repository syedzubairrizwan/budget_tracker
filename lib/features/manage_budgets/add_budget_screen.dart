import 'package:budget_tracker/features/manage_budgets/budget_bloc.dart';
import 'package:budget_tracker/models/budget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:budget_tracker/features/manage_categories/category_bloc.dart';
import 'package:flutter/material.dart';
import 'package:budget_tracker/core/constants.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  AddBudgetScreenState createState() => AddBudgetScreenState();
}

class AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedCategoryId;
  String _selectedPriority = 'Medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Budget'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoaded) {
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      hint: const Text('Select Category'),
                      items: [
                        const DropdownMenuItem(
                          value: 'overall',
                          child: Text('📊 Overall Budget'),
                        ),
                        ...state.categories.map((category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ))
                      ],
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
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Budget Priority',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'High', child: Text('🔥 High Priority')),
                  DropdownMenuItem(value: 'Medium', child: Text('⚡ Medium Priority')),
                  DropdownMenuItem(value: 'Low', child: Text('💤 Low Priority')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final budget = Budget(
                      id: const Uuid().v4(),
                      categoryId: _selectedCategoryId!,
                      amount: double.parse(_amountController.text),
                      spentAmount: 0,
                      priority: _selectedPriority,
                    );
                    context.read<BudgetBloc>().add(AddBudget(budget: budget));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Create Budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
