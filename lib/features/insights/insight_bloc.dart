import 'package:bloc/bloc.dart';
import 'package:budget_tracker/features/insights/insight_event.dart';
import 'package:budget_tracker/features/insights/insight_state.dart';
import 'package:budget_tracker/services/database_service.dart';
import 'package:budget_tracker/services/transaction_analysis_service.dart';

class InsightBloc extends Bloc<InsightEvent, InsightState> {
  final DatabaseService databaseService;
  final TransactionAnalysisService analysisService;

  InsightBloc({
    required this.databaseService,
    required this.analysisService,
  }) : super(InsightInitial()) {
    on<LoadInsights>(_onLoadInsights);
  }

  Future<void> _onLoadInsights(
    LoadInsights event,
    Emitter<InsightState> emit,
  ) async {
    emit(InsightLoading());
    try {
      final transactions = await databaseService.getTransactions();
      final categories = await databaseService.getCategories();
      final insights = await analysisService.getSpendingInsights(transactions, categories);
      emit(InsightLoaded(insights: insights));
    } catch (e) {
      emit(InsightError(message: 'Failed to load insights: $e'));
    }
  }
}