import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_tracker/models/budget.dart';
import 'package:budget_tracker/services/database_service.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

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
    on<ApplyTemplate>(_onApplyTemplate);
  }

  Future<void> _onLoadBudgets(
      LoadBudgets event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      final budgets = await _databaseService.getBudgets();
      emit(BudgetLoaded(budgets: budgets));
    } catch (e) {
      emit(BudgetError(message: e.toString()));
    }
  }

  Future<void> _onAddBudget(
      AddBudget event, Emitter<BudgetState> emit) async {
    try {
      // Delete any existing budget for the same category first to prevent duplicates
      final budgets = await _databaseService.getBudgets();
      for (final existingBudget in budgets) {
        if (existingBudget.categoryId == event.budget.categoryId) {
          await _databaseService.deleteBudget(existingBudget.id);
        }
      }
      await _databaseService.insertBudget(event.budget);
      final updatedBudgets = await _databaseService.getBudgets();
      emit(BudgetLoaded(budgets: updatedBudgets));
    } catch (e) {
      emit(BudgetError(message: e.toString()));
    }
  }

  Future<void> _onUpdateBudget(
      UpdateBudget event, Emitter<BudgetState> emit) async {
    try {
      await _databaseService.updateBudget(event.budget);
      final budgets = await _databaseService.getBudgets();
      emit(BudgetLoaded(budgets: budgets));
    } catch (e) {
      emit(BudgetError(message: e.toString()));
    }
  }

  Future<void> _onDeleteBudget(
      DeleteBudget event, Emitter<BudgetState> emit) async {
    try {
      await _databaseService.deleteBudget(event.id);
      final budgets = await _databaseService.getBudgets();
      emit(BudgetLoaded(budgets: budgets));
    } catch (e) {
      emit(BudgetError(message: e.toString()));
    }
  }

  Future<void> _onApplyTemplate(
      ApplyTemplate event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      // Delete all existing budgets atomically
      await _databaseService.deleteAllBudgets();

      // Add budgets from the selected template
      const uuid = Uuid();
      for (final item in event.template.items) {
        final newBudget = Budget(
          id: uuid.v4(),
          categoryId: item.categoryId,
          amount: item.amount,
          spentAmount: 0,
          priority: item.priority,
        );
        await _databaseService.insertBudget(newBudget);
      }

      // Load updated budgets directly and emit loaded state
      final budgets = await _databaseService.getBudgets();
      emit(BudgetLoaded(budgets: budgets));
    } catch (e) {
      emit(BudgetError(message: e.toString()));
    }
  }
}
