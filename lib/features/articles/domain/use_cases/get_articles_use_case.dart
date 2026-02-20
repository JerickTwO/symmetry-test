import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article_entity.dart';
import '../repository/article_repository.dart';

/// Caso de uso: Obtener todos los artículos.
/// Una sola responsabilidad — listar artículos.
/// Puro Dart — sin dependencias externas.
class GetArticlesUseCase
    extends UseCase<DataState<List<ArticleEntity>>, NoParams> {
  final ArticleRepository repository;

  GetArticlesUseCase(this.repository);

  @override
  Future<DataState<List<ArticleEntity>>> call(NoParams params) async {
    return await repository.getArticles();
  }
}
