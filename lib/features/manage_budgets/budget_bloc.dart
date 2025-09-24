import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_tracker/models/budget.dart';
import 'package:budget_tracker/services/database_service.dart';
import 'package:equatable/equatable.dart';

part 'budget_event.dart';
part 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final DatabaseService _databaseService;

  BudgetBloc({required DatabaseService databaseService})
      : _databaseService = databaseService,
        super(BudgetInitial()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<AddBudget>(_onAddBudget);
    on<UpdateBudget>(_onUpdateBudget);
    on<DeleteBudget>(_onDeleteBudget);
  }

  void _onLoadBudgets(
      LoadBudgets event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      final budgets = await _databaseService.getBudgets();
      emit(BudgetLoaded(budgets: budgets));
    } catch (e) {
      emit(BudgetError(message: e.toString()));
    }
  }

  void _onAddBudget(
      AddBudget event, Emitter<BudgetState> emit) async {
    try {
      await _databaseService.insertBudget(event.budget);
      add(LoadBudgets());
    } catch (e) {
      emit(BudgetError(message: e.toString()));
    }
  }

  void _onUpdateBudget(
      UpdateBudget event, Emitter<BudgetState> emit) async {
    try {
      await _databaseService.updateBudget(event.budget);
      add(LoadBudgets());
    } catch (e) {
      emit(BudgetError(message: e.toString()));
    }
  }

  void _onDeleteBudget(
      DeleteBudget event, Emitter<BudgetState> emit) async {
    try {
      await _databaseService.deleteBudget(event.id);
      add(LoadBudgets());
    } catch (e) {
      emit(BudgetError(message: e.toString()));
    }
  }
}
