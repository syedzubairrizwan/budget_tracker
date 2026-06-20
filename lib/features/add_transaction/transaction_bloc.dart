import 'package:budget_tracker/services/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/services/database_service.dart';
import 'package:equatable/equatable.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final DatabaseService _databaseService;
  final NotificationService _notificationService;

  TransactionBloc({
    required DatabaseService databaseService,
    required NotificationService notificationService,
  }) : _databaseService = databaseService,
       _notificationService = notificationService,
       super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<SearchTransactions>(_onSearchTransactions);
  }

  void _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await _databaseService.getTransactions();
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  void _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _databaseService.insertTransaction(event.transaction);
      add(LoadTransactions());

      // Trigger automatic budget recalculation and check for overspend warnings
      final budgets = await _databaseService.getBudgets();
      for (var budget in budgets) {
        if (event.transaction.categoryId == budget.categoryId) {
          if (budget.amount > 0 && budget.spentAmount / budget.amount > 0.9) {
            _notificationService.showNotification(
              0,
              'Budget Alert',
              'You have spent over 90% of your budget for ${budget.categoryId}',
              '',
            );
          }
        }
      }
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  void _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _databaseService.updateTransaction(event.transaction);
      add(LoadTransactions());
      // Trigger budget recalculation after update
      await _databaseService.getBudgets();
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  void _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _databaseService.deleteTransaction(event.id);
      add(LoadTransactions());
      // Trigger budget recalculation after deletion
      await _databaseService.getBudgets();
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  void _onSearchTransactions(
    SearchTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    final currentState = state;
    if (currentState is TransactionLoaded) {
      if (event.query.isEmpty) {
        add(LoadTransactions());
      } else {
        final filteredTransactions = currentState.transactions
            .where(
              (transaction) => transaction.title.toLowerCase().contains(
                event.query.toLowerCase(),
              ),
            )
            .toList();
        emit(
          TransactionLoaded(
            transactions: filteredTransactions,
            searchQuery: event.query,
          ),
        );
      }
    }
  }
}
