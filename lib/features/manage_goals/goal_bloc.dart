import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_tracker/models/goal.dart';
import 'package:budget_tracker/services/database_service.dart';
import 'package:equatable/equatable.dart';

part 'goal_event.dart';
part 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final DatabaseService _databaseService;

  GoalBloc({required DatabaseService databaseService})
      : _databaseService = databaseService,
        super(GoalInitial()) {
    on<LoadGoals>(_onLoadGoals);
    on<AddGoal>(_onAddGoal);
    on<UpdateGoal>(_onUpdateGoal);
    on<DeleteGoal>(_onDeleteGoal);
  }

  void _onLoadGoals(
      LoadGoals event, Emitter<GoalState> emit) async {
    emit(GoalLoading());
    try {
      final goals = await _databaseService.getGoals();
      emit(GoalLoaded(goals: goals));
    } catch (e) {
      emit(GoalError(message: e.toString()));
    }
  }

  void _onAddGoal(
      AddGoal event, Emitter<GoalState> emit) async {
    try {
      await _databaseService.insertGoal(event.goal);
      add(LoadGoals());
    } catch (e) {
      emit(GoalError(message: e.toString()));
    }
  }

  void _onUpdateGoal(
      UpdateGoal event, Emitter<GoalState> emit) async {
    try {
      await _databaseService.updateGoal(event.goal);
      add(LoadGoals());
    } catch (e) {
      emit(GoalError(message: e.toString()));
    }
  }

  void _onDeleteGoal(
      DeleteGoal event, Emitter<GoalState> emit) async {
    try {
      await _databaseService.deleteGoal(event.id);
      add(LoadGoals());
    } catch (e) {
      emit(GoalError(message: e.toString()));
    }
  }
}
