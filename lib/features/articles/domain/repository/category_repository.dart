import '../../../../core/resources/data_state.dart';
import '../entities/category_entity.dart';

/// Contrato del repositorio de categorías.
/// Define las operaciones sin conocer la implementación.
/// Puro Dart — sin dependencias externas.
abstract class CategoryRepository {
  Future<DataState<List<CategoryEntity>>> getCategories();

  Future<DataState<CategoryEntity>> addCategory(String name);
}
