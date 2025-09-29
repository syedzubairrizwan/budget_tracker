import 'package:bloc/bloc.dart';
import 'package:budget_tracker/features/subscriptions/subscription_event.dart';
import 'package:budget_tracker/features/subscriptions/subscription_state.dart';
import 'package:budget_tracker/services/database_service.dart';
import 'package:budget_tracker/services/transaction_analysis_service.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final DatabaseService databaseService;
  final TransactionAnalysisService analysisService;

  SubscriptionBloc({
    required this.databaseService,
    required this.analysisService,
  }) : super(SubscriptionInitial()) {
    on<LoadSubscriptions>(_onLoadSubscriptions);
  }

  Future<void> _onLoadSubscriptions(
    LoadSubscriptions event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    try {
      final transactions = await databaseService.getTransactions();
      final subscriptions = await analysisService.detectSubscriptions(transactions);
      emit(SubscriptionLoaded(subscriptions: subscriptions));
    } catch (e) {
      emit(SubscriptionError(message: 'Failed to load subscriptions: $e'));
    }
  }
}