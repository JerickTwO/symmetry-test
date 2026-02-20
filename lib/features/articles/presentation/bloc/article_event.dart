import 'dart:typed_data';

/// Eventos del BLoC de artículos.
abstract class ArticleEvent {
  const ArticleEvent();
}

class LoadArticles extends ArticleEvent {
  const LoadArticles();
}

class LoadArticleDetail extends ArticleEvent {
  final String articleId;

  const LoadArticleDetail({required this.articleId});
}

class CreateArticleRequested extends ArticleEvent {
  final String title;
  final String content;
  final Uint8List? imageData;
  final String? imageFileName;
  final String? category;

  const CreateArticleRequested({
    required this.title,
    required this.content,
    this.imageData,
    this.imageFileName,
    this.category,
  });
}

class UpdateArticleRequested extends ArticleEvent {
  final String id;
  final String title;
  final String content;
  final Uint8List? imageData;
  final String? imageFileName;
  final String? category;

  const UpdateArticleRequested({
    required this.id,
    required this.title,
    required this.content,
    this.imageData,
    this.imageFileName,
    this.category,
  });
}

class DeleteArticleRequested extends ArticleEvent {
  final String articleId;

  const DeleteArticleRequested({required this.articleId});
}
