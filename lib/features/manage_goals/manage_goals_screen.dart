import 'package:budget_tracker/features/manage_goals/add_goal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_tracker/features/manage_goals/goal_bloc.dart';

class ManageGoalsScreen extends StatelessWidget {
  const ManageGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Goals'),
      ),
      body: BlocBuilder<GoalBloc, GoalState>(
        builder: (context, state) {
          if (state is GoalLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GoalLoaded) {
            return ListView.builder(
              itemCount: state.goals.length,
              itemBuilder: (context, index) {
                final goal = state.goals[index];
                return ListTile(
                  title: Text(goal.name),
                  subtitle: Text(
                      '${goal.currentAmount.toStringAsFixed(2)} / ${goal.targetAmount.toStringAsFixed(2)}'),
                );
              },
            );
          }
          if (state is GoalError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No goals yet.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddGoalScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
