import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article_entity.dart';
import '../repository/article_repository.dart';

/// Caso de uso: Obtener un artículo por su ID.
/// Una sola responsabilidad — obtener detalle de artículo.
/// Puro Dart — sin dependencias externas.
class GetArticleByIdUseCase extends UseCase<DataState<ArticleEntity>, String> {
  final ArticleRepository repository;

  GetArticleByIdUseCase(this.repository);

  @override
  Future<DataState<ArticleEntity>> call(String id) async {
    return await repository.getArticleById(id);
  }
}
