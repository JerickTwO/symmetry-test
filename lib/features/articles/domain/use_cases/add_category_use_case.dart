import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/category_entity.dart';
import '../repository/category_repository.dart';

/// Caso de uso: Agregar una nueva categoría.
/// Una sola responsabilidad — crear categoría.
/// Puro Dart — sin dependencias externas.
class AddCategoryUseCase extends UseCase<DataState<CategoryEntity>, String> {
  final CategoryRepository repository;

  AddCategoryUseCase(this.repository);

  @override
  Future<DataState<CategoryEntity>> call(String name) async {
    return await repository.addCategory(name);
  }
}
