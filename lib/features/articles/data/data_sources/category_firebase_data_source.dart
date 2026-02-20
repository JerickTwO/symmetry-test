import '../models/category_model.dart';

/// Contrato del data source de categorías.
/// Solo estas clases interactúan directamente con servicios externos (Firebase).
abstract class CategoryFirebaseDataSource {
  /// Obtiene todas las categorías disponibles.
  Future<List<CategoryModel>> getCategories();

  /// Agrega una nueva categoría y retorna el modelo creado.
  Future<CategoryModel> addCategory(String name);
}
