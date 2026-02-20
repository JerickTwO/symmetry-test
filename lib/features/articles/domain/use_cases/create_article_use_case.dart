import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article_entity.dart';
import '../repository/article_repository.dart';
import 'create_article_params.dart';

/// Caso de uso: Crear un nuevo artículo.
/// Una sola responsabilidad — crear artículo.
/// Puro Dart — sin dependencias externas.
class CreateArticleUseCase
    extends UseCase<DataState<ArticleEntity>, CreateArticleParams> {
  final ArticleRepository repository;

  CreateArticleUseCase(this.repository);

  @override
  Future<DataState<ArticleEntity>> call(CreateArticleParams params) async {
    return await repository.createArticle(params);
  }
}
