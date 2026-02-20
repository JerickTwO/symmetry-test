import '../../../../core/usecase/usecase.dart';
import '../repository/article_repository.dart';

/// Caso de uso: Eliminar un artículo.
/// Una sola responsabilidad — eliminar artículo por ID.
/// Puro Dart — sin dependencias externas.
class DeleteArticleUseCase extends UseCase<void, String> {
  final ArticleRepository repository;

  DeleteArticleUseCase(this.repository);

  @override
  Future<void> call(String id) async {
    return await repository.deleteArticle(id);
  }
}
