import '../../../../core/resources/data_state.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/repository/article_repository.dart';
import '../../domain/use_cases/create_article_params.dart';
import '../../domain/use_cases/update_article_params.dart';
import '../data_sources/article_firebase_data_source.dart';

/// Implementación concreta del [ArticleRepository] del domain layer.
/// Cumple el contrato definido en la capa de negocio.
/// Utiliza el data source para interactuar con Firebase.
class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleFirebaseDataSource _dataSource;

  const ArticleRepositoryImpl(this._dataSource);

  @override
  Future<DataState<List<ArticleEntity>>> getArticles() async {
    try {
      final models = await _dataSource.getArticles();
      final entities = models.map((m) => m.toEntity()).toList();
      return DataState.success(entities);
    } catch (e) {
      return DataState.error(e.toString());
    }
  }

  @override
  Future<DataState<ArticleEntity>> getArticleById(String id) async {
    try {
      final model = await _dataSource.getArticleById(id);
      return DataState.success(model.toEntity());
    } catch (e) {
      return DataState.error(e.toString());
    }
  }

  @override
  Future<DataState<ArticleEntity>> createArticle(
      CreateArticleParams params) async {
    try {
      final model = await _dataSource.createArticle(params);
      return DataState.success(model.toEntity());
    } catch (e) {
      return DataState.error(e.toString());
    }
  }

  @override
  Future<DataState<ArticleEntity>> updateArticle(
      UpdateArticleParams params) async {
    try {
      final model = await _dataSource.updateArticle(params);
      return DataState.success(model.toEntity());
    } catch (e) {
      return DataState.error(e.toString());
    }
  }

  @override
  Future<void> deleteArticle(String id) async {
    await _dataSource.deleteArticle(id);
  }
}
