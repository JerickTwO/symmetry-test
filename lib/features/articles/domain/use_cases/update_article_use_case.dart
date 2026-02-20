import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article_entity.dart';
import '../repository/article_repository.dart';
import 'update_article_params.dart';

/// Caso de uso: Actualizar un artículo existente.
/// Una sola responsabilidad — actualizar artículo.
/// Puro Dart — sin dependencias externas.
class UpdateArticleUseCase
    extends UseCase<DataState<ArticleEntity>, UpdateArticleParams> {
  final ArticleRepository repository;

  UpdateArticleUseCase(this.repository);

  @override
  Future<DataState<ArticleEntity>> call(UpdateArticleParams params) async {
    return await repository.updateArticle(params);
  }
}
