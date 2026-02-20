import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/category_entity.dart';
import '../repository/category_repository.dart';

/// Caso de uso: Obtener todas las categorías.
/// Una sola responsabilidad — listar categorías.
/// Puro Dart — sin dependencias externas.
class GetCategoriesUseCase
    extends UseCase<DataState<List<CategoryEntity>>, NoParams> {
  final CategoryRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<DataState<List<CategoryEntity>>> call(NoParams params) async {
    return await repository.getCategories();
  }
}
