import '../../../../core/resources/data_state.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repository/category_repository.dart';
import '../data_sources/category_firebase_data_source.dart';

/// Implementación concreta del [CategoryRepository] del domain layer.
/// Utiliza el data source para interactuar con Firebase.
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryFirebaseDataSource _dataSource;

  const CategoryRepositoryImpl(this._dataSource);

  @override
  Future<DataState<List<CategoryEntity>>> getCategories() async {
    try {
      final models = await _dataSource.getCategories();
      final entities = models.map((m) => m.toEntity()).toList();
      return DataState.success(entities);
    } catch (e) {
      return DataState.error(e.toString());
    }
  }

  @override
  Future<DataState<CategoryEntity>> addCategory(String name) async {
    try {
      final model = await _dataSource.addCategory(name);
      return DataState.success(model.toEntity());
    } catch (e) {
      return DataState.error(e.toString());
    }
  }
}
