import 'package:budget_tracker/features/subscriptions/subscription_bloc.dart';
import 'package:budget_tracker/features/subscriptions/subscription_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
      ),
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SubscriptionLoaded) {
            if (state.subscriptions.isEmpty) {
              return const Center(
                child: Text('No subscriptions detected.'),
              );
            }
            return ListView.builder(
              itemCount: state.subscriptions.length,
              itemBuilder: (context, index) {
                final subscription = state.subscriptions[index];
                return ListTile(
                  title: Text(subscription.name),
                  subtitle: Text(
                      'Next due date: ${DateFormat.yMd().format(subscription.nextDueDate)}'),
                  trailing: Text(
                    '\$${subscription.averageAmount.toStringAsFixed(2)} / mo',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            );
          } else if (state is SubscriptionError) {
            return Center(
              child: Text(state.message),
            );
          }
          return const Center(
            child: Text('Press the button to load subscriptions.'),
          );
        },
      ),
    );
  }
}