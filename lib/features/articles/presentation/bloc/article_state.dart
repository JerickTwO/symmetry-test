import '../../domain/entities/article_entity.dart';

/// Estados del BLoC de artículos.
abstract class ArticleState {
  const ArticleState();
}

class ArticleInitial extends ArticleState {
  const ArticleInitial();
}

class ArticleLoading extends ArticleState {
  const ArticleLoading();
}

class ArticlesLoaded extends ArticleState {
  final List<ArticleEntity> articles;

  const ArticlesLoaded({required this.articles});
}

class ArticleDetailLoaded extends ArticleState {
  final ArticleEntity article;

  const ArticleDetailLoaded({required this.article});
}

class ArticleCreated extends ArticleState {
  const ArticleCreated();
}

class ArticleUpdated extends ArticleState {
  const ArticleUpdated();
}

class ArticleDeleted extends ArticleState {
  const ArticleDeleted();
}

class ArticleError extends ArticleState {
  final String message;

  const ArticleError({required this.message});
}
