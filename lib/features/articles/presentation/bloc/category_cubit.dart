import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/use_cases/add_category_use_case.dart';
import '../../domain/use_cases/get_categories_use_case.dart';
import 'category_state.dart';

/// Cubit de categorías.
/// Maneja la carga y creación de categorías.
class CategoryCubit extends Cubit<CategoryState> {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final AddCategoryUseCase _addCategoryUseCase;

  /// Lista en memoria de las categorías cargadas.
  List<CategoryEntity> _categories = [];

  CategoryCubit({
    required GetCategoriesUseCase getCategoriesUseCase,
    required AddCategoryUseCase addCategoryUseCase,
  })  : _getCategoriesUseCase = getCategoriesUseCase,
        _addCategoryUseCase = addCategoryUseCase,
        super(const CategoryInitial());

  /// Carga todas las categorías desde Firestore.
  Future<void> loadCategories() async {
    emit(const CategoryLoading());

    final result = await _getCategoriesUseCase(const NoParams());
    if (result.isSuccess) {
      _categories = result.data!;
      emit(CategoriesLoaded(categories: _categories));
    } else {
      emit(CategoryError(message: result.error!));
    }
  }

  /// Agrega una nueva categoría y actualiza la lista.
  Future<void> addCategory(String name) async {
    final result = await _addCategoryUseCase(name);
    if (result.isSuccess) {
      final added = result.data!;

      // Verificar si ya estaba en la lista local
      final exists = _categories.any((c) => c.id == added.id);
      if (!exists) {
        _categories = [..._categories, added];
        _categories.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      }

      emit(CategoryAdded(categories: _categories, addedCategory: added));
    } else {
      emit(CategoryError(message: result.error!));
    }
  }
}
