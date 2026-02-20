import '../../../articles/domain/use_cases/create_article_params.dart';
import '../../../articles/domain/use_cases/update_article_params.dart';
import '../models/article_model.dart';

/// Contrato del data source de artículos.
/// Solo estas clases interactúan directamente con servicios externos (Firebase).
abstract class ArticleFirebaseDataSource {
  Future<List<ArticleModel>> getArticles();

  Future<ArticleModel> getArticleById(String id);

  Future<ArticleModel> createArticle(CreateArticleParams params);

  Future<ArticleModel> updateArticle(UpdateArticleParams params);

  Future<void> deleteArticle(String id);
}
