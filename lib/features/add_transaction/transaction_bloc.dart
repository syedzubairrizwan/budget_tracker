import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/services/database_service.dart';
import 'package:equatable/equatable.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final DatabaseService _databaseService;

  TransactionBloc({required DatabaseService databaseService})
      : _databaseService = databaseService,
        super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  void _onLoadTransactions(
      LoadTransactions event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      final transactions = await _databaseService.getTransactions();
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  void _onAddTransaction(
      AddTransaction event, Emitter<TransactionState> emit) async {
    try {
      await _databaseService.insertTransaction(event.transaction);
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  void _onUpdateTransaction(
      UpdateTransaction event, Emitter<TransactionState> emit) async {
    try {
      await _databaseService.updateTransaction(event.transaction);
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  void _onDeleteTransaction(
      DeleteTransaction event, Emitter<TransactionState> emit) async {
    try {
      await _databaseService.deleteTransaction(event.id);
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }
}
