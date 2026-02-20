/// Parámetros para crear un artículo.
class CreateArticleParams {
  final String title;
  final String content;
  final String? thumbnailURL;
  final String? category;

  const CreateArticleParams({
    required this.title,
    required this.content,
    this.thumbnailURL,
    this.category,
  });
}
