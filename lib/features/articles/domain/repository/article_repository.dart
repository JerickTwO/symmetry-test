import '../../../../core/resources/data_state.dart';
import '../entities/article_entity.dart';
import '../use_cases/create_article_params.dart';
import '../use_cases/update_article_params.dart';

/// Contrato del repositorio de artículos.
/// Define las operaciones CRUD sin conocer la implementación.
/// Puro Dart — sin dependencias externas.
abstract class ArticleRepository {
  Future<DataState<List<ArticleEntity>>> getArticles();

  Future<DataState<ArticleEntity>> getArticleById(String id);

  Future<DataState<ArticleEntity>> createArticle(CreateArticleParams params);

  Future<DataState<ArticleEntity>> updateArticle(UpdateArticleParams params);

  Future<void> deleteArticle(String id);
}
