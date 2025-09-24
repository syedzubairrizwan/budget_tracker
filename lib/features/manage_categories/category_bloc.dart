import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:budget_tracker/services/database_service.dart';
import 'package:equatable/equatable.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final DatabaseService _databaseService;

  CategoryBloc({required DatabaseService databaseService})
      : _databaseService = databaseService,
        super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  void _onLoadCategories(
      LoadCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final categories = await _databaseService.getCategories();
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  void _onAddCategory(
      AddCategory event, Emitter<CategoryState> emit) async {
    try {
      await _databaseService.insertCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  void _onUpdateCategory(
      UpdateCategory event, Emitter<CategoryState> emit) async {
    try {
      await _databaseService.updateCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  void _onDeleteCategory(
      DeleteCategory event, Emitter<CategoryState> emit) async {
    try {
      await _databaseService.deleteCategory(event.id);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }
}
