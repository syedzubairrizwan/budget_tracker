import 'package:budget_tracker/services/transaction_analysis_service.dart';
import 'package:equatable/equatable.dart';

abstract class InsightState extends Equatable {
  const InsightState();

  @override
  List<Object> get props => [];
}

class InsightInitial extends InsightState {}

class InsightLoading extends InsightState {}

class InsightLoaded extends InsightState {
  final List<Insight> insights;

  const InsightLoaded({required this.insights});

  @override
  List<Object> get props => [insights];
}

class InsightError extends InsightState {
  final String message;

  const InsightError({required this.message});

  @override
  List<Object> get props => [message];
}