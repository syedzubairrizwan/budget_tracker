import 'package:budget_tracker/services/transaction_analysis_service.dart';
import 'package:equatable/equatable.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final List<Subscription> subscriptions;

  const SubscriptionLoaded({required this.subscriptions});

  @override
  List<Object> get props => [subscriptions];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError({required this.message});

  @override
  List<Object> get props => [message];
}