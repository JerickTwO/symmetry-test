import '../../domain/entities/category_entity.dart';

/// Estados del Cubit de categorías.
abstract class CategoryState {
  const CategoryState();
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoriesLoaded extends CategoryState {
  final List<CategoryEntity> categories;

  const CategoriesLoaded({required this.categories});
}

class CategoryAdded extends CategoryState {
  final List<CategoryEntity> categories;
  final CategoryEntity addedCategory;

  const CategoryAdded({
    required this.categories,
    required this.addedCategory,
  });
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError({required this.message});
}
