import 'package:budget_tracker/features/manage_budgets/add_budget_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_tracker/features/manage_budgets/budget_bloc.dart';

class ManageBudgetsScreen extends StatelessWidget {
  const ManageBudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Budgets'),
      ),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BudgetLoaded) {
            return ListView.builder(
              itemCount: state.budgets.length,
              itemBuilder: (context, index) {
                final budget = state.budgets[index];
                return ListTile(
                  title: Text(budget.categoryId), // I will fix this later
                  subtitle: Text(
                      '${budget.spentAmount.toStringAsFixed(2)} / ${budget.amount.toStringAsFixed(2)}'),
                );
              },
            );
          }
          if (state is BudgetError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No budgets yet.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddBudgetScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
