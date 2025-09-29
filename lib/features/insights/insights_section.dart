import 'package:budget_tracker/features/insights/insight_bloc.dart';
import 'package:budget_tracker/features/insights/insight_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InsightsSection extends StatelessWidget {
  const InsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spending Insights',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<InsightBloc, InsightState>(
          builder: (context, state) {
            if (state is InsightLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is InsightLoaded) {
              if (state.insights.isEmpty) {
                return const Card(
                  child: ListTile(
                    title: Text('No insights available yet.'),
                    subtitle: Text('Keep using the app to generate new insights.'),
                  ),
                );
              }
              return Column(
                children: state.insights.map((insight) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                      title: Text(insight.title),
                      subtitle: Text(insight.description),
                    ),
                  );
                }).toList(),
              );
            } else if (state is InsightError) {
              return Card(
                color: Colors.red.shade50,
                child: ListTile(
                  leading: const Icon(Icons.error_outline, color: Colors.red),
                  title: const Text('Could not load insights'),
                  subtitle: Text(state.message),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}